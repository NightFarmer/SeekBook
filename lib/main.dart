import 'package:flutter/material.dart';
import 'package:seek_book/utils/battery.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

import 'pages/read_page.dart';

void main() {
  Battery.init();
  ScreenAdaptation.designSize = 414.0;

  return runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ReadPage(),
    );
  }
}
