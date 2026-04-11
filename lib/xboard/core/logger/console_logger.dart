/// 控制台日志实现
///
/// 使用 Dart 原生 print 输出日志，不依赖任何外部包
library;

import 'logger_interface.dart';

/// 控制台日志实现
class ConsoleLogger implements LoggerInterface {
  static const String _prefix = '[XBoard]';

  @override
  LogLevel minLevel;

  /// 是否启用时间戳
  final bool enableTimestamp;

  /// 是否启用颜色（仅在支持 ANSI 的终端中有效）
  final bool enableColor;

  ConsoleLogger({
    this.minLevel = LogLevel.info,
    this.enableTimestamp = true,
    this.enableColor = false,
  });

  /// ANSI 颜色代码
  static const String _reset = '\x1B[0m';
  static const String _debugColor = '\x1B[2;36m';       // 暗淡青色
  static const String _infoColor = '\x1B[32m';           // 绿色
  static const String _warningColor = '\x1B[1;33m';      // 粗体黄色
  static const String _errorColor = '\x1B[1;37;41m';     // 粗体白字红底

  /// 各级别 emoji 前缀
  static const String _debugEmoji = '🔍';
  static const String _infoEmoji = 'ℹ️';
  static const String _warningEmoji = '⚠️';
  static const String _errorEmoji = '❌';

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (minLevel.index <= LogLevel.debug.index) {
      _log('DEBUG', message, error, stackTrace, _debugColor, _debugEmoji);
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (minLevel.index <= LogLevel.info.index) {
      _log('INFO', message, error, stackTrace, _infoColor, _infoEmoji);
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (minLevel.index <= LogLevel.warning.index) {
      _log('WARN', message, error, stackTrace, _warningColor, _warningEmoji);
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (minLevel.index <= LogLevel.error.index) {
      _log('ERROR', message, error, stackTrace, _errorColor, _errorEmoji);
    }
  }

  void _log(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    String colorCode,
    String emoji,
  ) {
    final timestamp = enableTimestamp ? _getTimestamp() : '';

    if (enableColor) {
      // 彩色模式：emoji + ANSI颜色 + 粗体区分
      final buffer = StringBuffer();
      buffer.write('$colorCode$emoji $_prefix$timestamp[$level] $message$_reset');
      // ignore: avoid_print
      print(buffer.toString());

      if (error != null) {
        // ignore: avoid_print
        print('$colorCode$emoji $_prefix$timestamp[$level] Error: $error$_reset');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('$colorCode$emoji $_prefix$timestamp[$level] StackTrace:\n$stackTrace$_reset');
      }
    } else {
      // 纯文本模式：仅用 emoji 区分
      // ignore: avoid_print
      print('$emoji $_prefix$timestamp[$level] $message');

      if (error != null) {
        // ignore: avoid_print
        print('$emoji $_prefix$timestamp[$level] Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('$emoji $_prefix$timestamp[$level] StackTrace:\n$stackTrace');
      }
    }
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}]';
  }
}

