/// HTTP Relay 中继代理客户端
///
/// 协议: relay://authKey@host:port
/// 通过 HTTP POST /r 将请求中继到目标 URL
///
/// 请求头:
///   X-K: 认证密钥
///   X-T: base64(目标URL)
///   X-M: HTTP方法 (GET/POST/...)
///   X-H: base64(JSON自定义请求头)
///
/// 响应头:
///   X-S: 目标服务器原始状态码
///   X-RH: base64(JSON原始响应头)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('relay_client.dart');

class RelayClient {
  /// 解析 relay:// URL
  ///
  /// 支持格式:
  /// - `relay://authKey@host:port`
  /// - `relay://authKey@host:port|[ipv6]:port` (双栈，取第一个地址)
  static ({String authKey, String host, int port}) parseRelayUrl(
      String relayUrl) {
    var url = relayUrl.trim();
    if (url.toLowerCase().startsWith('relay://')) {
      url = url.substring(8);
    }

    final atIndex = url.indexOf('@');
    if (atIndex == -1) {
      throw FormatException('Relay URL 缺少认证密钥: $relayUrl');
    }

    final authKey = url.substring(0, atIndex);
    var hostPart = url.substring(atIndex + 1);

    // 双栈格式：取第一个地址
    if (hostPart.contains('|')) {
      hostPart = hostPart.split('|').first;
    }

    String host;
    int port;

    if (hostPart.startsWith('[')) {
      // IPv6: [::1]:port
      final closeBracket = hostPart.indexOf(']');
      if (closeBracket == -1) {
        throw FormatException('Relay URL IPv6 格式错误: $hostPart');
      }
      host = hostPart.substring(1, closeBracket);
      port = int.parse(hostPart.substring(closeBracket + 2));
    } else {
      final colonIndex = hostPart.lastIndexOf(':');
      if (colonIndex == -1) {
        throw FormatException('Relay URL 缺少端口号: $hostPart');
      }
      host = hostPart.substring(0, colonIndex);
      port = int.parse(hostPart.substring(colonIndex + 1));
    }

    return (authKey: authKey, host: host, port: port);
  }

  /// 通过 relay 中继发送请求
  static Future<RelayResponse> request({
    required String relayUrl,
    required String targetUrl,
    String method = 'GET',
    Map<String, String>? headers,
    List<int>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final parsed = parseRelayUrl(relayUrl);
    _logger.info(
        '[Relay] POST → ${parsed.host}:${parsed.port}/r | 目标: $targetUrl');

    final client = HttpClient();
    client.connectionTimeout = timeout;
    client.findProxy = (_) => 'DIRECT';

    try {
      final relayHost =
          parsed.host.contains(':') ? '[${parsed.host}]' : parsed.host;
      final relayUri = Uri.parse('http://$relayHost:${parsed.port}/r');

      final request = await client.postUrl(relayUri);

      // Relay 协议头
      request.headers.set('X-K', parsed.authKey);
      request.headers.set('X-T', base64.encode(utf8.encode(targetUrl)));
      request.headers.set('X-M', method);

      if (headers != null && headers.isNotEmpty) {
        request.headers.set(
          'X-H',
          base64.encode(utf8.encode(json.encode(headers))),
        );
      }

      if (body != null && body.isNotEmpty) {
        request.contentLength = body.length;
        request.add(body);
      }

      final response = await request.close().timeout(timeout);

      final responseBytes = await response.fold<List<int>>(
        <int>[],
        (prev, chunk) => prev..addAll(chunk),
      );

      // 解析 relay 响应
      final originalStatus =
          int.tryParse(response.headers.value('x-s') ?? '') ??
              response.statusCode;

      // 原始响应头 (key 统一小写)
      Map<String, String> originalHeaders = {};
      final rhB64 = response.headers.value('x-rh');
      if (rhB64 != null && rhB64.isNotEmpty) {
        try {
          final decoded = json.decode(utf8.decode(base64.decode(rhB64)));
          if (decoded is Map) {
            originalHeaders = decoded
                .map((k, v) => MapEntry(k.toString().toLowerCase(), v.toString()));
          }
        } catch (_) {}
      }

      _logger.info(
          '[Relay] 响应: relay=${response.statusCode}, 原始=$originalStatus, body=${responseBytes.length}B');

      return RelayResponse(
        statusCode: originalStatus,
        body: responseBytes,
        headers: originalHeaders,
        relayStatusCode: response.statusCode,
      );
    } finally {
      client.close();
    }
  }
}

/// Relay 中继响应
class RelayResponse {
  final int statusCode;
  final List<int> body;
  final Map<String, String> headers;
  final int relayStatusCode;

  const RelayResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.relayStatusCode,
  });

  String get bodyString => utf8.decode(body);

  bool get isSuccess =>
      relayStatusCode == 200 && statusCode >= 200 && statusCode < 400;
}
