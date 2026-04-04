import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'controller.dart';
import 'xboard/xboard.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:fl_clash/xboard/router/app_router.dart' as xboard_router;
import 'package:fl_clash/xboard/features/initialization/initialization.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  Timer? _autoUpdateProfilesTaskTimer;
  bool _preHasVpn = false;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: commonSharedXPageTransitions,
      TargetPlatform.windows: commonSharedXPageTransitions,
      TargetPlatform.linux: commonSharedXPageTransitions,
      TargetPlatform.macOS: commonSharedXPageTransitions,
    },
  );

  ColorScheme _getAppColorScheme({
    required Brightness brightness,
    int? primaryColor,
  }) {
    return ref.read(genColorSchemeProvider(brightness));
  }

  @override
  void initState() {
    super.initState();

    // XBoard: 后台预热初始化服务（不阻塞 UI）
    Future.microtask(() async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        debugPrint('[Application] 预热初始化失败: $e');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        await appController.attach(currentContext, ref);
      } else {
        exit(0);
      }
      _autoUpdateProfilesTask();
      appController.initLink();
      app?.initShortcuts();

      // XBoard: 快速认证和更新检查
      _performQuickAuthWithDomainService();
      _checkForUpdates();
    });
  }

  /// XBoard: 使用域名服务进行快速认证检查
  void _performQuickAuthWithDomainService() {
    Future.microtask(() async {
      try {
        final initState = ref.read(initializationProvider);
        if (!initState.isReady) {
          final deadline = DateTime.now().add(const Duration(seconds: 30));
          while (!ref.read(initializationProvider).isReady &&
              !ref.read(initializationProvider).isFailed &&
              DateTime.now().isBefore(deadline)) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          if (!ref.read(initializationProvider).isReady) {
            // 初始化失败或超时，仍然标记用户状态为已初始化，让路由跳到登录页（而非永远卡在 /loading）
            ref.read(xboardUserProvider.notifier).markInitialized();
            return;
          }
        }

        final userNotifier = ref.read(xboardUserProvider.notifier);
        await userNotifier.quickAuth();

        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('[Application] 快速认证检查失败: $e');
        // 认证失败也要标记已初始化，避免卡在 /loading
        ref.read(xboardUserProvider.notifier).markInitialized();
        if (mounted) setState(() {});
      }
    });
  }

  /// XBoard: 检查应用更新
  void _checkForUpdates() {
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        final updateNotifier = ref.read(updateCheckProvider.notifier);
        await updateNotifier.checkForUpdates();

        final updateState = ref.read(updateCheckProvider);
        if (updateState.hasUpdate && mounted) {
          final currentContext = globalState.navigatorKey.currentContext;
          if (currentContext != null) {
            showDialog(
              context: currentContext,
              barrierDismissible: !updateState.forceUpdate,
              builder: (context) => UpdateDialog(state: updateState),
            );
          }
        }
      } catch (e) {
        debugPrint('[Application] 自动更新检查异常: $e');
      }
    });
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await appController.autoUpdateProfiles();
      _autoUpdateProfilesTask();
    });
  }

  Widget _buildPlatformState({required Widget child}) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(child: ProxyManager(child: child)),
        ),
      );
    }
    return AndroidManager(child: TileManager(child: child));
  }

  Widget _buildState({required Widget child}) {
    return AppStateManager(
      child: CoreManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            commonPrint.log('connectivityChanged ${results.toString()}');
            appController.updateLocalIp();
            final hasVpn = results.contains(ConnectivityResult.vpn);
            if (_preHasVpn == hasVpn) {
              appController.addCheckIp();
            }
            _preHasVpn = hasVpn;
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlatformApp({required Widget child}) {
    if (system.isDesktop) {
      return WindowHeaderContainer(child: child);
    }
    return VpnManager(child: child);
  }

  Widget _buildApp({required Widget child}) {
    return StatusManager(child: ThemeManager(child: child));
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (_, ref, child) {
        // XBoard: WebSocket 自动连接器
        ref.watch(webSocketAutoConnectorProvider);

        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeProps = ref.watch(themeSettingProvider);
        final userState = ref.watch(xboardUserProvider);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (_, child) {
            return AppEnvManager(
              child: _buildApp(
                child: _buildPlatformState(
                  child: _buildState(child: _buildPlatformApp(child: child!)),
                ),
              ),
            );
          },
          routerConfig: _buildRouter(userState),
          scrollBehavior: BaseScrollBehavior(),
          title: appName,
          locale: utils.getLocaleForString(locale),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: themeProps.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.light,
              primaryColor: themeProps.primaryColor,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.dark,
              primaryColor: themeProps.primaryColor,
            ).toPureBlack(themeProps.pureBlack),
          ),
        );
      },
    );
  }

  // XBoard: 构建带认证重定向的路由器
  GoRouter _buildRouter(UserAuthState userState) {
    return GoRouter(
      navigatorKey: globalState.navigatorKey,
      initialLocation: '/',
      routes: xboard_router.routes,
      redirect: (context, state) {
        final isAuthenticated = userState.isAuthenticated;
        final isInitialized = userState.isInitialized;
        final isLoginPage = state.uri.path == '/login';

        if (!isInitialized) return '/loading';
        if (!isAuthenticated && !isLoginPage) return '/login';
        if (isAuthenticated && isLoginPage) return '/';

        return null;
      },
    );
  }

  @override
  Future<void> dispose() async {
    linkManager.destroy();
    _autoUpdateProfilesTaskTimer?.cancel();
    await coreController.destroy();
    await appController.handleExit();
    super.dispose();
  }
}
