import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../mihom_theme.dart';
import '../../i18n.dart';
import '../../login_dialog.dart';
import '../../credential_store.dart';
import '../../pill_toast.dart';
import '../../flag_badge.dart';

/// 桌面端节点页 — 三列宽布局
class DesktopNodesPage extends StatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  const DesktopNodesPage({super.key, required this.theme, this.isGuest = true, this.onLogin});

  @override
  State<DesktopNodesPage> createState() => _DesktopNodesPageState();
}

class _DesktopNodesPageState extends State<DesktopNodesPage> {
  int _selectedGroup = 0;
  int _selectedNodeIdx = 0;
  // 测速状态: key = 'groupIdx-nodeIdx'
  final Set<String> _testingNodes = {};
  // 测速结果覆盖: key -> delay string
  final Map<String, String> _testResults = {};
  bool _isTestingAll = false;
  MihomTheme get t => widget.theme;

  List<_NodeGroup> get _nodeGroups => [
    _NodeGroup('JP', S.isEn ? 'Japan' : '日本', [
      _Node(S.isEn ? 'Tokyo 01' : '东京 01', 23, _S.fast),
      _Node(S.isEn ? 'Tokyo 02' : '东京 02', 45, _S.fast),
      _Node(S.isEn ? 'Osaka 01' : '大阪 01', 89, _S.medium),
      _Node(S.isEn ? 'Osaka 02' : '大阪 02', 112, _S.medium),
    ]),
    _NodeGroup('US', S.isEn ? 'USA' : '美国', [
      _Node(S.isEn ? 'Los Angeles' : '洛杉矶', 120, _S.medium),
      _Node(S.isEn ? 'New York' : '纽约', 180, _S.medium),
      _Node(S.isEn ? 'Seattle' : '西雅图', 320, _S.slow),
    ]),
    _NodeGroup('SG', S.isEn ? 'Singapore' : '新加坡', [
      _Node(S.isEn ? 'Singapore 01' : '新加坡 01', 65, _S.fast),
      _Node(S.isEn ? 'Singapore 02' : '新加坡 02', 98, _S.medium),
    ]),
    _NodeGroup('DE', S.isEn ? 'Germany' : '德国', [
      _Node(S.isEn ? 'Frankfurt' : '法兰克福', 200, _S.medium),
    ]),
    _NodeGroup('GB', S.isEn ? 'UK' : '英国', [
      _Node(S.isEn ? 'London' : '伦敦', 210, _S.medium),
    ]),
    _NodeGroup('KR', S.isEn ? 'Korea' : '韩国', [
      _Node(S.isEn ? 'Seoul 01' : '首尔 01', 35, _S.fast),
      _Node(S.isEn ? 'Seoul 02' : '首尔 02', 52, _S.fast),
    ]),
  ];

  Color _statusColor(_S s) {
    switch (s) {
      case _S.fast: return t.success;
      case _S.medium: return t.warning;
      case _S.slow: return t.danger;
    }
  }

  void _testNode(int groupIdx, int nodeIndex, String nodeName) {
    final key = '$groupIdx-$nodeIndex';
    if (_testingNodes.contains(key)) return;
    setState(() {
      _testingNodes.add(key);
      _testResults.remove(key);
    });
    final rng = Random();
    final duration = Duration(milliseconds: 800 + rng.nextInt(1700));
    Future.delayed(duration, () {
      if (!mounted) return;
      final timeout = rng.nextDouble() < 0.2;
      final newDelay = timeout ? null : (15 + rng.nextInt(350));
      setState(() {
        _testingNodes.remove(key);
        _testResults[key] = timeout ? (S.isEn ? 'Timeout' : '超时') : '${newDelay}ms';
      });
    });
  }

