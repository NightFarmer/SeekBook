import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void ClickCallback();

class Clickable extends StatelessWidget {
  final Widget child;
  final ClickCallback onClick;

  final double pressedOpacity;

  Clickable({Key key, this.child, this.onClick, this.pressedOpacity = 0.1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
//    return GestureDetector(
//      behavior: HitTestBehavior.opaque,
//      child: child,
//      onTap: () async {
////        Feedback.forTap(context);
//        /*await */ SystemSound.play(SystemSoundType.click);
//        if (this.onClick != null) {
//          this.onClick();
//        }
//      },
//    );
    return CupertinoButton(
      padding: EdgeInsets.all(0.0),
      child: child,
      borderRadius: BorderRadius.all(Radius.circular(0.0)),
//      color: Colors.red,
      pressedOpacity: pressedOpacity,
      onPressed: () {
        SystemSound.play(SystemSoundType.click);
        if (this.onClick != null) {
          this.onClick();
        }
      },
    );
  }
}
