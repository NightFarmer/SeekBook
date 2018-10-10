import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/components/read_option_layer.dart';
import 'package:seek_book/components/read_pager.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class ReadPage extends StatefulWidget {
  Map bookInfo;

  ReadPage({Key key, @required this.bookInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReadPageState();
  }
}

class _ReadPageState extends State<ReadPage> {
  final GlobalKey<ReadOptionLayerState> optionLayerKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              child: ReadPager(
                bookInfo: widget.bookInfo,
                optionLayerKey: optionLayerKey,
              ),
              left: 0.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
            ),
            Positioned(
              child: ReadOptionLayer(key: optionLayerKey),
              left: 0.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
            ),
          ],
        ),
      ),
      onWillPop: () async {
        return true;
//        return false;
      },
    );
  }
}