  void _testAllNodes() {
    if (_isTestingAll) return;
    final groups = _nodeGroups;
    int totalNodes = 0;
    for (final g in groups) totalNodes += g.nodes.length;
    setState(() {
      _isTestingAll = true;
      _testResults.clear();
    });
    showPillToast(context, t, S.isEn ? 'Testing $totalNodes nodes...' : '正在批量测试 $totalNodes 个节点延迟...');
    final rng = Random();
    int completed = 0;
    int failed = 0;
    for (int gi = 0; gi < groups.length; gi++) {
      for (int ni = 0; ni < groups[gi].nodes.length; ni++) {
        final key = '$gi-$ni';
        setState(() => _testingNodes.add(key));
        final ms = 800 + rng.nextInt(2200);
        final isTimeout = rng.nextDouble() < 0.15;
        Future.delayed(Duration(milliseconds: ms), () {
          if (!mounted) return;
          completed++;
          if (isTimeout) failed++;
          setState(() {
            _testingNodes.remove(key);
            _testResults[key] = isTimeout
                ? (S.isEn ? 'Timeout' : '超时')
                : '${20 + rng.nextInt(300)}ms';
          });
          if (completed == totalNodes) {
            setState(() => _isTestingAll = false);
            final msg = failed > 0
                ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '测速完成：${totalNodes - failed} 个成功，$failed 个超时')
                : (S.isEn ? 'All $totalNodes nodes tested' : '全部 $totalNodes 个节点测速完成');
            showPillToast(context, t, msg);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) return _guestView();
    return _normalView();
  }

  Widget _guestView() {
    return Center(
      child: Container(
        width: 380, padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: t.cardBg, borderRadius: BorderRadius.circular(24),
          border: t.cardBorder, boxShadow: t.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.lock_outline, color: t.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(S.loginToViewNodes, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
            const SizedBox(height: 8),
            Text(S.loginToViewNodesDesc, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showLoginDialog(context, t, hint: S.loginToViewNodesHint,
                  initialEmail: SavedCredentials.email, initialPassword: SavedCredentials.password,
                ).then((result) {
                  if (result != null) {
                    SavedCredentials.email = result['email'] ?? '';
                    SavedCredentials.password = result['password'] ?? '';
                    widget.onLogin?.call();
                  }
                });
              },
              child: Container(
                width: double.infinity, height: 44,
                decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(S.loginOrRegister, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _normalView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(S.selectNode, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
              const Spacer(),
              _headerBtn(Icons.sync, S.subscribe, () => showPillToast(context, t, S.syncingSubscriptions)),
              const SizedBox(width: 8),
              _headerBtn(Icons.speed, S.speedTest, () => _testAllNodes()),
              const SizedBox(width: 8),
              _headerBtn(Icons.sort, S.sort, () => showPillToast(context, t, S.sortedByLatency)),
            ],
          ),
          const SizedBox(height: 16),

          // 智能选择横幅
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.smartSelect, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(S.smartSelectDesc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 节点列表 — 桌面端用三列以上 grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _nodeGroups.asMap().entries.map((groupEntry) {
                  final groupIdx = groupEntry.key;
                  final group = groupEntry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        child: Row(
                          children: [
                            FlagBadge(group.code, size: 24),
                            const SizedBox(width: 8),
                            Text(group.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary)),
                            const SizedBox(width: 6),
                            Text('(${group.nodes.length})', style: TextStyle(fontSize: 12, color: t.textHint)),
                          ],
                        ),
                      ),
                      LayoutBuilder(builder: (ctx, constraints) {
                        final cols = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.0,
                          ),
                          itemCount: group.nodes.length,
                          itemBuilder: (context, nodeIndex) {
                            final node = group.nodes[nodeIndex];
                            final isSelected = _selectedGroup == groupIdx && _selectedNodeIdx == nodeIndex;
                            final nodeKey = '$groupIdx-$nodeIndex';
                            final isTesting = _testingNodes.contains(nodeKey);
                            final delayText = _testResults[nodeKey] ?? '${node.delay}ms';
                            final isTimeout = delayText == (S.isEn ? 'Timeout' : '超时');

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedGroup = groupIdx;
                                  _selectedNodeIdx = nodeIndex;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? null : t.cardBg,
                                  gradient: isSelected ? t.nodeSelectedGradient : null,
                                  borderRadius: BorderRadius.circular(t.cardRadius - 2),
                                  border: !isSelected ? t.cardBorder : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isSelected ? t.primary : Colors.black).withValues(alpha: isSelected ? 0.2 : 0.04),
                                      blurRadius: isSelected ? 15 : 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(node.name,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white : t.textPrimary),
                                            overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                _testNode(groupIdx, nodeIndex, node.name);
                                              },
                                              child: isTesting
                                                ? SizedBox(
                                                    width: 12, height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: isSelected ? Colors.white70 : t.primary,
                                                    ),
                                                  )
                                                : Text(delayText,
                                                    style: TextStyle(fontSize: 11,
                                                      color: isSelected ? Colors.white70 : (isTimeout ? t.danger : _statusColor(node.status)),
                                                      fontWeight: FontWeight.w500,
                                                      decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted,
                                                      decorationColor: (isSelected ? Colors.white70 : _statusColor(node.status)).withValues(alpha: 0.5))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(shape: BoxShape.circle,
                                        color: isSelected ? Colors.white : (isTesting ? t.textHint : (isTimeout ? t.danger : _statusColor(node.status)))),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: t.cardBg, borderRadius: BorderRadius.circular(10),
          border: t.cardBorder, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: t.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── 数据模型 ──
enum _S { fast, medium, slow }

class _NodeGroup {
  final String code;
  final String title;
  final List<_Node> nodes;
  const _NodeGroup(this.code, this.title, this.nodes);
}

class _Node {
  final String name;
  final int delay;
  final _S status;
  const _Node(this.name, this.delay, this.status);
}
