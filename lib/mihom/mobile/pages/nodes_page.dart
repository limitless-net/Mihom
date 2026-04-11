import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import '../../theme/mihom_theme.dart';
import '../../widgets/login_dialog.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../widgets/credential_store.dart';
import '../../widgets/flag_badge.dart';

class DemoNodesPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  final int selectedNode;
  final ValueChanged<int>? onNodeSelected;
  const DemoNodesPage({super.key, required this.theme, this.isGuest = true, this.onLogin, this.selectedNode = 0, this.onNodeSelected});

  @override
  ConsumerState<DemoNodesPage> createState() => _DemoNodesPageState();
}

class _DemoNodesPageState extends ConsumerState<DemoNodesPage> {
  final Set<String> _testingNodes = {};
  final Map<String, String> _testResults = {};
  bool _isTestingAll = false;
  bool _isSyncing = false;
  bool _didAutoTestSelected = false;
  MihomTheme get t => widget.theme;

  // Guest server preview data
  List<_GuestServer> _guestServers = [];
  bool _guestLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isGuest) _loadGuestServers();
  }

  @override
  void didUpdateWidget(covariant DemoNodesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGuest != widget.isGuest && !widget.isGuest) {
      _guestServers = [];
    }
  }

  Future<void> _loadGuestServers() async {
    if (_guestServers.isNotEmpty) return;
    setState(() => _guestLoading = true);
    try {
      if (!XBoardSDK.instance.isInitialized) {
        if (mounted) setState(() => _guestLoading = false);
        return;
      }
      final http = XBoardSDK.instance.httpService;
      final result = await http.getRequest('/api/v1/guest/server/fetch');
      final data = result['data'];
      if (data is List && mounted) {
        setState(() {
          _guestServers = data.map((e) => _GuestServer.fromJson(e as Map<String, dynamic>)).toList();
          _guestLoading = false;
        });
      } else if (mounted) {
        setState(() => _guestLoading = false);
      }
    } catch (e) {
      debugPrint('[NodesPage] Guest server fetch error: $e');
      if (mounted) setState(() => _guestLoading = false);
    }
  }

  /// Extract ISO country code from node name
  static String _extractFlag(String name) {
    final lower = name.toLowerCase();
    const map = {
      '日本': 'JP', 'japan': 'JP',
      '美国': 'US', 'usa': 'US', 'us': 'US',
      '新加坡': 'SG', 'singapore': 'SG',
      '德国': 'DE', 'germany': 'DE',
      '英国': 'GB', 'uk': 'GB',
      '韩国': 'KR', 'korea': 'KR',
      '香港': 'HK', 'hong kong': 'HK',
      '台湾': 'TW', 'taiwan': 'TW',
      '加拿大': 'CA', 'canada': 'CA',
      '澳大利亚': 'AU', 'australia': 'AU', '澳洲': 'AU',
      '法国': 'FR', 'france': 'FR',
      '印度': 'IN', 'india': 'IN',
      '俄罗斯': 'RU', 'russia': 'RU',
      '荷兰': 'NL', 'netherlands': 'NL',
      '土耳其': 'TR', 'turkey': 'TR',
      '泰国': 'TH', 'thailand': 'TH',
      '越南': 'VN', 'vietnam': 'VN',
      '马来西亚': 'MY', 'malaysia': 'MY',
    };
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '--';
  }

  /// Whether a proxy name is a special info node (not connectable)
  static bool _isInfoNode(String name) {
    final lower = name.toLowerCase();
    return lower == 'direct' ||
        lower == 'reject' ||
        lower.contains('剩余流量') ||
        lower.contains('套餐到期') ||
        lower.contains('距离下次重置') ||
        lower.contains('到期') ||
        lower.contains('expire') ||
        lower.contains('traffic') ||
        lower.contains('官网') ||
        lower.contains('订阅链接') ||
        lower.contains('更新订阅') ||
        lower.contains('剩余') ||
        lower.contains('过期') ||
        lower.contains('telegram') ||
        lower.contains('频道') ||
        lower.contains('客服') ||
        lower.contains('公告') ||
        lower.contains('教程') ||
        RegExp(r'\d+(\.\d+)?\s*(gb|tb|mb|pb)', caseSensitive: false).hasMatch(name) ||
        RegExp(r'\d+%').hasMatch(name);
  }

  /// Build node groups from real provider data, filtered by current proxy mode
  List<_NodeGroup> _buildNodeGroups() {
    final allGroups = ref.watch(groupsProvider);
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));

    final groups = switch (mode) {
      Mode.direct => <Group>[],
      Mode.global => allGroups.where((g) => g.name == GroupName.GLOBAL.name).toList(),
      Mode.rule => allGroups
          .where((g) => g.hidden == false && g.name != GroupName.GLOBAL.name)
          .where((g) => g.type == GroupType.Selector)
          .where((g) => !_isInfoNode(g.name))
          .toList(),
    };

    if (groups.isEmpty) {
      return [_NodeGroup(S.isEn ? 'No Nodes' : '暂无节点', [])];
    }

    return groups.map((g) {
      final nodes = g.all
          .where((p) => !_isInfoNode(p.name))
          .map((p) {
        final delay = ref.read(getDelayProvider(proxyName: p.name, testUrl: g.testUrl));
        return _Node(p.name, delay, g.name, g.testUrl);
      }).toList();
      return _NodeGroup(g.name, nodes);
    }).toList();
  }

  /// Get the currently selected proxy name for a group
  String? _getSelectedProxyName(String groupName) {
    return appController.getSelectedProxyName(groupName);
  }

  void _selectNode(String groupName, String nodeName) {
    HapticFeedback.lightImpact();
    appController.changeProxy(groupName: groupName, proxyName: nodeName);
    // Auto-test if no delay data
    final groups = _buildNodeGroups();
    final group = groups.where((g) => g.title == groupName).firstOrNull;
    if (group != null) {
      final node = group.nodes.where((n) => n.name == nodeName).firstOrNull;
      if (node != null && (node.delay == null || node.delay! <= 0)) {
        _testNode(groupName, nodeName, node.testUrl);
      }
    }
  }

  void _testNode(String groupName, String nodeName, String? testUrl) {
    final key = '$groupName-$nodeName';
    if (_testingNodes.contains(key)) return;
    setState(() {
      _testingNodes.add(key);
      _testResults.remove(key);
    });
    proxies_common.proxyDelayTest(
      Proxy(name: nodeName, type: ''),
      testUrl,
    ).then((_) {
      if (!mounted) return;
      final delay = ref.read(getDelayProvider(proxyName: nodeName, testUrl: testUrl));
      setState(() {
        _testingNodes.remove(key);
        if (delay == null || delay <= 0) {
          _testResults[key] = S.isEn ? 'Timeout' : '超时';
        } else {
          _testResults[key] = '${delay}ms';
        }
      });
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _testingNodes.remove(key);
          _testResults[key] = S.isEn ? 'Timeout' : '超时';
        });
      }
    });
  }

  void _testAllNodes() {
    if (_isTestingAll) return;
    final groups = _buildNodeGroups();
    int totalNodes = 0;
    for (final g in groups) totalNodes += g.nodes.length;
    if (totalNodes == 0) return;
    setState(() {
      _isTestingAll = true;
      _testResults.clear();
    });
    HapticFeedback.lightImpact();
    showPillToast(context, t, S.isEn ? 'Testing $totalNodes nodes...' : '正在批量测试 $totalNodes 个节点延迟...');

    int completed = 0;
    int failed = 0;
    for (final g in groups) {
      for (final node in g.nodes) {
        final key = '${g.title}-${node.name}';
        setState(() => _testingNodes.add(key));
        proxies_common.proxyDelayTest(
          Proxy(name: node.name, type: ''),
          node.testUrl,
        ).then((_) {
          if (!mounted) return;
          final delay = ref.read(getDelayProvider(proxyName: node.name, testUrl: node.testUrl));
          completed++;
          if (delay == null || delay <= 0) failed++;
          setState(() {
            _testingNodes.remove(key);
            _testResults[key] = (delay == null || delay <= 0)
                ? (S.isEn ? 'Timeout' : '超时')
                : '${delay}ms';
          });
          if (completed == totalNodes) {
            setState(() => _isTestingAll = false);
            final msg = failed > 0
                ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '测速完成：${totalNodes - failed} 个成功，$failed 个超时')
                : (S.isEn ? 'All $totalNodes nodes tested' : '全部 $totalNodes 个节点测速完成');
            showPillToast(context, t, msg);
          }
        }).catchError((_) {
          if (!mounted) return;
          completed++;
          failed++;
          setState(() {
            _testingNodes.remove(key);
            _testResults[key] = S.isEn ? 'Timeout' : '超时';
          });
          if (completed == totalNodes) {
            setState(() => _isTestingAll = false);
          }
        });
      }
    }
  }

  void _syncSubscription() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    HapticFeedback.lightImpact();
    try {
      // 1. Refresh XBoard subscription info to get latest subscribeUrl
      await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
      // 2. Re-import subscription (clear old config → download new → apply)
      final sub = ref.read(subscriptionInfoProvider);
      if (sub != null && sub.subscribeUrl.isNotEmpty) {
        await ref.read(profileImportProvider.notifier).importSubscription(
          sub.subscribeUrl,
          forceRefresh: true,
        );
      } else {
        // Fallback: update existing profiles directly
        await appController.updateProfiles();
        appController.applyProfileDebounce();
      }
      if (mounted) {
        setState(() {});
        showPillToast(context, t, S.isEn ? 'Subscription synced' : '订阅已同步');
      }
    } catch (_) {
      if (mounted) showPillToast(context, t, S.isEn ? 'Sync failed' : '同步失败');
    }
    if (mounted) setState(() => _isSyncing = false);
  }

  Color _delayColor(int? ms) {
    if (ms == null) return t.textHint;
    if (ms < 0) return t.danger;
    if (ms == 0) return t.textHint;
    if (ms < 600) return t.success;
    return t.warning;
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
          const SizedBox(height: 16),
          if (_guestLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_guestServers.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest server list
                    ..._guestServers.map((server) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: t.cardBg,
                          borderRadius: BorderRadius.circular(t.cardRadius - 2),
                          border: t.cardBorder,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            FlagBadge(_extractFlag(server.name), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(server.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
                                  Text(server.tags.join(' · '), style: TextStyle(fontSize: 12, color: t.textHint)),
                                ],
                              ),
                            ),
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: server.isOnline ? t.success : t.textHint.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              server.isOnline ? (S.isEn ? 'Online' : '在线') : (S.isEn ? 'Offline' : '离线'),
                              style: TextStyle(fontSize: 11, color: server.isOnline ? t.success : t.textHint, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    // Login prompt
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
            )
          else
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: t.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: t.cardBorder,
                    boxShadow: t.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.public, color: t.primary, size: 32),
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
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _normalView(BuildContext context) {
    final nodeGroups = _buildNodeGroups();

    // Auto-test selected nodes that have no delay data on first render
    if (!_didAutoTestSelected) {
      _didAutoTestSelected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final group in nodeGroups) {
          final selectedName = _getSelectedProxyName(group.title);
          if (selectedName == null) continue;
          final node = group.nodes.where((n) => n.name == selectedName).firstOrNull;
          if (node != null && (node.delay == null || node.delay! <= 0)) {
            _testNode(group.title, node.name, node.testUrl);
          }
        }
      });
    }

    return SafeArea(
      child: RefreshIndicator(
        color: t.primary,
        onRefresh: () async {
          _syncSubscription();
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
                    _headerButton(Icons.sync, S.subscribe, _isSyncing ? null : _syncSubscription, loading: _isSyncing),
                    const SizedBox(width: 8),
                    _headerButton(Icons.speed, S.speedTest, _isTestingAll ? null : _testAllNodes, loading: _isTestingAll),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Smart select banner ──
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

            // ── Node list ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, groupIndex) {
                    final group = nodeGroups[groupIndex];
                    if (group.nodes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(
                          S.isEn ? 'No nodes available' : '暂无可用节点',
                          style: TextStyle(fontSize: 14, color: t.textHint),
                        )),
                      );
                    }
                    final selectedName = _getSelectedProxyName(group.title);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text(group.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textSecondary),
                                overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 6),
                              Text('(${group.nodes.length})', style: TextStyle(fontSize: 13, color: t.textHint.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: group.nodes.length,
                          itemBuilder: (context, nodeIndex) {
                            final node = group.nodes[nodeIndex];
                            final isSelected = node.name == selectedName;
                            final key = '${group.title}-${node.name}';
                            final isTesting = _testingNodes.contains(key);
                            final testResult = _testResults[key];
                            final delayMs = node.delay;
                            final displayDelay = testResult ?? (delayMs != null && delayMs > 0 ? '${delayMs}ms' : null);
                            final isTimeout = testResult != null && (testResult == '超时' || testResult == 'Timeout');

                            // Resolve flag for sub-groups (URLTest/Fallback like 自动选择/故障转移)
                            String flagSource = node.name;
                            final allGroups = ref.read(groupsProvider);
                            final subGroup = allGroups.where((sg) => sg.name == node.name).firstOrNull;
                            if (subGroup != null && subGroup.type.isComputedSelected) {
                              String? realNode = subGroup.now;
                              if (realNode != null && realNode.isNotEmpty && !_isInfoNode(realNode)) {
                                flagSource = realNode;
                              } else {
                                final firstReal = subGroup.all.where((n) => !_isInfoNode(n.name)).firstOrNull;
                                if (firstReal != null) flagSource = firstReal.name;
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                              onTap: () => _selectNode(group.title, node.name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                    FlagBadge(_extractFlag(flagSource), size: 22),
                                    const SizedBox(width: 8),
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
                                          GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              _testNode(group.title, node.name, node.testUrl);
                                            },
                                            child: isTesting
                                                ? SizedBox(
                                                    width: 12, height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: isSelected ? Colors.white70 : t.textHint,
                                                    ),
                                                  )
                                                : Text(displayDelay ?? (S.isEn ? 'Tap to test' : '点击测速'),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isSelected ? Colors.white70
                                                          : isTimeout ? t.danger
                                                          : _delayColor(delayMs),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isTesting
                                            ? (isSelected ? Colors.white38 : t.textHint)
                                            : isTimeout
                                                ? (isSelected ? Colors.white : t.danger)
                                                : (isSelected ? Colors.white : _delayColor(delayMs)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  childCount: nodeGroups.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton(IconData icon, String label, VoidCallback? onTap, {bool loading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: loading ? 0.6 : 1.0,
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
              if (loading)
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: t.textSecondary,
                  ),
                )
              else
                Icon(icon, size: 16, color: t.textSecondary),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data models ──

class _NodeGroup {
  final String title;
  final List<_Node> nodes;
  const _NodeGroup(this.title, this.nodes);
}

class _Node {
  final String name;
  final int? delay;
  final String groupName;
  final String? testUrl;
  const _Node(this.name, this.delay, this.groupName, this.testUrl);
}

class _GuestServer {
  final String name;
  final List<String> tags;
  final bool isOnline;
  final double rate;
  _GuestServer({required this.name, required this.tags, this.isOnline = false, this.rate = 1.0});
  factory _GuestServer.fromJson(Map<String, dynamic> json) {
    final tags = <String>[];
    if (json['tags'] is List) {
      tags.addAll((json['tags'] as List).map((e) => e.toString()));
    }
    return _GuestServer(
      name: json['name']?.toString() ?? '',
      tags: tags,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      rate: (json['rate'] is num) ? (json['rate'] as num).toDouble() : 1.0,
    );
  }
}
