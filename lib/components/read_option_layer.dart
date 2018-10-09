import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seek_book/utils/status_bar.dart';

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

    StatusBar.hide();

    super.initState();
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
      color: Colors.green.withOpacity(0.1),
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
