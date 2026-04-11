import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mihom_theme.dart';
import 'i18n.dart';

/// 移动端首次启动引导页
class MobileOnboarding extends StatefulWidget {
  final VoidCallback onComplete;
  const MobileOnboarding({super.key, required this.onComplete});

  @override
  State<MobileOnboarding> createState() => _MobileOnboardingState();
}

class _MobileOnboardingState extends State<MobileOnboarding> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < _pageCount - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = S.isEn;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: _page < _pageCount - 1
                    ? GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onComplete();
                        },
                        child: Text(
                          isEn ? 'Skip' : '跳过',
                          style: TextStyle(fontSize: 14, color: const Color(0xFF1A237E).withValues(alpha: 0.5)),
                        ),
                      )
                    : const SizedBox(height: 20),
              ),
            ),
            // 内容
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _buildWelcome(isEn),
                  _buildFeatures(isEn),
                  _buildPrivacy(isEn),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i
                      ? const Color(0xFF1A237E)
                      : const Color(0xFF1A237E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 24),
            // 按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity, height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _page == _pageCount - 1
                          ? (isEn ? 'Get Started' : '开始使用')
                          : (isEn ? 'Next' : '下一步'),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Page 1: 欢迎 ──
  Widget _buildWelcome(bool isEn) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset('lib/ui_demo/branding/icon_white.png', fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isEn ? 'Welcome to Mihom' : '欢迎使用 Mihom',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 10),
        Text(
          isEn ? 'Secure, fast, and easy proxy client' : '安全、快速、简洁的代理客户端',
          style: TextStyle(fontSize: 15, color: const Color(0xFF1A237E).withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 6),
        Text(
          isEn ? 'Let\'s set things up' : '只需几步即可完成设置',
          style: TextStyle(fontSize: 13, color: const Color(0xFF1A237E).withValues(alpha: 0.4)),
        ),
      ],
    );
  }

  // ── Page 2: 功能特性 ──
  Widget _buildFeatures(bool isEn) {
    final features = [
      (Icons.speed, isEn ? 'Smart Routing' : '智能分流', isEn ? 'Auto route traffic optimally' : '国内外流量自动分配最优线路'),
      (Icons.school, isEn ? 'Campus Mode' : '校园网模式', isEn ? 'Bypass campus firewall' : '智能绕过校园网防火墙'),
      (Icons.security, isEn ? 'Privacy First' : '隐私优先', isEn ? 'Zero-log, encrypted' : '零日志，全程加密'),
      (Icons.palette, isEn ? 'Themes' : '精美主题', isEn ? '4 themes + dark mode' : '4 款主题 + 深色模式'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEn ? 'What you get' : '核心特性',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(f.$1, color: const Color(0xFF1A237E), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                      const SizedBox(height: 2),
                      Text(f.$3, style: TextStyle(fontSize: 12, color: const Color(0xFF1A237E).withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Page 3: 隐私声明 ──
  Widget _buildPrivacy(bool isEn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Image.asset('lib/ui_demo/branding/icon_black.png', width: 32, height: 32,
              color: const Color(0xFF1A237E), colorBlendMode: BlendMode.srcIn),
          ),
          const SizedBox(height: 20),
          Text(
            isEn ? 'Your Privacy Matters' : '隐私声明',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 14),
          Text(
            isEn
                ? 'Mihom does not collect personal data.\nAll connections are encrypted.\nWe respect your privacy.'
                : 'Mihom 不收集任何个人数据。\n所有连接均采用端到端加密。\n我们尊重您的隐私权利。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: const Color(0xFF1A237E).withValues(alpha: 0.6), height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFF5C6BC0)),
                const SizedBox(width: 6),
                Text(
                  isEn ? 'By continuing you agree to our Terms' : '继续使用即表示您同意我们的服务条款',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5C6BC0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
