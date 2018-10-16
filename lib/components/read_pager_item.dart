import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seek_book/components/battery_icon.dart';
import 'package:seek_book/utils/battery.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/globals.dart' as Globals;

class ReadPagerItem extends StatefulWidget {
  final text;
  final title;
  final pageLabel;

  ReadPagerItem({Key key, this.text, this.title, this.pageLabel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReadPagerItemState();
  }
}

/// 翻页阅读的每页组件
class _ReadPagerItemState extends State<ReadPagerItem> {
  var pageWidth = vw(100);
  var pageHeight = ScreenAdaptation.screenHeight;

  var batteryValue = 0;
  var time = "";

  @override
  void initState() {
    this.waitToGetNewStateValue();
    super.initState();
  }

  waitToGetNewStateValue() async {
    try {
      batteryValue = Battery.value;
      var dateTime = new DateTime.now();
      time = '${dateTime.hour}:${dateTime.minute}';
      await Future.delayed(Duration(milliseconds: 1000));
      this.waitToGetNewStateValue();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    //标题及电量页面文字颜色
    var smallTextColor =
        Globals.readTheme == 'normal' ? Color(0xff807C7A) : Color(0xFFffffff);
    var smallTextStyle = TextStyle(color: smallTextColor, fontSize: dp(13));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dp(16)),
      decoration: BoxDecoration(
        //阅读背景色
        color: Globals.readTheme == 'normal'
            ? Color(0xffEAE5E0)
            : Color(0xff000000),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: dp(35),
//            color: Colors.green,
            alignment: Alignment.topLeft,
//            color: Colors.green,
            padding: EdgeInsets.only(top: dp(12)),
            child: Text(
              widget.title,
              style: TextStyle(
                color: smallTextColor,
                fontSize: dp(14),
              ),
            ),
          ),
          Expanded(
            child: widget.text,
          ),
          Container(
            height: dp(44),
//            color: Colors.green.withOpacity(0.2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                BatteryIcon(
                  color: smallTextColor,
                ),
                Expanded(
                  child: Text(
                    '$time',
                    style: smallTextStyle,
                  ),
                ),
                Text(
                  '${widget.pageLabel}',
                  style: smallTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
