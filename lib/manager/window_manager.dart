import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/mihom/providers/theme_provider.dart';
import 'package:fl_clash/mihom/theme/mihom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends ConsumerStatefulWidget {
  final Widget child;

  const WindowManager({super.key, required this.child});

  @override
  ConsumerState<WindowManager> createState() => _WindowContainerState();
}

class _WindowContainerState extends ConsumerState<WindowManager>
    with WindowListener, WindowExtListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.autoLaunch), (
      prev,
      next,
    ) {
      if (prev != next) {
        debouncer.call(FunctionTag.autoLaunch, () {
          autoLaunch?.updateStatus(next);
        });
      }
    });
    windowExtManager.addListener(this);
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    await appController.handleBackOrExit();
    super.onWindowClose();
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    commonPrint.log('focus');
    render?.resume();
  }

  @override
  Future<void> onShouldTerminate() async {
    await appController.handleExit();
    super.onShouldTerminate();
  }

  @override
  void onWindowMoved() {
    super.onWindowMoved();
    windowManager.getPosition().then((offset) {
      ref.read(windowSettingProvider.notifier);
      // .update((state) => state.copyWith(top: offset.dy, left: offset.dx));
    });
  }

  @override
  Future<void> onWindowResized() async {
    super.onWindowResized();
    final size = await windowManager.getSize();
    ref
        .read(windowSettingProvider.notifier)
        .update(
          (state) => state.copyWith(width: size.width, height: size.height),
        );
  }

  @override
  void onWindowMinimize() async {
    appController.savePreferencesDebounce();
    commonPrint.log('minimize');
    render?.pause();
    super.onWindowMinimize();
  }

  @override
  void onWindowRestore() {
    commonPrint.log('restore');
    render?.resume();
    super.onWindowRestore();
  }

  @override
  Future<void> dispose() async {
    windowManager.removeListener(this);
    windowExtManager.removeListener(this);
    super.dispose();
  }
}

class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final isMobileView = ref.watch(isMobileViewProvider);
        final version = ref.watch(versionProvider);
        if ((version <= 10 || !isMobileView) && system.isMacOS) {
          return child!;
        }
        return Column(
          children: [
            const WindowHeader(),
            Expanded(child: child!),
          ],
        );
      },
      child: child,
    );
  }
}

class WindowHeader extends ConsumerStatefulWidget {
  const WindowHeader({super.key});

  @override
  ConsumerState<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends ConsumerState<WindowHeader> {
  final isMaximizedNotifier = ValueNotifier<bool>(false);
  final isPinNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initNotifier();
  }

  Future<void> _initNotifier() async {
    isMaximizedNotifier.value = await windowManager.isMaximized();
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  @override
  void dispose() {
    isMaximizedNotifier.dispose();
    isPinNotifier.dispose();
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    switch (isMaximized) {
      case true:
        await windowManager.unmaximize();
        break;
      case false:
        await windowManager.maximize();
        break;
    }
    isMaximizedNotifier.value = await windowManager.isMaximized();
  }

  Future<void> _updatePin() async {
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    isPinNotifier.value = await windowManager.isAlwaysOnTop();
  }

  Widget _buildActions(Color iconColor) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            _updatePin();
          },
          icon: ValueListenableBuilder(
            valueListenable: isPinNotifier,
            builder: (_, value, _) {
              return value
                  ? Icon(Icons.push_pin, color: iconColor, size: 18)
                  : Icon(Icons.push_pin_outlined, color: iconColor, size: 18);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            windowManager.minimize();
          },
          icon: Icon(Icons.remove, color: iconColor, size: 18),
        ),
        IconButton(
          onPressed: () async {
            _updateMaximized();
          },
          icon: ValueListenableBuilder(
            valueListenable: isMaximizedNotifier,
            builder: (_, value, _) {
              return value
                  ? Icon(Icons.filter_none, color: iconColor, size: 16)
                  : Icon(Icons.crop_square, color: iconColor, size: 18);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            appController.handleBackOrExit();
          },
          icon: Icon(Icons.close, color: iconColor, size: 18),
        ),
      ],
    );
  }

  MihomTheme get _mihomTheme {
    final themeState = system.isDesktop
        ? ref.watch(desktopThemeProvider)
        : ref.watch(mobileThemeProvider);
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return resolveTheme(themeState, systemBrightness);
  }

  @override
  Widget build(BuildContext context) {
    final t = _mihomTheme;
    final iconColor = Colors.white.withValues(alpha: 0.9);

    return Container(
      decoration: BoxDecoration(gradient: t.primaryGradient),
      child: Material(
      color: Colors.transparent,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            child: GestureDetector(
              onPanStart: (_) {
                windowManager.startDragging();
              },
              onDoubleTap: () {
                _updateMaximized();
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                height: kHeaderHeight,
              ),
            ),
          ),
          // App icon on the left
          Positioned(
            left: 10,
            child: SizedBox(
              height: kHeaderHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/branding/icon.png', width: 22, height: 22),
                  const SizedBox(width: 6),
                  Text(appName, style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          if (system.isMacOS)
            const SizedBox.shrink()
          else ...[
            Positioned(right: 0, child: _buildActions(iconColor)),
          ],
        ],
      ),      ),    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Transform.translate(
        offset: Offset(0, -1),
        child: Image.asset('assets/images/icon.png', width: 34, height: 34),
      ),
    );
  }
}
