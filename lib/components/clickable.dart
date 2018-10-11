import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void ClickCallback();

class Clickable extends StatelessWidget {
  final Widget child;
  final ClickCallback onClick;

  Clickable({Key key, this.child, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: child,
      onTap: () async {
//        Feedback.forTap(context);
        /*await */ SystemSound.play(SystemSoundType.click);
        if (this.onClick != null) {
          this.onClick();
        }
      },
    );
  }
}
