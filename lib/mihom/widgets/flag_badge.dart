import 'dart:io' show Platform;
import 'package:flutter/material.dart';

/// 国旗徽章 — Windows 用 PNG 图片，macOS/Linux 用 emoji
class FlagBadge extends StatelessWidget {
  final String code;
  final double size;
  const FlagBadge(this.code, {super.key, this.size = 28});

  static bool get _useEmoji => !Platform.isWindows;

  static String _countryCodeToEmoji(String code) {
    final c = code.toUpperCase();
    if (c.length != 2) return code;
    final first = c.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = c.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  Widget build(BuildContext context) {
    // Unknown country code — show a neutral globe icon instead of garbled emoji
    if (code == '--' || code.length != 2) {
      return Container(
        width: size,
        height: size * 0.72,
        decoration: BoxDecoration(
          color: const Color(0xFF607D8B),
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
        child: Center(
          child: Icon(Icons.language, color: Colors.white, size: size * 0.5),
        ),
      );
    }

    if (_useEmoji) {
      return SizedBox(
        width: size,
        height: size * 0.72,
        child: Center(
          child: Text(
            _countryCodeToEmoji(code),
            style: TextStyle(fontSize: size * 0.6, height: 1),
          ),
        ),
      );
    }

    final filename = code.toLowerCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.asset(
        'assets/flags/$filename.png',
        width: size,
        height: size * 0.72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF607D8B),
            borderRadius: BorderRadius.circular(size * 0.15),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                fontSize: size * 0.32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
