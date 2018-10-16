import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:seek_book/components/my_book_list.dart';
import 'package:seek_book/pages/book_search_page.dart';
import 'package:seek_book/pages/read_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:seek_book/globals.dart' as Globals;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  GlobalKey<MyBookListState> myBookListKey = GlobalKey();

  List<Map> bookList = [];

  @override
  void initState() {
    super.initState();
//    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
//    ScreenAdaptation.designSize = 414.0;
//    ScreenAdaptation.init(context);

    var scaffold = Container(
      color: Colors.red,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Container(
                child: GestureDetector(
                  onTap: () async {
//                Navigator.pushNamed(context, '/search');
                    await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BookSearchPage(),
                      ),
                    );
//                    loadData();
                    await Future.delayed(Duration(milliseconds: 350));
                    myBookListKey.currentState.loadData();
                  },
                  child: Text('search'),
                ),
              ),
              Expanded(
                child: MyBookList(key: myBookListKey),
//                child: ListView.builder(
//                  itemBuilder: buildRow,
//                  itemCount: bookList.length,
//                ),
              )
            ],
          ),
        ),
      ),
    );
    //浅色状态栏文字
    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.light;
//    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.dark;
    return new AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: scaffold,
      sized: false,
    );
//    return scaffold;
  }
}
