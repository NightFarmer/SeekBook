import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    this.init();
  }

  init() async {
    Future.delayed(Duration(milliseconds: 1000));
//    Navigator.pushNamed(context, '/read');
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdaptation.designSize = 414.0;
    ScreenAdaptation.init(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/read');
        },
        child: Text('jump'),
      ),
    );
  }
}
