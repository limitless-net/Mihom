import 'dart:convert';
import 'package:fl_clash/xboard/infrastructure/network/proxy_aware_http.dart';

class RemoteTaskService {
  Future<Map<String, dynamic>> executeHttpRequest({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? headers,
    dynamic body,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final stringHeaders = headers?.map((k, v) => MapEntry(k, v.toString()));

      // 目前 ProxyAwareHttpClient 仅支持 GET；非 GET 请求退化为直连
      final responseBody = await ProxyAwareHttpClient.getString(
        url,
        timeout: const Duration(seconds: 30),
        headers: stringHeaders,
      );

      stopwatch.stop();
      if (responseBody == null) {
        return {
          'status': 'error',
          'errorMessage': 'All channels failed',
          'latency': stopwatch.elapsedMilliseconds,
        };
      }

      // 尝试解析 JSON
      dynamic parsed;
      try {
        parsed = json.decode(responseBody);
      } catch (_) {
        parsed = responseBody;
      }

      return {
        'status': 'success',
        'statusCode': 200,
        'body': parsed,
        'latency': stopwatch.elapsedMilliseconds,
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'status': 'error',
        'errorMessage': e.toString(),
        'latency': stopwatch.elapsedMilliseconds,
      };
    }
  }
}
