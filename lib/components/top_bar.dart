import 'package:flutter/material.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

typedef void ClickCallback();

class TopBar extends PreferredSize {
  final Widget child;
  final title;
  final String rightButtonText;
  final ClickCallback onRightButtonClick;
  static final double DefaultHeight = dp(55.0);

  TopBar({
    Key key,
    this.child,
    this.title,
    this.rightButtonText,
    this.onRightButtonClick,
  }) : super(child: child, preferredSize: Size(0.0, dp(300.0)));

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    if (child == null) {
      child = _TopBarDefaultChild(
        title: title,
        rightButtonText: rightButtonText,
        onRightButtonClick: onRightButtonClick,
      );
    }
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
          child: Container(
//              color: Colors.green,
        color: Theme.of(context).primaryColor,
        child: child,
      )),
    );
  }
}

class _TopBarDefaultChild extends StatelessWidget {
  final title;
  final rightButtonText;
  final onRightButtonClick;

  _TopBarDefaultChild({
    Key key,
    this.title,
    this.rightButtonText,
    this.onRightButtonClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget titleView;
    if (this.title is String) {
      titleView = Text(
        title,
        style: TextStyle(
          color: Color(0xFFffffff),
          fontSize: dp(18.0),
        ),
      );
    } else if (this.title is Widget) {
      titleView = this.title;
    } else {
      titleView = Text("");
    }
    Widget rightWidget;
    if (this.rightButtonText != null) {
      rightWidget = Clickable(
        onClick: () {
          if (this.onRightButtonClick != null) {
            this.onRightButtonClick();
          }
        },
        child: Container(
          margin: EdgeInsets.only(right: dp(13.0)),
          padding:
              EdgeInsets.symmetric(horizontal: dp(10.0), vertical: dp(2.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(dp(13.0))),
            border: Border.all(color: Color(0xFFffffff), width: dp(0.8)),
          ),
          child: Text(
            rightButtonText,
            style: TextStyle(
              color: Color(0xFFffffff),
              fontSize: dp(11.5),
            ),
          ),
        ),
      );
    }
    var leftButton = Clickable(
      onClick: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dp(14.0),
          vertical: dp(10.0),
        ),
        child: Image.asset(
          "assets/images/ab_back.png",
          width: dp(32.0),
        ),
      ),
    );
    var buttons = <Widget>[];
    buttons.add(leftButton);
    if (rightWidget != null) {
      buttons.add(rightWidget);
    }
    return Container(
      child: Stack(
        children: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons,
            ),
          ),
          Center(
            child: titleView,
          )
        ],
      ),
      height: TopBar.DefaultHeight,
    );
  }
}
