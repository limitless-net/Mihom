import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/services/storage/xboard_storage_provider.dart';
import '../theme/mihom_theme.dart';
import '../i18n.dart';
import 'pill_toast.dart';

/// 登录弹窗 — [startAsRegister] 控制初始为注册模式
/// 返回 Map<String,String>? 包含 email 和 password，或 null
Future<Map<String, String>?> showLoginDialog(BuildContext context, MihomTheme t, {
  String? hint,
  bool startAsRegister = false,
  String initialEmail = '',
  String initialPassword = '',
}) {
  return showGeneralDialog<Map<String, String>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
      scale: Curves.easeOutBack.transform(a1.value),
      child: Opacity(opacity: a1.value, child: child),
    ),
    pageBuilder: (ctx, a1, a2) => Center(
      child: Material(
        color: Colors.transparent,
        child: _LoginDialogContent(
          t: t, hint: hint, startAsRegister: startAsRegister,
          initialEmail: initialEmail, initialPassword: initialPassword,
        ),
      ),
    ),
  );
}

class _LoginDialogContent extends ConsumerStatefulWidget {
  final MihomTheme t;
  final String? hint;
  final bool startAsRegister;
  final String initialEmail;
  final String initialPassword;
  const _LoginDialogContent({
    required this.t, this.hint, this.startAsRegister = false,
    this.initialEmail = '', this.initialPassword = '',
  });

  @override
  ConsumerState<_LoginDialogContent> createState() => _LoginDialogContentState();
}

class _LoginDialogContentState extends ConsumerState<_LoginDialogContent> {
  bool _isSubmitting = false;
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _inviteCtrl = TextEditingController();
  bool _obscure = true;
  late bool _isRegister;
  bool _rememberPwd = true;
  bool _isForgotPwd = false;
  bool _isSendingCode = false;
  String? _error;
  int _countdown = 0;
  bool _codeSent = false;

