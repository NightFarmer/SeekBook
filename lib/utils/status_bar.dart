import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBar {
  static const platform =
      const MethodChannel('seekbook.nightfarmer.top/statusbar');

  static hide() async {
    if (Platform.operatingSystem == 'android') {
      try {
        await platform.invokeMethod('hide');
      } catch (e) {}
    } else {
      var index = SystemUiOverlay.values.indexOf(SystemUiOverlay.top);
      List<SystemUiOverlay> newLays = []..addAll(SystemUiOverlay.values);
      newLays.removeAt(index);
      SystemChrome.setEnabledSystemUIOverlays(newLays);
    }
  }

  static show() async {
    if (Platform.operatingSystem == 'android') {
      try {
        final int result = await platform.invokeMethod('show');
      } catch (e) {}
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }
}
