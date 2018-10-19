import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/pages/book_search_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

typedef void ClickCallback();

class HomePageTopBar extends PreferredSize {
//  final Widget child;
//  final title;
//  final String rightButtonText;
  final ClickCallback onRightButtonClick;

  HomePageTopBar({
    Key key,
//    this.child,
//    this.title,
//    this.rightButtonText,
    this.onRightButtonClick,
  }) : super(child: null, preferredSize: Size(0.0, dp(300.0)));

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    if (child == null) {
      child = Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '书探',
              style: TextStyle(
                fontSize: dp(30),
                color: Color(0xFFffffff),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
//          FlatButton(
//            onPressed: () {},
//            child: Container(
//              child: Image.asset(
//                'assets/images/ic_action_search.png',
//                width: dp(40),
//                height: dp(40),
//              ),
//              width: dp(50),
//              height: dp(50),
//              alignment: Alignment.center,
//              color: Color(0x00ffffff),
//            ),
//            highlightColor: Color(0x11ffffff),
//          ),
          Clickable(
            onClick: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => BookSearchPage(),
                ),
              );
              await Future.delayed(Duration(milliseconds: 350));
              if (onRightButtonClick != null) {
                onRightButtonClick();
              }
            },
            child: Container(
              child: Image.asset(
                'assets/images/ic_action_search.png',
                width: dp(40),
                height: dp(40),
              ),
              width: dp(60),
              height: dp(55),
              alignment: Alignment.center,
              color: Color(0xffffff),
            ),
          ),
        ],
      );
    }
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Container(
//          height: dp(60),
          color: Theme.of(context).primaryColor,
          child: child,
          padding: EdgeInsets.only(
            left: dp(10),
            top: dp(10),
            bottom: dp(10),
          ),
        ),
      ),
    );
  }
}
