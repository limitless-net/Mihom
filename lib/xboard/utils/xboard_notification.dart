import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';

/// XBoard 通知工具类
/// 
/// 使用 FlClash 的底部中间 SnackBar 通知（自动消失）
class XBoardNotification {
  XBoardNotification._();

  /// 显示错误通知（底部中间 SnackBar，自动消失）
  static void showError(String message) {
    final context = globalState.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      context.showSnackBar('❌ $message');
    }
  }

  /// 显示成功通知（底部中间 SnackBar，自动消失，绿色）
  static void showSuccess(String message) {
    final context = globalState.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          margin: _getSnackBarMargin(context),
        ),
      );
    }
  }

  /// 显示普通通知（底部中间 SnackBar，自动消失）
  static void showInfo(String message) {
    final context = globalState.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      context.showSnackBar(message);
    }
  }

  /// 显示警告通知（顶部居中药丸形，符合 Mihom 主题风格）
  static void showWarning(String message) {
    final context = globalState.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _WarningPillToast(
        text: message,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// 显示确认对话框（需要用户确认）
  static Future<bool> showConfirm(
    String message, {
    String? title,
  }) async {
    final result = await globalState.showMessage(
      title: title ?? appLocalizations.tip,
      message: TextSpan(text: message),
      cancelable: true,
    );
    return result == true;
  }

  /// 获取 SnackBar 的 margin（适配屏幕宽度）
  static EdgeInsets _getSnackBarMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.only(bottom: 16, right: 16, left: 16);
    } else {
      return EdgeInsets.only(bottom: 16, left: 16, right: width - 316);
    }
  }
}

/// 顶部居中警告药丸（橙色主题，2.5s 自动消失）
class _WarningPillToast extends StatefulWidget {
  final String text;
  final VoidCallback onDismiss;
  const _WarningPillToast({required this.text, required this.onDismiss});

  @override
  State<_WarningPillToast> createState() => _WarningPillToastState();
}

class _WarningPillToastState extends State<_WarningPillToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 尝试获取 Mihom 主题色，fallback 到橙色
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;

    return Positioned(
      left: 0,
      right: 0,
      top: MediaQuery.of(context).padding.top + 60,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3D2E1A)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
