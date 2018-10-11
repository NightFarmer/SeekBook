import 'dart:async';

import 'package:battery/battery.dart' as batteryLib;

class Battery {
  static var value = 0;
  static var battery = new batteryLib.Battery();

  static init() async {
    Battery.waitToGetBatteryValue();
  }

  static waitToGetBatteryValue() async {
    try {
      Battery.value = await battery.batteryLevel;
//      print("battery ${Battery.value}");
      await Future.delayed(Duration(milliseconds: 5000));
      Battery.waitToGetBatteryValue();
    } catch (e) {
      print(e);
    }
  }
}
