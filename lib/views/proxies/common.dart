import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight + 2;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 6,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final groups = appController.groups;
  final selectedMap = appController.currentProfile?.selectedMap ?? {};
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.takeFirstValid([
    appController.getRealTestUrl(testUrl),
  ]);
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(
    Delay(url: currentTestUrl, name: state.proxyName, value: null),
  );
  appController.setDelay(
    await _racingDelayTest(state.proxyName, currentTestUrl),
  );
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final proxyNames = proxies.map((proxy) => proxy.name).toSet().toList();

  final delayProxies = proxyNames.map<Future>((proxyName) async {
    final groups = appController.groups;
    final selectedMap = appController.currentProfile?.selectedMap ?? {};
    final state = computeRealSelectedProxyState(
      proxyName,
      groups: groups,
      selectedMap: selectedMap,
    );
    final url = state.testUrl.takeFirstValid([
      appController.getRealTestUrl(testUrl),
    ]);
    final name = state.proxyName;
    if (name.isEmpty) {
      return;
    }
    appController.setDelay(Delay(url: url, name: name, value: null));
    appController.setDelay(await _racingDelayTest(name, url));
  }).toList();

  final batchesDelayProxies = delayProxies.batch(100);
  for (final batchDelayProxies in batchesDelayProxies) {
    await Future.wait(batchDelayProxies);
  }
  appController.addSortNum();
}

/// 多URL竞速延迟测试
///
/// 同时向多个测试URL发送请求，取最低延迟结果
Future<Delay> _racingDelayTest(String proxyName, String displayUrl) async {
  final results = await Future.wait(
    delayTestUrls.map((url) async {
      try {
        return await coreController.getDelay(url, proxyName);
      } catch (_) {
        return Delay(name: proxyName, url: url, value: -1);
      }
    }),
  );

  // 找最低正延迟
  Delay? best;
  final parts = <String>[];
  for (final r in results) {
    final label = delayTestUrlLabels[r.url] ?? r.url;
    if (r.value != null && r.value! > 0) {
      parts.add('$label ${r.value}ms');
      if (best == null || r.value! < best.value!) {
        best = r;
      }
    } else {
      parts.add('$label ✗');
    }
  }

  if (best != null) {
    final winLabel = delayTestUrlLabels[best.url] ?? best.url;
    debugPrint('[延迟] $proxyName: ${parts.join(' | ')} → $winLabel ${best.value}ms ✓');
    return Delay(name: proxyName, url: displayUrl, value: best.value);
  }

  debugPrint('[延迟] $proxyName: ${parts.join(' | ')} → 全部超时');
  return Delay(name: proxyName, url: displayUrl, value: -1);
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final columns = appController.getProxiesColumns();
  final proxyCardType = appController.config.proxiesStyleProps.cardType;
  final selectedProxyName = appController.getSelectedProxyName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
