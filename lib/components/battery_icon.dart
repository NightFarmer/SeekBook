import 'package:flutter/material.dart';
import 'package:seek_book/utils/battery.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class BatteryIcon extends StatelessWidget {
  final Color color;

  BatteryIcon({this.color});

  @override
  Widget build(BuildContext context) {
    test();
    return Container(
      margin: EdgeInsets.only(right: dp(10), top: dp(1)),
      child: Row(
        children: <Widget>[
          Container(
            color: color,
            width: dp(1.5),
            height: 6.0,
          ),
          Container(
            width: dp(20),
            height: dp(13),
            alignment: Alignment.center,
            child: FittedBox(
              child: Text(
                Battery.value.toString(),
                style: TextStyle(
                  color: color,
                ),
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: dp(1.5),
                color: color,
              ),
            ),
          )
        ],
      ),
    );
  }

  void test() async {}
}
