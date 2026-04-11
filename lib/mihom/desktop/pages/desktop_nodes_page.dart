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
import '../../i18n.dart';
import '../../widgets/login_dialog.dart';
import '../../widgets/credential_store.dart';
import '../../widgets/pill_toast.dart';
import '../../widgets/flag_badge.dart';

/// 桌面端节点页 — 三列宽布局
class DesktopNodesPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  const DesktopNodesPage({super.key, required this.theme, this.isGuest = true, this.onLogin});

  @override
  ConsumerState<DesktopNodesPage> createState() => _DesktopNodesPageState();
}

class _DesktopNodesPageState extends ConsumerState<DesktopNodesPage> {
  int _selectedGroup = 0;
  int _selectedNodeIdx = 0;
  final Set<String> _testingNodes = {};
  final Map<String, String> _testResults = {};
  bool _isTestingAll = false;
  bool _didAutoTestSelected = false;
  int _sortMode = 0; // 0=默认, 1=按国家, 2=按延迟
  MihomTheme get t => widget.theme;

  // 游客节点预览数据
  List<_GuestServer> _guestServers = [];
  bool _guestLoading = false;
  bool _guestApiFailed = false;

  @override
  void initState() {
    super.initState();
    _loadGuestServersIfNeeded();
  }

  @override
  void didUpdateWidget(covariant DesktopNodesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGuest != widget.isGuest && !widget.isGuest) {
      // 登录后清空游客缓存，交给真实代理组显示
      _guestServers = [];
    }
  }

  Future<void> _loadGuestServersIfNeeded() async {
    if (_guestServers.isNotEmpty) return;
    setState(() => _guestLoading = true);
    try {
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
    } catch (_) {
      if (mounted) setState(() { _guestLoading = false; _guestApiFailed = true; });
    }
  }

  /// Build node groups from real provider data, filtered by current proxy mode
  List<_NodeGroup> _buildNodeGroups() {
    final allGroups = ref.watch(groupsProvider);
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));

    // Filter groups based on current proxy mode — only show Selector groups
    // (URLTest/Fallback are sub-groups managed by mihomo core)
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
      final emptyMsg = mode == Mode.direct
          ? (S.isEn ? 'Direct mode' : '直连模式')
          : (S.isEn ? 'No nodes' : '暂无节点');
      String emptyHint;
      if (mode == Mode.direct) {
        emptyHint = S.isEn ? 'No proxy needed in direct mode' : '直连模式无需代理';
      } else {
        final user = ref.read(userInfoProvider);
        if (user?.planId != null) {
          emptyHint = S.isEn ? 'Initializing...' : '正在初始化订阅...';
        } else {
          emptyHint = S.isEn ? 'Please purchase a plan first' : '请先购买套餐';
        }
      }
      return [_NodeGroup('--', emptyMsg, [
        _Node(emptyHint, emptyHint, 0, _S.slow, '--'),
      ])];
    }
    return groups.map((g) {
      final allGroups = ref.watch(groupsProvider);
      final nodes = g.all
          .where((p) => !_isInfoNode(p.name))
          .map((p) {
        // Check if this proxy is a sub-group (URLTest/Fallback)
        String displayName = p.name;
        String? resolvedHint;
        final subGroup = allGroups.where((sg) => sg.name == p.name).firstOrNull;
        if (subGroup != null && subGroup.type.isComputedSelected) {
          // Show sub-group's own name with resolved node as hint
          final resolvedNode = subGroup.now;
          if (resolvedNode != null && resolvedNode.isNotEmpty && !_isInfoNode(resolvedNode)) {
            resolvedHint = resolvedNode;
          } else {
            // now 解析到信息节点(剩余流量等)，取子组的第一个真实节点
            final firstReal = subGroup.all
                .where((n) => !_isInfoNode(n.name))
                .firstOrNull;
            if (firstReal != null) resolvedHint = firstReal.name;
          }
          if (resolvedHint != null) {
            displayName = '${p.name} · $resolvedHint';
          }
        }
        // Extract flag from resolved hint or node name
        final flag = _extractFlag(resolvedHint ?? p.name);
        final delay = ref.watch(getDelayProvider(proxyName: p.name, testUrl: g.testUrl));
        return _Node(p.name, displayName, delay, _delayStatus(delay), flag);
      })
          .where((n) => !_isInfoNode(n.displayName))
          .toList();
      return _NodeGroup(_extractFlag(g.name), g.name, nodes);
    }).where((g) => g.nodes.isNotEmpty).toList();
  }

  /// Whether a proxy name is a special non-connectable entry
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
        lower.contains('残余') ||
        lower.contains('官网') ||
        lower.contains('重置剩余') ||
        lower.contains('订阅链接') ||
        lower.contains('更新订阅') ||
        lower.contains('剩余') ||
        lower.contains('过期') ||
        lower.contains('到期时间') ||
        lower.contains('有效期') ||
        lower.contains('续费') ||
        lower.contains('购买') ||
        lower.contains('充值') ||
        lower.contains('邀请') ||
        lower.contains('tg群') ||
        lower.contains('telegram') ||
        lower.contains('频道') ||
        lower.contains('客服') ||
        lower.contains('公告') ||
        lower.contains('网址') ||
        lower.contains('官方') ||
        lower.contains('教程') ||
        lower.contains('使用说明') ||
        RegExp(r'\d+(\.\d+)?\s*(gb|tb|mb|pb)', caseSensitive: false).hasMatch(name) ||
        RegExp(r'\d+%').hasMatch(name);
  }

  static String _extractFlag(String name) {
    final n = name.toUpperCase();
    const map = {
      'JP': ['日本', 'JAPAN', 'JP', '东京', 'TOKYO', '大阪', 'OSAKA'],
      'US': ['美国', 'USA', 'US', '洛杉矶', 'LOS ANGELES', '纽约', 'NEW YORK', '西雅图', 'SEATTLE', 'SAN', '硅谷', '芝加哥', 'CHICAGO', '达拉斯', 'DALLAS'],
      'SG': ['新加坡', 'SINGAPORE', 'SG'],
      'HK': ['香港', 'HONG KONG', 'HK'],
      'TW': ['台湾', 'TAIWAN', 'TW'],
      'KR': ['韩国', 'KOREA', 'KR', '首尔', 'SEOUL'],
      'DE': ['德国', 'GERMANY', 'DE', '法兰克福', 'FRANKFURT'],
      'GB': ['英国', 'UK', 'GB', '伦敦', 'LONDON'],
      'FR': ['法国', 'FRANCE', 'FR', '巴黎', 'PARIS'],
      'AU': ['澳大利亚', 'AUSTRALIA', 'AU', '悉尼', 'SYDNEY'],
      'CA': ['加拿大', 'CANADA', 'CA', '多伦多', 'TORONTO', '温哥华', 'VANCOUVER'],
      'IN': ['印度', 'INDIA', 'IN', '孟买', 'MUMBAI'],
      'RU': ['俄罗斯', 'RUSSIA', 'RU', '莫斯科', 'MOSCOW'],
      'BR': ['巴西', 'BRAZIL', 'BR'],
      'MY': ['马来西亚', 'MALAYSIA', 'MY', '吉隆坡', 'KUALA LUMPUR'],
      'TH': ['泰国', 'THAILAND', 'TH', '曼谷', 'BANGKOK'],
      'VN': ['越南', 'VIETNAM', 'VN'],
      'PH': ['菲律宾', 'PHILIPPINES', 'PH'],
      'ID': ['印尼', '印度尼西亚', 'INDONESIA', 'JAKARTA'],
      'TR': ['土耳其', 'TURKEY', 'TÜRKIYE', 'TR', '伊斯坦布尔', 'ISTANBUL'],
      'NL': ['荷兰', 'NETHERLANDS', 'NL', '阿姆斯特丹', 'AMSTERDAM'],
      'IT': ['意大利', 'ITALY', 'IT', '米兰', 'MILAN'],
      'ES': ['西班牙', 'SPAIN', 'ES'],
      'AR': ['阿根廷', 'ARGENTINA', 'AR'],
      'CL': ['智利', 'CHILE', 'CL'],
      'ZA': ['南非', 'SOUTH AFRICA', 'ZA'],
      'AE': ['阿联酋', 'UAE', 'AE', '迪拜', 'DUBAI'],
      'IL': ['以色列', 'ISRAEL', 'IL'],
      'PL': ['波兰', 'POLAND', 'PL'],
      'UA': ['乌克兰', 'UKRAINE', 'UA'],
      'KZ': ['哈萨克斯坦', 'KAZAKHSTAN', 'KZ'],
      'IE': ['爱尔兰', 'IRELAND', 'IE'],
      'SE': ['瑞典', 'SWEDEN', 'SE'],
      'NO': ['挪威', 'NORWAY', 'NO'],
      'FI': ['芬兰', 'FINLAND', 'FI'],
      'CH': ['瑞士', 'SWITZERLAND', 'CH', '苏黎世', 'ZURICH'],
      'AT': ['奥地利', 'AUSTRIA', 'AT', '维也纳', 'VIENNA'],
      'MM': ['缅甸', 'MYANMAR', 'MM'],
      'KH': ['柬埔寨', 'CAMBODIA', 'KH'],
      'PK': ['巴基斯坦', 'PAKISTAN', 'PK'],
      'BD': ['孟加拉', 'BANGLADESH', 'BD'],
      'NP': ['尼泊尔', 'NEPAL', 'NP'],
      'MO': ['澳门', 'MACAU', 'MO'],
      'NG': ['尼日利亚', 'NIGERIA', 'NG'],
      'EG': ['埃及', 'EGYPT', 'EG'],
      'CO': ['哥伦比亚', 'COLOMBIA', 'CO'],
      'MX': ['墨西哥', 'MEXICO', 'MX'],
      'PE': ['秘鲁', 'PERU', 'PE'],
    };
    for (final e in map.entries) {
      if (e.value.any((k) => n.contains(k))) return e.key;
    }
    return '🌐';
  }

  /// Map delay value to status using FlClash thresholds:
  /// null = not tested, 0 = testing, <0 = timeout, <600 = fast, >=600 = medium
  static _S _delayStatus(int? delay) {
    if (delay == null || delay <= 0) return _S.slow;
    if (delay < 600) return _S.fast;
    return _S.medium;
  }

  static String _formatDelay(int? delay) {
    if (delay != null && delay > 0) return '${delay}ms';
    return S.isEn ? 'Timeout' : '超时';
  }

  Color _delayColor(int? delay) {
    if (delay == null) return t.textHint;
    if (delay < 0) return t.danger;
    if (delay == 0) return t.textHint;
    if (delay < 600) return t.success;
    return t.warning;
  }

  String _sortLabel() {
    switch (_sortMode) {
      case 1: return S.isEn ? 'Sort by Country' : '按国家排序';
      case 2: return S.isEn ? 'Sort by Delay' : '按延迟排序';
      default: return S.isEn ? 'Default Order' : '默认排序';
    }
  }

  List<_NodeGroup> _applySorting(List<_NodeGroup> groups) {
    if (_sortMode == 0) return groups;
    if (_sortMode == 1) {
      // 按国家/flag code 将所有节点合并后重新分组
      final allNodes = <_Node>[];
      for (final g in groups) allNodes.addAll(g.nodes);
      final grouped = <String, List<_Node>>{};
      for (final n in allNodes) {
        grouped.putIfAbsent(n.flag, () => []).add(n);
      }
      final sorted = grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      return sorted.map((e) => _NodeGroup(e.key, e.key, e.value)).toList();
    }
    if (_sortMode == 2) {
      // 每个组内部按延迟排序，有延迟的在前，超时/未测的在后
      return groups.map((g) {
        final sorted = List<_Node>.from(g.nodes)..sort((a, b) {
          final da = (a.delay != null && a.delay! > 0) ? a.delay! : 99999;
          final db = (b.delay != null && b.delay! > 0) ? b.delay! : 99999;
          return da.compareTo(db);
        });
        return _NodeGroup(g.code, g.title, sorted);
      }).toList();
    }
    return groups;
  }

  void _testNode(String groupName, int nodeIndex, String nodeName) {
    final key = '$groupName-$nodeName';
    if (_testingNodes.contains(key)) return;
    setState(() {
      _testingNodes.add(key);
      _testResults.remove(key);
    });
    // Real delay test via proxies_common
    final groups = ref.read(groupsProvider);
    final group = groups.where((g) => g.name == groupName).firstOrNull;
    final proxy = group?.all.where((p) => p.name == nodeName).firstOrNull;
    if (group != null && proxy != null) {
      proxies_common.proxyDelayTest(proxy, group.testUrl).then((_) {
        if (!mounted) return;
        final delay = ref.read(getDelayProvider(proxyName: proxy.name, testUrl: group.testUrl));
        setState(() {
          _testingNodes.remove(key);
          _testResults[key] = _formatDelay(delay);
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _testingNodes.remove(key);
          _testResults[key] = S.isEn ? 'Timeout' : '超时';
        });
      });
      return;
    }
    // Fallback if group/node not found
    setState(() {
      _testingNodes.remove(key);
      _testResults[key] = S.isEn ? 'Timeout' : '超时';
    });
  }

  void _testAllNodes() {
    if (_isTestingAll) return;
    final allGroups = ref.read(groupsProvider);
    final mode = ref.read(patchClashConfigProvider.select((s) => s.mode));
    final groups = switch (mode) {
      Mode.direct => <Group>[],
      Mode.global => allGroups.where((g) => g.name == GroupName.GLOBAL.name).toList(),
      Mode.rule => allGroups
          .where((g) => g.hidden == false && g.name != GroupName.GLOBAL.name)
          .where((g) => g.type == GroupType.Selector)
          .where((g) => !_isInfoNode(g.name))
          .toList(),
    };
    // Build test list with info nodes filtered out
    final testList = <(String groupName, Proxy proxy, String? testUrl)>[];
    for (final group in groups) {
      for (final proxy in group.all) {
        if (_isInfoNode(proxy.name)) continue;
        testList.add((group.name, proxy, group.testUrl));
      }
    }
    if (testList.isEmpty) return;
    final totalNodes = testList.length;
    setState(() {
      _isTestingAll = true;
      _testResults.clear();
    });
    showPillToast(context, t, S.isEn ? 'Testing $totalNodes nodes...' : '正在批量测试 $totalNodes 个节点延迟...');
    int completed = 0;
    int failed = 0;
    for (final (groupName, proxy, testUrl) in testList) {
      final key = '$groupName-${proxy.name}';
      setState(() => _testingNodes.add(key));
      proxies_common.proxyDelayTest(proxy, testUrl).then((_) {
        if (!mounted) return;
        completed++;
        final delay = ref.read(getDelayProvider(proxyName: proxy.name, testUrl: testUrl));
        if (delay == null || delay <= 0) failed++;
        setState(() {
          _testingNodes.remove(key);
          _testResults[key] = _formatDelay(delay);
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
          final msg = failed > 0
              ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '测速完成：${totalNodes - failed} 个成功，$failed 个超时')
              : (S.isEn ? 'All $totalNodes nodes tested' : '全部 $totalNodes 个节点测速完成');
          showPillToast(context, t, msg);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 有真实代理组时使用正常视图
    final realGroups = ref.watch(groupsProvider);
    if (realGroups.isNotEmpty) return _normalView();
    // 游客或无订阅 — 显示 API 服务器预览
    if (_guestLoading) {
      return Center(child: CircularProgressIndicator(color: t.primary));
    }
    if (_guestServers.isNotEmpty) return _guestPreviewView();
    // API 不可用（线上 Xboard 未适配）— 回退到登录引导卡片
    if (_guestApiFailed && widget.isGuest) return _guestView();
    return _normalView(); // fallback to empty state
  }

  /// 游客预览视图 — 从 Xboard guest API 加载的服务器列表（只读）
  Widget _guestPreviewView() {
    // 过滤掉信息节点（续费链接、官网、流量提示等），再按国旗分组
    final realServers = _guestServers.where((s) => !_isInfoNode(s.name)).toList();
    final Map<String, List<_GuestServer>> grouped = {};
    for (final s in realServers) {
      final flag = _extractFlag(s.name);
      grouped.putIfAbsent(flag, () => []).add(s);
    }
    final groups = grouped.entries.toList();

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 14, color: t.primary),
                    const SizedBox(width: 4),
                    Text(S.isEn ? 'Preview' : '预览模式',
                        style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 提示横幅
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isGuest
                        ? (S.isEn ? 'Log in and subscribe to connect to these nodes' : '登录并购买套餐后即可连接以下节点')
                        : (S.isEn ? 'Purchase a plan to connect to these nodes' : '购买套餐后即可连接以下节点'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 节点网格
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groups.map((entry) {
                  final flag = entry.key;
                  final servers = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        child: Row(
                          children: [
                            FlagBadge(flag, size: 24),
                            const SizedBox(width: 8),
                            Text(_flagToCountryName(flag), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary)),
                            const SizedBox(width: 6),
                            Text('(${servers.length})', style: TextStyle(fontSize: 12, color: t.textHint)),
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
                          itemCount: servers.length,
                          itemBuilder: (context, i) {
                            final server = servers[i];
                            return Container(
                              clipBehavior: Clip.hardEdge,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: t.cardBg,
                                borderRadius: BorderRadius.circular(t.cardRadius - 2),
                                border: t.cardBorder,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                              ),
                              child: Row(
                                children: [
                                  FlagBadge(_extractFlag(server.name), size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Tooltip(
                                          message: server.name,
                                          waitDuration: const Duration(milliseconds: 500),
                                          child: Text(server.name,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary),
                                            overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          server.rate != null ? '${server.rate}x' : '',
                                          style: TextStyle(fontSize: 11, color: t.textHint),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: server.isOnline ? const Color(0xFF4CAF50) : t.textHint,
                                    ),
                                  ),
                                ],
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

  static String _flagToCountryName(String flag) {
    const map = {
      'JP': '日本', 'US': '美国', 'SG': '新加坡', 'HK': '香港', 'TW': '台湾', 'KR': '韩国',
      'DE': '德国', 'GB': '英国', 'FR': '法国', 'AU': '澳大利亚', 'CA': '加拿大', 'IN': '印度',
      'RU': '俄罗斯', 'BR': '巴西', 'MY': '马来西亚', 'TH': '泰国', 'VN': '越南', 'PH': '菲律宾',
      'ID': '印尼', 'TR': '土耳其', 'NL': '荷兰', 'IT': '意大利', 'ES': '西班牙', 'AR': '阿根廷',
      'MX': '墨西哥', 'AE': '阿联酋', 'CH': '瑞士', 'SE': '瑞典', 'IE': '爱尔兰', 'PL': '波兰',
    };
    return map[flag] ?? flag;
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
              _headerBtn(Icons.sync, S.subscribe, () async {
                final wasConnected = ref.read(isStartProvider);
                showPillToast(context, t, S.syncingSubscriptions);
                try {
                  // 1. 刷新 XBoard 订阅信息
                  await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
                  // 2. 清除旧配置 → 下载新配置 → 应用
                  final sub = ref.read(subscriptionInfoProvider);
                  if (sub != null && sub.subscribeUrl.isNotEmpty) {
                    await ref.read(profileImportProvider.notifier).importSubscription(
                      sub.subscribeUrl,
                      forceRefresh: true,
                    );
                  } else {
                    final currentProfile = ref.read(currentProfileProvider);
                    if (currentProfile != null) {
                      await appController.updateProfile(currentProfile);
                    }
                  }
                } finally {
                  if (mounted) {
                    final msg = wasConnected
                        ? (S.isEn ? 'Subscription updated, please reconnect' : '订阅已更新，请重新连接')
                        : (S.isEn ? 'Subscription updated' : '订阅已更新');
                    showPillToast(context, t, msg);
                  }
                }
              }),
              const SizedBox(width: 8),
              _headerBtn(Icons.speed, S.speedTest, () => _testAllNodes()),
              const SizedBox(width: 8),
              _headerBtn(Icons.sort, _sortLabel(), () {
                setState(() {
                  _sortMode = (_sortMode + 1) % 3;
                });
                showPillToast(context, t, _sortLabel());
              }),
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
              child: Builder(builder: (context) {
                final nodeGroups = _applySorting(_buildNodeGroups());

                // Auto-test selected nodes that have no delay data on first render
                if (!_didAutoTestSelected) {
                  _didAutoTestSelected = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final allGroups = ref.read(groupsProvider);
                    for (final group in nodeGroups) {
                      final realGroup = allGroups.where((g) => g.name == group.title).firstOrNull;
                      if (realGroup == null) continue;
                      final selectedName = realGroup.now;
                      if (selectedName == null || selectedName.isEmpty) continue;
                      final node = group.nodes.where((n) => n.name == selectedName).firstOrNull;
                      if (node != null && (node.delay == null || node.delay! <= 0)) {
                        _testNode(group.title, 0, node.name);
                      }
                    }
                  });
                }
                // Clamp selection if groups changed (e.g. mode switch)
                if (_selectedGroup >= nodeGroups.length) {
                  _selectedGroup = 0;
                  _selectedNodeIdx = 0;
                }
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: nodeGroups.asMap().entries.map((groupEntry) {
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
                            final nodeKey = '${group.title}-${node.name}';
                            final isTesting = _testingNodes.contains(nodeKey);
                            final delayText = _testResults[nodeKey] ?? (node.delay != null && node.delay! > 0 ? '${node.delay}ms' : (S.isEn ? 'Test' : '测速'));
                            final delayColor = _delayColor(node.delay);

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedGroup = groupIdx;
                                  _selectedNodeIdx = nodeIndex;
                                });
                                // Wire to real proxy switch — use node name directly
                                final allGroups = ref.read(groupsProvider);
                                final realGroup = allGroups.where((g) => g.name == group.title).firstOrNull;
                                if (realGroup != null) {
                                  appController.changeProxy(groupName: realGroup.name, proxyName: node.name);
                                  appController.updateCurrentSelectedMap(realGroup.name, node.name);
                                  // Auto-test if no delay data
                                  if (node.delay == null || node.delay! <= 0) {
                                    _testNode(group.title, nodeIndex, node.name);
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                clipBehavior: Clip.hardEdge,
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
                                    FlagBadge(node.flag, size: 22),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Tooltip(
                                            message: node.displayName,
                                            waitDuration: const Duration(milliseconds: 500),
                                            child: Text(node.displayName,
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.white : t.textPrimary),
                                              overflow: TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(height: 2),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                _testNode(group.title, nodeIndex, node.name);
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
                                                      color: isSelected ? Colors.white70 : delayColor,
                                                      fontWeight: FontWeight.w500,
                                                      decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted,
                                                      decorationColor: (isSelected ? Colors.white70 : delayColor).withValues(alpha: 0.5))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(shape: BoxShape.circle,
                                        color: isSelected ? Colors.white : (isTesting ? t.textHint : delayColor)),
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
                );
              }),
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
  final String name;        // original proxy name (for API calls)
  final String displayName; // resolved display name (for UI)
  final int? delay;
  final _S status;
  final String flag;        // ISO country code for FlagBadge
  const _Node(this.name, this.displayName, this.delay, this.status, this.flag);
}

class _GuestServer {
  final int id;
  final String name;
  final List<String> tags;
  final double? rate;
  final bool isOnline;

  const _GuestServer({
    required this.id,
    required this.name,
    required this.tags,
    this.rate,
    this.isOnline = false,
  });

  factory _GuestServer.fromJson(Map<String, dynamic> json) {
    return _GuestServer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rate: (json['rate'] is num) ? (json['rate'] as num).toDouble() : null,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
    );
  }
}
