import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 阅读页选项弹出层
class ReadOptionLayer extends StatefulWidget {
  ReadOptionLayer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ReadOptionLayerState();
  }
}

class ReadOptionLayerState extends State<ReadOptionLayer> {
  var layerShow = false;

  @override
  void initState() {
    // TODO: implement initState
//    if (ChqMeasurements.isLandscapePhone(context)) {
//      SystemChrome.setEnabledSystemUIOverlays([]);
//    } else {
//      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//    }
//    SystemChrome.setEnabledSystemUIOverlays([]);
    print("?????");

//    StatusBar.hide();

    super.initState();

    initScreenOrientation();
//    print("1111111111111111111111111");
  }

//  void

  void initScreenOrientation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    if (MediaQuery.of(context).orientation == Orientation.portrait) {
    var orientation = prefs.getString('orientation');
    if (orientation == 'landscape') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else if (orientation == 'portrait') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void show() {
    if (layerShow) return;
    setState(() {
      layerShow = true;
    });
    StatusBar.show();
  }

  void hide() {
    if (!layerShow) return;
    setState(() {
      layerShow = false;
    });
    StatusBar.hide();
  }

  void toggle() {
    if (layerShow) {
      hide();
    } else {
      show();
    }
  }

  @override
  Widget build(BuildContext context) {
    var topLayer = Container(
      height: 100.0,
      color: Colors.black,
      child: SafeArea(
        child: Container(
          width: vw(100),
          color: Colors.lightGreen,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text("返回"),
          ),
        ),
      ),
    );
    var bottomLayer = Container(
      height: 100.0,
      color: Colors.green.withOpacity(0.1),
    );
    var children = <Widget>[
      topLayer,
      Expanded(child: Container()),
      bottomLayer
    ];
    if (!layerShow) {
      children = [];
    }
    return Container(
      child: Column(
        children: children,
      ),
    );
  }
}
