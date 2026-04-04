import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/config/utils/config_file_loader.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_racing_service.dart';
import 'package:fl_clash/xboard/features/remote_task/remote_task_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

import 'application.dart';
import 'common/common.dart';

RemoteTaskManager? remoteTaskManager;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化 XBoard 配置模块和域名服务
    await _initializeXBoardServices();

    // 初始化 RemoteTaskManager（非阻塞）
    try {
      remoteTaskManager = await RemoteTaskManager.create();
      if (remoteTaskManager != null) {
        remoteTaskManager!.initialize();
        remoteTaskManager!.start();
      }
    } catch (e) {
      debugPrint('RemoteTaskManager 初始化异常: $e');
      remoteTaskManager = null;
    }

    final version = await system.version;
    final container = await globalState.init(version);
    HttpOverrides.global = FlClashHttpOverrides();

    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    return runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}

Future<void> _loadSecurityConfig() async {
  try {
    final certConfig = await ConfigFileLoaderHelper.getCertificateConfig();
    final certPath = certConfig['path'] as String?;
    final certEnabled = certConfig['enabled'] as bool? ?? true;

    if (certEnabled && certPath != null && certPath.isNotEmpty) {
      DomainRacingService.setCertificatePath(certPath);
    }
  } catch (e) {
    debugPrint('[Main] 加载安全配置失败（使用默认值）: $e');
  }
}

Future<void> _initializeXBoardServices() async {
  try {
    final configSettings = await ConfigFileLoader.loadFromFile();
    await _loadSecurityConfig();
    await XBoardConfig.initialize(settings: configSettings);
  } catch (e) {
    debugPrint('[Main] XBoard服务初始化失败: $e');
    rethrow;
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      remoteTaskManager?.dispose();
      XBoardSDK.instance.dispose();
    }
  }
}
