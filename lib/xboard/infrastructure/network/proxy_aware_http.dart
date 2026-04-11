/// 代理感知的 HTTP 客户端工具
///
/// 统一封装直连 / SOCKS5 / Relay 三种通道的 HTTP GET 请求，
/// 供 UpdateService、RemoteConfigManager 等非 SDK 请求使用。
///
/// 使用方式:
/// ```dart
/// final result = await ProxyAwareHttpClient.getString(url);
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/infrastructure/network/relay_client.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:socks5_proxy/socks_client.dart';

final _logger = FileLogger('proxy_aware_http.dart');

/// 代理感知的 HTTP 客户端
///
/// 根据域名竞速结果，自动选择最优通道（直连 / SOCKS5 / Relay）发送请求。
/// 当竞速结果使用代理时，会并发直连+代理，取最快返回的结果。
class ProxyAwareHttpClient {
  /// 发送 GET 请求并返回响应字符串
  ///
  /// 自动使用竞速结果中的代理配置，如果有代理则并发直连+代理竞速
  static Future<String?> getString(
    String url, {
    Duration timeout = const Duration(seconds: 15),
    Map<String, String>? headers,
  }) async {
    final racingResult = XBoardConfig.lastRacingResult;
    final proxyUrls = XBoardConfig.allProxyUrls;

    // 如果没有可用代理，直接直连
    if (proxyUrls.isEmpty && (racingResult == null || !racingResult.useProxy)) {
      return _directGet(url, timeout: timeout, headers: headers);
    }

    // 并发竞速：直连 + 所有代理
    final futures = <Future<String?>>[];

    // 直连
    futures.add(_directGet(url, timeout: timeout, headers: headers));

    // 代理通道
    final proxies = <String>{};
    if (racingResult != null && racingResult.useProxy && racingResult.proxyUrl != null) {
      proxies.add(racingResult.proxyUrl!);
    }
    for (final p in proxyUrls) {
      proxies.add(p);
    }

    for (final proxyUrl in proxies) {
      if (proxyUrl.toLowerCase().startsWith('relay://')) {
        futures.add(_relayGet(url, proxyUrl, timeout: timeout, headers: headers));
      } else if (proxyUrl.toLowerCase().startsWith('socks5://')) {
        futures.add(_socks5Get(url, proxyUrl, timeout: timeout, headers: headers));
      }
    }

    // 取第一个成功的结果
    try {
      final result = await _waitForFirstSuccess(futures);
      return result;
    } catch (e) {
      _logger.error('[ProxyAwareHttp] 所有通道均失败', e);
      return null;
    }
  }

  /// 直连 GET
  static Future<String?> _directGet(
    String url, {
    required Duration timeout,
    Map<String, String>? headers,
  }) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = timeout;
      client.badCertificateCallback = (_, _, _) => true;
      client.findProxy = (_) => 'DIRECT';

      final request = await client.getUrl(Uri.parse(url));
      headers?.forEach((k, v) => request.headers.set(k, v));

      final response = await request.close().timeout(timeout);
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        _logger.info('[ProxyAwareHttp] 直连成功: $url');
        return body;
      }
      return null;
    } catch (e) {
      _logger.debug('[ProxyAwareHttp] 直连失败: $url ($e)');
      return null;
    } finally {
      client?.close();
    }
  }

  /// Relay 中继 GET
  static Future<String?> _relayGet(
    String url,
    String relayUrl, {
    required Duration timeout,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await RelayClient.request(
        relayUrl: relayUrl,
        targetUrl: url,
        method: 'GET',
        headers: headers,
        timeout: timeout,
      );
      if (response.isSuccess) {
        _logger.info('[ProxyAwareHttp] Relay成功: $url');
        return response.bodyString;
      }
      return null;
    } catch (e) {
      _logger.debug('[ProxyAwareHttp] Relay失败: $url ($e)');
      return null;
    }
  }

  /// SOCKS5 代理 GET
  static Future<String?> _socks5Get(
    String url,
    String proxyUrl, {
    required Duration timeout,
    Map<String, String>? headers,
  }) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = timeout;
      client.badCertificateCallback = (_, _, _) => true;

      // 解析 socks5://user:pass@host:port
      var proxy = proxyUrl;
      if (proxy.toLowerCase().startsWith('socks5://')) {
        proxy = proxy.substring(9);
      }
      String? username;
      String? password;
      String hostPort = proxy;
      if (proxy.contains('@')) {
        final atIdx = proxy.lastIndexOf('@');
        final auth = proxy.substring(0, atIdx);
        hostPort = proxy.substring(atIdx + 1);
        if (auth.contains(':')) {
          username = auth.substring(0, auth.indexOf(':'));
          password = auth.substring(auth.indexOf(':') + 1);
        }
      }
      final parts = hostPort.split(':');
      final host = parts[0];
      final port = parts.length > 1 ? int.parse(parts[1]) : 1080;

      SocksTCPClient.assignToHttpClient(client, [
        ProxySettings(
          InternetAddress(host),
          port,
          username: username,
          password: password,
        ),
      ]);

      final request = await client.getUrl(Uri.parse(url));
      headers?.forEach((k, v) => request.headers.set(k, v));

      final response = await request.close().timeout(timeout);
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        _logger.info('[ProxyAwareHttp] SOCKS5成功: $url');
        return body;
      }
      return null;
    } catch (e) {
      _logger.debug('[ProxyAwareHttp] SOCKS5失败: $url ($e)');
      return null;
    } finally {
      client?.close();
    }
  }

  /// 等待第一个非 null 结果
  static Future<String?> _waitForFirstSuccess(List<Future<String?>> futures) async {
    if (futures.isEmpty) return null;

    final completer = Completer<String?>();
    int remaining = futures.length;

    for (final future in futures) {
      future.then((result) {
        if (result != null && !completer.isCompleted) {
          completer.complete(result);
        } else {
          remaining--;
          if (remaining == 0 && !completer.isCompleted) {
            completer.complete(null);
          }
        }
      }).catchError((e) {
        remaining--;
        if (remaining == 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    return completer.future;
  }
}