  MihomTheme get t => widget.t;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.startAsRegister;
    _emailCtrl.text = widget.initialEmail;
    _pwdCtrl.text = widget.initialPassword;
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final result = await storage.getSavedCredentials();
      final data = result.dataOrNull;
      if (data != null && mounted) {
        final savedEmail = data['email'] as String?;
        final savedPassword = data['password'] as String?;
        final remember = data['rememberPassword'] as bool? ?? false;
        setState(() {
          if (_emailCtrl.text.isEmpty && savedEmail != null && savedEmail.isNotEmpty) {
            _emailCtrl.text = savedEmail;
          }
          if (_pwdCtrl.text.isEmpty && remember && savedPassword != null && savedPassword.isNotEmpty) {
            _pwdCtrl.text = savedPassword;
          }
          _rememberPwd = remember;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final storage = ref.read(storageServiceProvider);
      await storage.saveCredentials(email, password, _rememberPwd);
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _codeCtrl.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() { _countdown = 60; _codeSent = true; });
    _tick();
  }

  void _tick() {
    if (_countdown <= 0 || !mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown--);
      _tick();
    });
  }

  Future<void> _handleSendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = S.isEn ? 'Please enter a valid email' : '请输入有效的邮箱地址');
      return;
    }
    setState(() { _error = null; _isSendingCode = true; });
    HapticFeedback.lightImpact();
    try {
      final success = await ref.read(xboardUserProvider.notifier).sendVerificationCode(email);
      if (!mounted) return;
      setState(() => _isSendingCode = false);
      if (success) {
        _startCountdown();
        showPillToast(context, t, S.isEn ? 'Verification code sent' : '验证码已发送');
      } else {
        final authState = ref.read(xboardUserProvider);
        setState(() => _error = authState.errorMessage ?? (S.isEn ? 'Failed to send code' : '验证码发送失败'));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isSendingCode = false; });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text.trim();

    // ── 忘记密码模式 ──
    if (_isForgotPwd) {
      if (email.isEmpty || !email.contains('@')) {
        setState(() => _error = S.isEn ? 'Please enter a valid email' : '请输入有效的邮箱地址');
        return;
      }
      final code = _codeCtrl.text.trim();
      if (code.isEmpty) {
        setState(() => _error = S.isEn ? 'Please enter the verification code' : '请输入验证码');
        return;
      }
      if (pwd.isEmpty || pwd.length < 8) {
        setState(() => _error = S.isEn ? 'Password must be at least 8 characters' : '密码不少于8位');
        return;
      }
      setState(() { _error = null; _isSubmitting = true; });
      HapticFeedback.mediumImpact();
      try {
        final success = await ref.read(xboardUserProvider.notifier).resetPassword(email, pwd, code);
        if (!mounted) return;
        if (success) {
          showPillToast(context, t, S.isEn ? 'Password reset successful' : '密码重置成功');
          setState(() { _isForgotPwd = false; _codeCtrl.clear(); _isSubmitting = false; });
        } else {
          final authState = ref.read(xboardUserProvider);
          setState(() { _error = authState.errorMessage ?? (S.isEn ? 'Reset failed' : '重置失败'); _isSubmitting = false; });
        }
      } catch (e) {
        if (mounted) setState(() { _error = e.toString(); _isSubmitting = false; });
      }
      return;
    }

    // ── 登录/注册共用校验 ──
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = S.isEn ? 'Please enter a valid email' : '请输入有效的邮箱地址');
      return;
    }
    if (pwd.isEmpty || pwd.length < 8) {
      setState(() => _error = S.isEn ? 'Password must be at least 8 characters' : '密码不少于8位');
      return;
    }

    if (_isRegister) {
      final code = _codeCtrl.text.trim();
      if (code.isEmpty) {
        setState(() => _error = S.isEn ? 'Please enter the verification code' : '请输入验证码');
        return;
      }
      setState(() { _error = null; _isSubmitting = true; });
      HapticFeedback.mediumImpact();
      try {
        final inviteCode = _inviteCtrl.text.trim();
        final success = await ref.read(xboardUserProvider.notifier).register(
          email, pwd, inviteCode.isEmpty ? null : inviteCode, code,
        );
        if (!mounted) return;
        if (success) {
          showPillToast(context, t, S.isEn ? 'Registration successful, please login' : '注册成功，请登录');
          setState(() { _isRegister = false; _codeCtrl.clear(); _inviteCtrl.clear(); _isSubmitting = false; });
        } else {
          final authState = ref.read(xboardUserProvider);
          setState(() { _error = authState.errorMessage ?? (S.isEn ? 'Registration failed' : '注册失败'); _isSubmitting = false; });
        }
      } catch (e) {
        if (mounted) setState(() { _error = e.toString(); _isSubmitting = false; });
      }
      return;
    }

    // ── 登录 ──
    setState(() { _error = null; _isSubmitting = true; });
    HapticFeedback.mediumImpact();
    try {
      final success = await ref.read(xboardUserProvider.notifier).login(email, pwd);
      if (!mounted) return;
      if (success) {
        await _saveCredentials(email, pwd);
        Navigator.of(context).pop({'email': email, 'password': pwd});
      } else {
        final authState = ref.read(xboardUserProvider);
        setState(() { _error = authState.errorMessage ?? (S.isEn ? 'Login failed' : '登录失败'); _isSubmitting = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isForgotPwd
        ? (S.isEn ? 'Reset Password' : '重置密码')
        : (_isRegister ? S.registerMihom : S.loginMihom);

    return Container(
      width: MediaQuery.of(context).size.width > 600
          ? 380
          : MediaQuery.of(context).size.width * 0.86,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.18), blurRadius: 40)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标 — 可替换为自定义 logo
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: _isForgotPwd
                  ? const Icon(Icons.lock_reset, color: Colors.white, size: 28)
                  : const _AppLogo(size: 28),
            ),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
            if (widget.hint != null && !_isForgotPwd) ...[
              const SizedBox(height: 6),
              Text(widget.hint!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: t.textSecondary)),
            ],
            if (_isForgotPwd) ...[
              const SizedBox(height: 6),
              Text(
                S.isEn ? 'Enter your email and verification code to reset password' : '输入邮箱和验证码重置密码',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: t.textSecondary),
              ),
            ],
            const SizedBox(height: 20),

            // 错误提示
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: Colors.red))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 邮箱
            _inputField(
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              hint: S.emailAddress,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // 验证码（注册 / 忘记密码时显示）
            if (_isRegister || _isForgotPwd) ...[
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      controller: _codeCtrl,
                      icon: Icons.verified_outlined,
                      hint: S.isEn ? 'Verification code' : '验证码',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: (_countdown > 0 || _isSendingCode) ? null : _handleSendCode,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: (_countdown > 0 || _isSendingCode) ? null : t.buttonGradient,
                        color: (_countdown > 0 || _isSendingCode) ? (t.isDark ? const Color(0xFF2A2D45) : const Color(0xFFE0E0E0)) : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSendingCode
                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.textHint))
                            : Text(
                                _countdown > 0 ? '${_countdown}s' : (S.isEn ? 'Send' : '发送'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _countdown > 0 ? t.textHint : Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // 密码
            _inputField(
              controller: _pwdCtrl,
              icon: Icons.lock_outline,
              hint: _isForgotPwd ? (S.isEn ? 'New password' : '新密码') : S.password,
              obscure: _obscure,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: t.textHint),
              ),
            ),

            // 邀请码（仅注册时显示）
            if (_isRegister) ...[
              const SizedBox(height: 12),
              _inputField(
                controller: _inviteCtrl,
                icon: Icons.card_giftcard,
                hint: S.isEn ? 'Invite code (optional)' : '邀请码（选填）',
              ),
            ],

            // 登录模式：记住密码 + 忘记密码
            if (!_isRegister && !_isForgotPwd) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberPwd = !_rememberPwd),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            gradient: _rememberPwd ? t.buttonGradient : null,
                            color: _rememberPwd ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: _rememberPwd ? null : Border.all(color: t.textHint.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: _rememberPwd
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          S.isEn ? 'Remember me' : '记住密码',
                          style: TextStyle(fontSize: 12, color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isForgotPwd = true;
                        _error = null;
                        _codeCtrl.clear();
                        _pwdCtrl.clear();
                      });
                    },
                    child: Text(
                      S.isEn ? 'Forgot password?' : '忘记密码？',
                      style: TextStyle(fontSize: 12, color: t.primary),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            // 提交按钮
            GestureDetector(
              onTap: _isSubmitting ? null : _handleSubmit,
              child: Container(
                width: double.infinity, height: 48,
                decoration: BoxDecoration(
                  gradient: _isSubmitting ? null : t.buttonGradient,
                  color: _isSubmitting ? t.textHint.withValues(alpha: 0.3) : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isSubmitting ? [] : [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: _isSubmitting
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: t.textSecondary))
                    : Text(
                    _isForgotPwd
                        ? (S.isEn ? 'Reset Password' : '重置密码')
                        : (_isRegister ? S.register : S.login),
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 底部切换
            if (_isForgotPwd)
              GestureDetector(
                onTap: () => setState(() { _isForgotPwd = false; _error = null; }),
                child: Text.rich(
                  TextSpan(
                    text: S.isEn ? 'Back to ' : '返回',
                    style: TextStyle(fontSize: 13, color: t.textSecondary),
                    children: [
                      TextSpan(
                        text: S.login,
                        style: TextStyle(color: t.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() {
                  _isRegister = !_isRegister;
                  _error = null;
                  _codeCtrl.clear();
                  _inviteCtrl.clear();
                }),
                child: Text.rich(
                  TextSpan(
                    text: _isRegister ? S.hasAccount : S.noAccount,
                    style: TextStyle(fontSize: 13, color: t.textSecondary),
                    children: [
                      TextSpan(
                        text: _isRegister ? S.goLogin : S.goRegister,
                        style: TextStyle(color: t.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: t.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: t.textHint),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.all(12), child: suffix) : null,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: t.textHint.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// 应用 Logo — 替换此 widget 可自定义登录/注册页面 logo
class _AppLogo extends StatelessWidget {
  final double size;
  const _AppLogo({this.size = 28});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * 0.15),
      child: Image.asset('assets/branding/icon_white.png', fit: BoxFit.contain),
    );
  }
}
