import 'package:battery/battery.dart' as batteryLib;

class Battery {
  static var value = 0;
  static var battery = new batteryLib.Battery();

  static init() async {
    Battery.waitToGetBatteryValue();
  }

  static waitToGetBatteryValue() async {
    Battery.value = await battery.batteryLevel;
    print("battery ${Battery.value}");
    await Future.delayed(Duration(milliseconds: 1000));
    Battery.waitToGetBatteryValue();
  }
}
