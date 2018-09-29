import 'package:flutter/material.dart';
import 'package:seek_book/utils/battery.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class BatteryIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    test();
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            color: Colors.green,
            width: 2.0,
            height: 6.0,
          ),
          Container(
            child: Text(
              Battery.value.toString(),
              style: TextStyle(
                fontSize: dp(10),
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(
//                width: 2,
                  ),
            ),
          )
        ],
      ),
    );
  }

  void test() async {}
}
