import 'package:flutter/material.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class DemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _DemoPageState();
  }
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (c, i) {
        return Container(
          height: dp(35),
          child: Text('$i'),
        );
      },
      itemCount: 2000,
      controller: ScrollController(initialScrollOffset: dp(35) * 1600),
    );
  }
}
