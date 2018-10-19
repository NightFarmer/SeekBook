import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seek_book/components/home_page_top_bar.dart';
import 'package:seek_book/components/my_book_list.dart';
import 'package:seek_book/pages/book_search_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

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
    ScreenAdaptation.designSize = 414.0;
    ScreenAdaptation.init(context);
    final ThemeData theme = Theme.of(context);
    Widget scaffold = Scaffold(
      appBar: HomePageTopBar(
        onRightButtonClick: () {
          myBookListKey.currentState.loadData();
        },
      ),
      body: MyBookList(key: myBookListKey),
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
//    ScreenAdaptation.designSize = 414.0;
//    ScreenAdaptation.init(context);

    scaffold = Container(
      color: theme.primaryColor,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: theme.primaryColor,
//                height: dp(80),
//                decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                    colors: [
//                      theme.primaryColor,
//                      theme.primaryColor,
////                      Color(0xFFffae87),
//                    ],
//                  ),
//                ),
                padding: EdgeInsets.symmetric(
                  vertical: dp(10),
                  horizontal: dp(10),
                ),
//                alignment: Alignment.centerLeft,
//                child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '书探',
                              style: TextStyle(
                                fontSize: dp(25),
                                color: Color(0xFFffffff),
                              ),
                            ),
                          ),
                          GestureDetector(
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
                        ],
                      ),
                      padding: EdgeInsets.only(
//                        bottom: dp(10),
                        bottom: dp(5),
                        left: dp(5),
                      ),
                    ),
//                    Card(
//                      child: Container(
//                        height: dp(40),
////                    color: Color(0xFFffffff),
//                        child: Text("1"),
//                      ),
////                      elevation: dp(15),
//                      elevation: dp(0),
////                  color: Colors.blue,
//                    )
                  ],
                ),
//                ),
              ),
//              Container(
//                child: GestureDetector(
//                  onTap: () async {
////                Navigator.pushNamed(context, '/search');
//                    await Navigator.push(
//                      context,
//                      CupertinoPageRoute(
//                        builder: (context) => BookSearchPage(),
//                      ),
//                    );
////                    loadData();
//                    await Future.delayed(Duration(milliseconds: 350));
//                    myBookListKey.currentState.loadData();
//                  },
//                  child: Text('search'),
//                ),
//              ),
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
//    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.light;
////    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.dark;
//    return new AnnotatedRegion<SystemUiOverlayStyle>(
//      value: overlayStyle,
//      child: scaffold,
//      sized: false,
//    );
////    return scaffold;
  }
}
