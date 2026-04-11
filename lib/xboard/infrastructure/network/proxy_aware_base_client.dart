/// 代理感知的 http.BaseClient 实现
///
/// 替代 `http.Client()` 直连，自动根据域名竞速结果选择最优通道。
/// 支持 Relay 中继和 SOCKS5，兼容 http 包的所有 API（get/post/multipart 等）。
library;

import 'dart:async';
import 'dart:io';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/infrastructure/network/relay_client.dart';
import 'package:http/http.dart' as http;
import 'package:socks5_proxy/socks_client.dart';

final _logger = FileLogger('proxy_aware_base_client.dart');

/// 代理感知的 http.BaseClient
///
/// 在构造时根据当前竞速结果决定通道：
/// - relay:// → 转换为 Relay POST /r
/// - socks5:// → 通过 SOCKS5 代理
/// - 否则 → 直连
class ProxyAwareBaseClient extends http.BaseClient {
  HttpClient? _innerClient;
  String? _proxyUrl;
  bool _isRelay = false;

  ProxyAwareBaseClient() {
    _proxyUrl = _getBestProxy();
    _isRelay = _proxyUrl != null &&
        _proxyUrl!.toLowerCase().startsWith('relay://');
    if (!_isRelay) {
      _innerClient = _createHttpClient(_proxyUrl);
    }
  }

  static String? _getBestProxy() {
    final racing = XBoardConfig.lastRacingResult;
    if (racing != null && racing.useProxy && racing.proxyUrl != null) {
      return racing.proxyUrl;
    }
    // fallback: 取第一个可用代理
    final all = XBoardConfig.allProxyUrls;
    return all.isNotEmpty ? all.first : null;
  }

  static HttpClient _createHttpClient(String? proxyUrl) {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    client.badCertificateCallback = (_, _, _) => true;

    if (proxyUrl != null && proxyUrl.toLowerCase().startsWith('socks5://')) {
      final parsed = _parseSocks5(proxyUrl);
      SocksTCPClient.assignToHttpClient(client, [parsed]);
      _logger.info('[ProxyBaseClient] 使用 SOCKS5: $proxyUrl');
    } else {
      client.findProxy = (_) => 'DIRECT';
      _logger.debug('[ProxyBaseClient] 使用直连');
    }
    return client;
  }

  static ProxySettings _parseSocks5(String url) {
    var proxy = url;
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
    return ProxySettings(
      InternetAddress(host),
      port,
      username: username,
      password: password,
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_isRelay) {
      return _sendViaRelay(request);
    }
    return _sendViaIOClient(request);
  }

  /// 通过 dart:io HttpClient 发送（直连或 SOCKS5）
  Future<http.StreamedResponse> _sendViaIOClient(
      http.BaseRequest request) async {
    final client = _innerClient!;
    final ioRequest = await client.openUrl(request.method, request.url);

    // 复制请求头
    request.headers.forEach((key, value) {
      ioRequest.headers.set(key, value);
    });

    // 写入请求体
    if (request is http.Request && request.bodyBytes.isNotEmpty) {
      ioRequest.contentLength = request.bodyBytes.length;
      ioRequest.add(request.bodyBytes);
    } else if (request is http.MultipartRequest) {
      // MultipartRequest 需要被 finalize 成 ByteStream
      final stream = request.finalize();
      ioRequest.contentLength = request.contentLength;
      await ioRequest.addStream(stream);
    } else if (request is http.StreamedRequest) {
      await ioRequest.addStream(request.finalize());
    }

    final ioResponse = await ioRequest.close();

    // 转换响应头
    final headers = <String, String>{};
    ioResponse.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });

    return http.StreamedResponse(
      ioResponse,
      ioResponse.statusCode,
      headers: headers,
      reasonPhrase: ioResponse.reasonPhrase,
      contentLength: ioResponse.contentLength == -1
          ? null
          : ioResponse.contentLength,
      request: request,
      isRedirect: ioResponse.isRedirect,
    );
  }

  /// 通过 Relay 中继发送
  Future<http.StreamedResponse> _sendViaRelay(
      http.BaseRequest request) async {
    // 收集请求体
    List<int>? bodyBytes;
    if (request is http.Request && request.bodyBytes.isNotEmpty) {
      bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      final stream = request.finalize();
      bodyBytes = await stream.toBytes();
    } else if (request is http.StreamedRequest) {
      bodyBytes = await request.finalize().toBytes();
    }

    // 转换 headers 为 Map<String, String>
    final headers = Map<String, String>.from(request.headers);

    final relayResponse = await RelayClient.request(
      relayUrl: _proxyUrl!,
      targetUrl: request.url.toString(),
      method: request.method,
      headers: headers.isNotEmpty ? headers : null,
      body: bodyBytes,
      timeout: const Duration(seconds: 30),
    );

    _logger.debug(
        '[ProxyBaseClient] Relay 响应: ${relayResponse.statusCode} (${relayResponse.body.length}B)');

    // 转换为 http.StreamedResponse
    final responseHeaders = <String, String>{};
    relayResponse.headers.forEach((k, v) {
      responseHeaders[k] = v;
    });

    return http.StreamedResponse(
      Stream.value(relayResponse.body),
      relayResponse.statusCode,
      headers: responseHeaders,
      request: request,
    );
  }

  @override
  void close() {
    _innerClient?.close();
    super.close();
  }
}
