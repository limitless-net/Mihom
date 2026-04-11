import 'package:flutter/material.dart';
import 'package:fl_clash/common/constant.dart' show appName;
import '../theme/mihom_theme.dart';
import '../i18n.dart';

/// 桌面端首次启动引导页
class DesktopOnboarding extends StatefulWidget {
  final VoidCallback onComplete;
  const DesktopOnboarding({super.key, required this.onComplete});

  @override
  State<DesktopOnboarding> createState() => _DesktopOnboardingState();
}

class _DesktopOnboardingState extends State<DesktopOnboarding> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
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
      body: Stack(
        children: [
          // 背景装饰
          Positioned(top: -80, right: -80, child: _decorCircle(200, 0.06)),
          Positioned(bottom: -60, left: -60, child: _decorCircle(160, 0.04)),
          Positioned(top: 100, left: 40, child: _decorCircle(80, 0.03)),
          // 内容
          Center(
            child: SizedBox(
              width: 600,
              height: 480,
              child: Column(
                children: [
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
                  const SizedBox(height: 24),
                  // 指示器 + 按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 页面指示器
                      for (int i = 0; i < _pageCount; i++) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _page == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _page == i
                                ? const Color(0xFF1A237E)
                                : const Color(0xFF1A237E).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (i < _pageCount - 1) const SizedBox(width: 6),
                      ],
                      const SizedBox(width: 40),
                      // 下一步 / 开始
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: Text(
                              _page == _pageCount - 1
                                  ? (isEn ? 'Get Started' : '开始使用')
                                  : (isEn ? 'Next' : '下一步'),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 跳过
                  if (_page < _pageCount - 1)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onComplete,
                        child: Text(
                          isEn ? 'Skip' : '跳过',
                          style: TextStyle(fontSize: 13, color: const Color(0xFF1A237E).withValues(alpha: 0.5)),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 17),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double alpha) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A237E).withValues(alpha: alpha),
      ),
    );
  }

  // ── Page 1: 欢迎 ──
  Widget _buildWelcome(bool isEn) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 应用图标
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/branding/icon_white.png', fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          isEn ? 'Welcome to $appName' : '欢迎使用 $appName',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 12),
        Text(
          isEn ? 'Secure, fast, and easy proxy client' : '安全、快速、简洁的代理客户端',
          style: TextStyle(fontSize: 16, color: const Color(0xFF1A237E).withValues(alpha: 0.6), height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          isEn ? 'Let\'s set things up in a few steps' : '只需几步即可完成设置',
          style: TextStyle(fontSize: 14, color: const Color(0xFF1A237E).withValues(alpha: 0.4)),
        ),
      ],
    );
  }

  // ── Page 2: 功能特性 ──
  Widget _buildFeatures(bool isEn) {
    final features = [
      (Icons.speed, isEn ? 'Smart Routing' : '智能分流', isEn ? 'Auto route domestic & foreign traffic' : '国内外流量自动分配最优线路'),
      (Icons.school, isEn ? 'Campus Mode' : '校园网模式', isEn ? 'Bypass campus firewall smartly' : '智能绕过校园网防火墙限制'),
      (Icons.security, isEn ? 'Privacy First' : '隐私优先', isEn ? 'Zero-log, encrypted connections' : '零日志，全程加密传输'),
      (Icons.palette, isEn ? 'Beautiful Themes' : '精美主题', isEn ? '4 built-in themes, dark mode' : '4 款内置主题，支持深色模式'),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEn ? 'What you get' : '核心特性',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 28),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(f.$1, color: const Color(0xFF1A237E), size: 22),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                    const SizedBox(height: 2),
                    Text(f.$3, style: TextStyle(fontSize: 13, color: const Color(0xFF1A237E).withValues(alpha: 0.55))),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Page 3: 隐私声明 ──
  Widget _buildPrivacy(bool isEn) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/branding/icon_black.png', width: 36, height: 36,
            color: const Color(0xFF1A237E), colorBlendMode: BlendMode.srcIn),
        ),
        const SizedBox(height: 24),
        Text(
          isEn ? 'Your Privacy Matters' : '隐私声明',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 400,
          child: Text(
            isEn
                ? '$appName does not collect personal data.\nAll connections are encrypted end-to-end.\nWe respect your right to privacy.'
                : '$appName 不收集任何个人数据。\n所有连接均采用端到端加密传输。\n我们尊重您的隐私权利。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: const Color(0xFF1A237E).withValues(alpha: 0.6), height: 1.6),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Text(
                isEn ? 'By continuing you agree to our Terms of Service' : '继续使用即表示您同意我们的服务条款',
                style: const TextStyle(fontSize: 12, color: Color(0xFF5C6BC0)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
