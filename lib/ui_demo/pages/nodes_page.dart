import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../mihom_theme.dart';
import '../login_dialog.dart';
import '../i18n.dart';
import '../pill_toast.dart';
import '../credential_store.dart';

class DemoNodesPage extends StatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  final int selectedNode;
  final ValueChanged<int>? onNodeSelected;
  const DemoNodesPage({super.key, required this.theme, this.isGuest = true, this.onLogin, this.selectedNode = 0, this.onNodeSelected});

  @override
  State<DemoNodesPage> createState() => _DemoNodesPageState();
}

class _DemoNodesPageState extends State<DemoNodesPage> {
  int get _selectedNode => widget.selectedNode;
  final Set<String> _testingNodes = {};
  final Map<String, String> _testResults = {};
  bool _isTestingAll = false;
  MihomTheme get t => widget.theme;

  void _testNode(int groupIdx, int nodeIdx, String nodeName) {
    final key = '$groupIdx-$nodeIdx';
    if (_testingNodes.contains(key)) return;
    setState(() {
      _testingNodes.add(key);
      _testResults.remove(key);
    });
    final rng = Random();
    final ms = 800 + rng.nextInt(1700);
    final isTimeout = rng.nextDouble() < 0.2;
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() {
          _testingNodes.remove(key);
          if (isTimeout) {
            _testResults[key] = S.isEn ? 'Timeout' : '\u8d85\u65f6';
          } else {
            final newDelay = 20 + rng.nextInt(300);
            _testResults[key] = '${newDelay}ms';
          }
        });
      }
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
    HapticFeedback.lightImpact();
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
                ? (S.isEn ? 'Timeout' : '\u8d85\u65f6')
                : '${20 + rng.nextInt(300)}ms';
          });
          if (completed == totalNodes) {
            setState(() => _isTestingAll = false);
            final msg = failed > 0
                ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '\u6d4b\u901f\u5b8c\u6210\uff1a${totalNodes - failed} \u4e2a\u6210\u529f\uff0c$failed \u4e2a\u8d85\u65f6')
                : (S.isEn ? 'All $totalNodes nodes tested' : '\u5168\u90e8 $totalNodes \u4e2a\u8282\u70b9\u6d4b\u901f\u5b8c\u6210');
            showPillToast(context, t, msg);
          }
        });
      }
    }
  }

  List<_NodeGroup> get _nodeGroups => [
    _NodeGroup(S.isEn ? '🇯🇵 Japan' : '🇯🇵 日本', [
      _Node(S.isEn ? 'Tokyo 01' : '东京 01', 23, _S.fast),
      _Node(S.isEn ? 'Tokyo 02' : '东京 02', 45, _S.fast),
      _Node(S.isEn ? 'Osaka 01' : '大阪 01', 89, _S.medium),
      _Node(S.isEn ? 'Osaka 02' : '大阪 02', 112, _S.medium),
    ]),
    _NodeGroup(S.isEn ? '🇺🇸 USA' : '🇺🇸 美国', [
      _Node(S.isEn ? 'Los Angeles' : '洛杉矶', 120, _S.medium),
      _Node(S.isEn ? 'New York' : '纽约', 180, _S.medium),
      _Node(S.isEn ? 'Seattle' : '西雅图', 320, _S.slow),
    ]),
    _NodeGroup(S.isEn ? '🇸🇬 Singapore' : '🇸🇬 新加坡', [
      _Node(S.isEn ? 'Singapore 01' : '新加坡 01', 65, _S.fast),
      _Node(S.isEn ? 'Singapore 02' : '新加坡 02', 98, _S.medium),
    ]),
    _NodeGroup(S.isEn ? '🇩🇪 Germany' : '🇩🇪 德国', [
      _Node(S.isEn ? 'Frankfurt' : '法兰克福', 200, _S.medium),
    ]),
  ];

  Color _statusColor(_S s) {
    switch (s) {
      case _S.fast: return t.success;
      case _S.medium: return t.warning;
      case _S.slow: return t.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) return _guestView(context);
    return _normalView(context);
  }

  Widget _guestView(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Text(S.selectNode, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: t.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
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
                    HapticFeedback.mediumImpact();
                    showLoginDialog(context, t, hint: S.loginToViewNodesHint,
                      initialEmail: SavedCredentials.email,
                      initialPassword: SavedCredentials.password,
                    ).then((result) {
                      if (result != null) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        widget.onLogin?.call();
                      }
                    });
                  },
                  child: Container(
                    width: double.infinity, height: 46,
                    decoration: BoxDecoration(
                      gradient: t.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(S.loginOrRegister, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _normalView(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: t.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) showPillToast(context, t, S.nodeListUpdated);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(child: Text(S.selectNode, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary))),
                    _headerButton(Icons.sync, S.subscribe, () {
                      HapticFeedback.lightImpact();
                      showPillToast(context, t, S.syncingSubscriptions);
                    }),
                    const SizedBox(width: 8),
                    _headerButton(Icons.speed, S.speedTest, () {
                      HapticFeedback.lightImpact();
                      _testAllNodes();
                    }),
                    const SizedBox(width: 8),
                    _headerButton(Icons.sort, S.sort, () {
                      HapticFeedback.lightImpact();
                      showPillToast(context, t, S.sortedByLatency);
                    }),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 智能横幅 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.smartSelect, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(S.smartSelectDesc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 节点列表 ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, groupIndex) {
                    final group = _nodeGroups[groupIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            children: [
                              Text(group.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textSecondary)),
                              const SizedBox(width: 6),
                              Text('(${group.nodes.length})', style: TextStyle(fontSize: 13, color: t.textHint.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
                          ),
                          itemCount: group.nodes.length,
                          itemBuilder: (context, nodeIndex) {
                            final node = group.nodes[nodeIndex];
                            int gi = 0;
                            for (int g = 0; g < groupIndex; g++) gi += _nodeGroups[g].nodes.length;
                            gi += nodeIndex;
                            final isSelected = _selectedNode == gi;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onNodeSelected?.call(gi);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? null : t.cardBg,
                                  gradient: isSelected ? t.nodeSelectedGradient : null,
                                  borderRadius: BorderRadius.circular(t.cardRadius - 2),
                                  border: !isSelected ? t.cardBorder : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isSelected ? t.primary : (t.isDark ? Colors.black : Colors.black))
                                          .withValues(alpha: isSelected ? 0.2 : 0.04),
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
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : t.textPrimary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Builder(builder: (_) {
                                            final nodeKey = '$groupIndex-$nodeIndex';
                                            final isTesting = _testingNodes.contains(nodeKey);
                                            final result = _testResults[nodeKey];
                                            final isTimeout = result != null && (result == '超时' || result == 'Timeout');
                                            final delayText = result ?? '${node.delay}ms';
                                            final txtColor = isSelected ? Colors.white70
                                                : isTimeout ? t.danger : _statusColor(node.status);
                                            return GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                _testNode(groupIndex, nodeIndex, node.name);
                                              },
                                              child: isTesting
                                                  ? SizedBox(
                                                      width: 12, height: 12,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 1.5,
                                                        color: isSelected ? Colors.white70 : t.textHint,
                                                      ),
                                                    )
                                                  : Text(delayText,
                                                      style: TextStyle(fontSize: 12, color: txtColor, fontWeight: FontWeight.w500),
                                                    ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    Builder(builder: (_) {
                                      final nodeKey = '$groupIndex-$nodeIndex';
                                      final isTesting = _testingNodes.contains(nodeKey);
                                      final result = _testResults[nodeKey];
                                      final isTimeout = result != null && (result == '超时' || result == 'Timeout');
                                      final dotColor = isTesting
                                          ? (isSelected ? Colors.white38 : t.textHint)
                                          : isTimeout
                                              ? (isSelected ? Colors.white : t.danger)
                                              : (isSelected ? Colors.white : _statusColor(node.status));
                                      return Container(
                                        width: 8, height: 8,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  childCount: _nodeGroups.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: t.cardBorder,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: t.textSecondary),
            const SizedBox(width: 4),
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
  final String title;
  final List<_Node> nodes;
  const _NodeGroup(this.title, this.nodes);
}

class _Node {
  final String name;
  final int delay;
  final _S status;
  const _Node(this.name, this.delay, this.status);
}
