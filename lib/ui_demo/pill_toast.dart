import 'package:flutter/material.dart';
import 'mihom_theme.dart';

/// 居中药丸形提示 — 替代 SnackBar
void showPillToast(BuildContext context, MihomTheme t, String text) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _PillToast(
      theme: t,
      text: text,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _PillToast extends StatefulWidget {
  final MihomTheme theme;
  final String text;
  final VoidCallback onDismiss;
  const _PillToast({required this.theme, required this.text, required this.onDismiss});

  @override
  State<_PillToast> createState() => _PillToastState();
}

class _PillToastState extends State<_PillToast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1800), _dismiss);
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
    final t = widget.theme;
    return Positioned(
      left: 0, right: 0,
      top: MediaQuery.of(context).padding.top + 60,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF2A2D50) : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: t.cardBorder,
                  boxShadow: [
                    BoxShadow(
                      color: t.primary.withValues(alpha: 0.15),
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
                    Icon(Icons.info_outline, size: 16, color: t.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary),
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
