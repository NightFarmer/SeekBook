import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBar {
  static hide() {
    var index = SystemUiOverlay.values.indexOf(SystemUiOverlay.top);
    List<SystemUiOverlay> newLays = []..addAll(SystemUiOverlay.values);
    newLays.removeAt(index);
    SystemChrome.setEnabledSystemUIOverlays(newLays);
  }

  static show() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}
