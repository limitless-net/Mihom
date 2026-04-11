/// 网络异常消息中文翻译
///
/// 将 Dart 运行时英文异常消息转为中文，便于日志阅读
library;

/// 将异常对象的消息翻译为中文
String translateError(Object error) {
  final msg = error.toString();
  return translateErrorMessage(msg);
}

/// 将英文异常消息字符串翻译为中文
String translateErrorMessage(String msg) {
  // HandshakeException
  if (msg.contains('HandshakeException')) {
    if (msg.contains('Connection terminated during handshake')) {
      return '握手失败：连接在TLS握手期间被中断';
    }
    if (msg.contains('CERTIFICATE_VERIFY_FAILED')) {
      return '握手失败：证书验证失败';
    }
    return '握手失败：${_extractAfterColon(msg, 'HandshakeException')}';
  }

  // SocketException
  if (msg.contains('SocketException')) {
    if (msg.contains('Connection refused')) {
      return '连接被拒绝';
    }
    if (msg.contains('Connection reset by peer')) {
      return '连接被对端重置';
    }
    if (msg.contains('Connection timed out')) {
      return '连接超时';
    }
    if (msg.contains('Network is unreachable')) {
      return '网络不可达';
    }
    if (msg.contains('No route to host')) {
      return '无法路由到主机';
    }
    if (msg.contains('HTTP connection timed out')) {
      return 'HTTP连接超时';
    }
    if (msg.contains('Connection failed')) {
      return '连接失败';
    }
    return '网络异常：${_extractAfterColon(msg, 'SocketException')}';
  }

  // TimeoutException
  if (msg.contains('TimeoutException')) {
    return '请求超时';
  }

  // TlsException
  if (msg.contains('TlsException')) {
    return 'TLS连接失败';
  }

  // HttpException
  if (msg.contains('HttpException')) {
    return 'HTTP请求异常';
  }

  // ClientException (from http package)
  if (msg.contains('ClientException')) {
    if (msg.contains('Connection closed')) {
      return '连接已关闭';
    }
    return '客户端请求异常';
  }

  // OS Error
  if (msg.contains('OS Error')) {
    if (msg.contains('errno = 10054') || msg.contains('Connection reset')) {
      return '连接被重置';
    }
    if (msg.contains('errno = 10061') || msg.contains('Connection refused')) {
      return '连接被拒绝';
    }
    if (msg.contains('errno = 11001') || msg.contains('getaddrinfo')) {
      return 'DNS解析失败';
    }
  }

  // 以上都不匹配
  return msg;
}

/// 提取异常类名后面的描述部分
String _extractAfterColon(String msg, String exceptionType) {
  final idx = msg.indexOf(exceptionType);
  if (idx >= 0) {
    final rest = msg.substring(idx + exceptionType.length);
    final colonIdx = rest.indexOf(':');
    if (colonIdx >= 0) {
      return rest.substring(colonIdx + 1).trim();
    }
  }
  return msg;
}
