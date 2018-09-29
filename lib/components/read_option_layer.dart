import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 阅读页选项弹出层
class ReadOptionLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ReadOptionLayerState();
  }
}

class _ReadOptionLayerState extends State<ReadOptionLayer> {
  @override
  void initState() {
    // TODO: implement initState
//    if (ChqMeasurements.isLandscapePhone(context)) {
//      SystemChrome.setEnabledSystemUIOverlays([]);
//    } else {
//      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
//    }
    SystemChrome.setEnabledSystemUIOverlays([]);
    print("?????");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
