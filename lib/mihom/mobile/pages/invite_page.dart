import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/mihom_theme.dart';
import '../../widgets/pill_toast.dart';
import '../../i18n.dart';

/// 以居中弹窗形式打开邀请页
void showInviteDialog(BuildContext context, MihomTheme t) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
      scale: Curves.easeOutBack.transform(a1.value),
      child: Opacity(opacity: a1.value, child: child),
    ),
    pageBuilder: (ctx, a1, a2) => Center(
      child: Material(
        color: Colors.transparent,
        child: _InviteDialogContent(theme: t),
      ),
    ),
  );
}

class _InviteDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _InviteDialogContent({required this.theme});
  @override
  State<_InviteDialogContent> createState() => _InviteDialogContentState();
}

class _InviteDialogContentState extends State<_InviteDialogContent> {
  MihomTheme get t => widget.theme;

  bool _loading = true;
  String? _error;
  List<InviteCodeModel> _codes = [];
  int _totalInvites = 0;
  double _totalCommissionYuan = 0;
  int _commissionRate = 0;
  double _pendingYuan = 0;
  bool _transferring = false;
  bool _generating = false;

  // 提现配置
  List<String> _withdrawMethods = [];
  bool _withdrawClosed = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        XBoardSDK.instance.invite.getInviteInfo(),
        XBoardSDK.instance.httpService.getRequest('/api/v1/user/comm/config').catchError((_) => <String, dynamic>{}),
      ]);
      final info = results[0] as InviteInfoModel;
      final commConfig = results[1] as Map<String, dynamic>;
      final commData = commConfig['data'] as Map<String, dynamic>? ?? commConfig;
      if (!mounted) return;
      setState(() {
        _codes = info.codes;
        _totalInvites = info.totalInvites;
        _totalCommissionYuan = info.totalCommission / 100.0;
        _commissionRate = info.commissionRate;
        _pendingYuan = info.pendingCommission / 100.0;
        _withdrawClosed = (commData['withdraw_close'] ?? 1) == 1;
        final methods = commData['withdraw_methods'];
        if (methods is List) {
          _withdrawMethods = methods.map((e) => e.toString()).toList();
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _handleGenerate() async {
    setState(() => _generating = true);
    try {
      await XBoardSDK.instance.invite.generateInviteCode();
      await _loadData();
      if (mounted) showPillToast(context, t, S.isEn ? 'Invite code generated' : '邀请码已生成');
    } catch (e) {
      if (mounted) showPillToast(context, t, e is XBoardException ? e.message : '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _handleTransfer() async {
    if (_pendingYuan <= 0) {
      showPillToast(context, t, S.isEn ? 'No commission to transfer' : '暂无可划转佣金');
      return;
    }
    setState(() => _transferring = true);
    try {
      await XBoardSDK.instance.invite.transferCommissionToBalance(_pendingYuan * 100);
      await _loadData();
      if (mounted) showPillToast(context, t, S.isEn ? 'Transferred to balance' : '已划转到余额');
    } catch (e) {
      if (mounted) showPillToast(context, t, S.isEn ? 'Transfer failed' : '划转失败');
    } finally {
      if (mounted) setState(() => _transferring = false);
    }
  }

  void _showWithdrawDialog() {
    if (_pendingYuan <= 0) {
      showPillToast(context, t, S.isEn ? 'No commission to withdraw' : '暂无可提现佣金');
      return;
    }
    String? selectedMethod = _withdrawMethods.isNotEmpty ? _withdrawMethods.first : null;
    final accountCtrl = TextEditingController();
    bool submitting = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (ctx2, setDialogState) {
              return Container(
                width: MediaQuery.of(ctx2).size.width * 0.85,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.isEn ? 'Withdraw Commission' : '佣金提现', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 4),
                    Text(S.isEn ? 'Available: ¥${_pendingYuan.toStringAsFixed(2)}' : '可提现: ¥${_pendingYuan.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    const SizedBox(height: 16),
                    // 提现方式选择
                    Align(alignment: Alignment.centerLeft,
                      child: Text(S.isEn ? 'Withdraw Method' : '提现方式', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _withdrawMethods.map((m) {
                        final sel = m == selectedMethod;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedMethod = m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? t.primary.withValues(alpha: 0.1) : (t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA)),
                              borderRadius: BorderRadius.circular(8),
                              border: sel ? Border.all(color: t.primary.withValues(alpha: 0.5)) : null,
                            ),
                            child: Text(m, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? t.primary : t.textPrimary)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    // 提现账号
                    Align(alignment: Alignment.centerLeft,
                      child: Text(S.isEn ? 'Withdraw Account' : '提现账号', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary))),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: accountCtrl,
                        style: TextStyle(fontSize: 13, color: t.textPrimary),
                        decoration: InputDecoration(
                          hintText: S.isEn ? 'Enter your account' : '请输入提现账号',
                          hintStyle: TextStyle(fontSize: 12, color: t.textHint),
                          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: submitting ? null : () async {
                        if (selectedMethod == null) {
                          showPillToast(context, t, S.isEn ? 'Select a method' : '请选择提现方式');
                          return;
                        }
                        if (accountCtrl.text.trim().isEmpty) {
                          showPillToast(context, t, S.isEn ? 'Enter account' : '请输入提现账号');
                          return;
                        }
                        setDialogState(() => submitting = true);
                        try {
                          final http = XBoardSDK.instance.httpService;
                          await http.postRequest('/api/v1/user/ticket/withdraw', {
                            'withdraw_method': selectedMethod,
                            'withdraw_account': accountCtrl.text.trim(),
                          });
                          if (ctx2.mounted) Navigator.of(ctx2).pop();
                          if (mounted) {
                            showPillToast(context, t, S.isEn ? 'Withdrawal request submitted' : '提现申请已提交');
                            _loadData();
                          }
                        } catch (e) {
                          if (ctx2.mounted) showPillToast(ctx2, t, e is XBoardException ? e.message : e.toString());
                          setDialogState(() => submitting = false);
                        }
                      },
                      child: Container(
                        width: double.infinity, height: 44,
                        decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(S.isEn ? 'Submit Withdrawal' : '提交提现', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String get _displayCode {
    final active = _codes.where((c) => c.isActive).toList();
    if (active.isNotEmpty) return active.first.code;
    if (_codes.isNotEmpty) return _codes.first.code;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw * 0.9,
      constraints: BoxConstraints(maxHeight: sh * 0.85),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.people, color: t.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.inviteFriends, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      S.isEn ? 'Earn $_commissionRate% commission' : '邀请返佣 $_commissionRate%',
                      style: TextStyle(fontSize: 12, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.close, color: t.textHint, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: t.danger, size: 32),
                  const SizedBox(height: 8),
                  Text(S.isEn ? 'Failed to load' : '加载失败', style: TextStyle(color: t.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _loadData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(8)),
                      child: Text(S.isEn ? 'Retry' : '重试', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── 统计 ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stat(S.isEn ? 'Invited' : '已邀请', '$_totalInvites'),
                        _divider(),
                        _stat(S.isEn ? 'Commission' : '累计佣金', '¥${_totalCommissionYuan.toStringAsFixed(2)}'),
                        _divider(),
                        _stat(S.isEn ? 'Rate' : '返利比例', '$_commissionRate%'),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 待划转佣金 + 提现/划转 ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.isEn ? 'Pending' : '待划转', style: TextStyle(fontSize: 10, color: t.textHint)),
                              const SizedBox(height: 2),
                              Text('¥${_pendingYuan.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.primary)),
                            ],
                          ),
                          const Spacer(),
                          // 提现按钮
                          if (!_withdrawClosed && _withdrawMethods.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: _showWithdrawDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(S.isEn ? 'Withdraw' : '提现', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                                ),
                              ),
                            ),
                          // 划转到余额
                          GestureDetector(
                            onTap: _transferring ? null : _handleTransfer,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(8)),
                              child: _transferring
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(S.isEn ? 'To Balance' : '划转到余额', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 邀请二维码 ──
                    if (_displayCode.isNotEmpty) ...[
                      Builder(builder: (_) {
                        final baseUrl = XBoardSDK.instance.baseUrl ?? '';
                        final inviteUrl = baseUrl.isNotEmpty ? '$baseUrl/#/register?code=$_displayCode' : _displayCode;
                        return Column(
                          children: [
                            Container(
                              width: 150, height: 150,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.textHint.withValues(alpha: 0.12)),
                              ),
                              child: QrImageView(
                                data: inviteUrl,
                                version: QrVersions.auto,
                                size: 134,
                                eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: t.primary),
                                dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: t.primary),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(S.isEn ? 'Scan to register' : '扫码注册', style: TextStyle(fontSize: 11, color: t.textHint)),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: inviteUrl));
                                    showPillToast(context, t, S.isEn ? 'Invite link copied' : '邀请链接已复制');
                                  },
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.link, size: 14, color: t.primary),
                                    const SizedBox(width: 3),
                                    Text(S.isEn ? 'Copy Link' : '复制链接', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 14),
                    ],

                    // ── 邀请码 ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(S.myInviteCode, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textSecondary)),
                              const Spacer(),
                              GestureDetector(
                                onTap: _generating ? null : _handleGenerate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: _generating
                                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                                      : Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.add, color: t.primary, size: 12),
                                          const SizedBox(width: 2),
                                          Text(S.isEn ? 'Generate' : '生成', style: TextStyle(fontSize: 11, color: t.primary, fontWeight: FontWeight.w600)),
                                        ]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_codes.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text(S.isEn ? 'No invite codes yet' : '暂无邀请码', style: TextStyle(fontSize: 12, color: t.textHint))),
                            )
                          else
                            ..._codes.map((code) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: t.cardBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: code.isActive ? t.primary.withValues(alpha: 0.2) : t.textHint.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(code.code, style: TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.bold,
                                            color: code.isActive ? t.primary : t.textHint,
                                            letterSpacing: 1.5,
                                          )),
                                          Text(
                                            code.isActive ? (S.isEn ? 'Available' : '可用') : (S.isEn ? 'Used' : '已使用'),
                                            style: TextStyle(fontSize: 10, color: code.isActive ? t.success : t.textHint),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (code.isActive)
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Clipboard.setData(ClipboardData(text: code.code));
                                          showPillToast(context, t, S.inviteCodeCopied);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Icon(Icons.copy, color: t.primary, size: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.primary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: t.textSecondary)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 24, color: t.textHint.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 16));
  }
}
