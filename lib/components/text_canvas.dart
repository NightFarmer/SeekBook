import 'package:flutter/material.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class ChapterTextPainter extends CustomPainter {
  static List<int> calcPagerData(text, width, height, textStyle, lineHeight) {
    List<int> result = [];

    var allChart = text.split('');

    double charHeight = lineHeight;

    double xOffset = 0.0;
    int yCharCount = 0;
    int lineCount = 0;
    for (int i = 0; i < allChart.length; i++) {
      var char = allChart[i];
      TextSpan span = new TextSpan(style: textStyle, text: char);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();

      if (char == '\n' || (xOffset + tp.size.width) > width) {
        xOffset = 0.0;
        yCharCount++;
      }
      if ((yCharCount + 1) * charHeight > height && char != '\n') {
        yCharCount = 0;
        result.add(i);
      }
      xOffset += 1 * tp.size.width;
    }
    if (result.length == 0 || result[result.length - 1] != allChart.length) {
      result.add(allChart.length);
    }
//    print("新算法算出来的分页页码, 文本长度${text.length}");
//    print(result);
    return result;
  }

  final String text;

  final double width;
  final double height;
  final double lineHeight;

  ChapterTextPainter({this.text, this.width, this.height, this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
//    print("paint=========== ${text.length}");
    //
//    Paint paint = new Paint() //设置笔的属性
//      ..color = Colors.blue[200]
//      ..strokeCap = StrokeCap.round
//      ..isAntiAlias = true
//      ..strokeWidth = 12.0
//
//      ..strokeJoin = StrokeJoin.bevel;

//    canvas.draw

    var textStyle = new TextStyle(
      height: 1.2,
      fontSize: dp(17),
      letterSpacing: dp(1),
      color: Color(0xff383635),
//        fontFamily: 'ReadFont',
    );
    var allChart = text.split('');

//    var charWidth = 18;
//    var charHeight = 27;
    var charLineCount = 20;

    double xOffset = 0.0;
    int xCharCount = 0;
    int yCharCount = 0;
//    double yOffset = 0.0;
    int lineCount = 0;
    for (int i = 0; i < allChart.length; i++) {
      var char = allChart[i];
      TextSpan span = new TextSpan(style: textStyle, text: char);
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();

//      if (char == '\n' || (xCharCount + 1) > charLineCount) {
      if (char == '\n' || (xOffset + tp.size.width) > width) {
        xOffset = 0.0;
        xCharCount = 0;
        yCharCount++;
//        if (char == '\n') {//多绘制一个换行符 并不要紧
//          continue;
//        }
      }

//      print("$char\t${tp.size}");
      var yOffset = yCharCount * lineHeight + (lineHeight - tp.size.height) / 2;
      tp.paint(canvas, new Offset(xOffset, yOffset));

      xCharCount++;
      xOffset += 1 * tp.size.width;
    }
  }

//  charWidth(char) {
//    var indexOf = littleChars.indexOf(char);
////    print("$indexOf\t$char");
//    return indexOf >= 0 ? 13.0 : 18.0;
//  }

//  charTopOffset(char) {
//    var indexOf = numbers.indexOf(char);
//    return indexOf >= 0 ? 3.0 : 0;
//  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TextCanvas extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double lineHeight;

  TextCanvas({Key key, this.text, this.width, this.height, this.lineHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: new ChapterTextPainter(
        text: text,
        width: width,
        height: height,
        lineHeight: lineHeight,
      ),
    );
  }
}
