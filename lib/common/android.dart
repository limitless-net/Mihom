import 'dart:io';

import 'package:fl_clash/controller.dart';
import 'package:fl_clash/plugins/app.dart';

class Android {
  init() async {
    app?.onExit = () async {
      appController.savePreferencesDebounce();
    };
  }
}

final android = Platform.isAndroid ? Android() : null;
