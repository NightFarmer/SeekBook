// 翻页阅读容器组件

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/components/read_pager_item.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class ReadPager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReadPagerState();
  }
}

class _ReadPagerState extends State<ReadPager> {
  var currentPageIndex = 0;
  var currentChapterIndex = 0;

  var chapterTextCacheList = List(); //已缓存到内存的章节，缓存3个，当前的/上一章/下一章，若没有则从网络和本地读取，

  get ReadTextWidth => ScreenAdaptation.screenWidth - dp(32);

  get ReadTextHeight =>
      ScreenAdaptation.screenHeight - dp(35) - dp(44); //减去头部章节名称高度，减去底部页码高度

  var pageEndIndexList = [];

  var content = "";

  get textStyle => new TextStyle(
        height: 1.2,
        fontSize: dp(20),
        letterSpacing: dp(1),
        color: Color(0xff383635),
//        fontFamily: 'ReadFont',
      );

  @override
  void initState() {
    this.chapterParse();
    super.initState();
  }

  Future chapterParse() async {
    setState(() {
      this.content = 'loading';
    });

    Dio dio = new Dio();
    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
    Response response = await dio.get(url);
    var document = parse(response.data);
    var content = document.querySelector('#content').innerHtml;
    content = content
        .split("<br>")
        .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
        .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
        .join('\n');

//    print(content);
//    print(ReadTextWidth);
//    print(ReadTextHeight);

    var pageEndIndexList = parseChapterPager(content);
    print(pageEndIndexList);
    print("页数 ${pageEndIndexList.length}");
    this.pageEndIndexList = pageEndIndexList;

    setState(() {
      this.content = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    var text = content;
    if (text.length > 0) {
      if (this.pageEndIndexList.length > 1) {
        text = content.substring(
          currentPageIndex == 0
              ? 0
              : this.pageEndIndexList[currentPageIndex - 1],
          this.pageEndIndexList[currentPageIndex],
        );
      }
    }
    return ReadPagerItem(
      text: new Text(
        text,
        style: textStyle,
      ),
      title: "章节标题",
    );
  }

  // 解析一个章节所有分页每页最后字符的index列表
  List<int> parseChapterPager(String content) {
    List<int> pageEndPointList = List();
    do {
      var contentNeedToParse = content;
      var prePageEnd = 0;
      if (pageEndPointList.length > 0) {
        prePageEnd = pageEndPointList[pageEndPointList.length - 1];
        contentNeedToParse = content.substring(
          prePageEnd,
          min(prePageEnd + pageEndPointList[0] * 2, content.length),
        );
//        contentNeedToParse = content.substring(prePageEnd);
      }
      pageEndPointList.add(prePageEnd + getOnePageEnd(contentNeedToParse));
    } while (pageEndPointList.length == 0 ||
        pageEndPointList[pageEndPointList.length - 1] != content.length);

    return pageEndPointList;
  }

  /// 传入需要计算分页的文本，返回第一页最后一个字符的index
  int getOnePageEnd(String text) {
    if (layout(text)) {
//      return false;
      return text.length;
    }

    int start = 0;
    int end = text.length;
    int mid = (end + start) ~/ 2;

    var time = 0;
    // 最多循环20次
    for (int i = 0; i < 20; i++) {
      time++;
      if (layout(text.substring(0, mid))) {
        if (mid <= start || mid >= end) break;
        // 未越界
        start = mid;
        mid = (start + end) ~/ 2;
      } else {
        // 越界
        end = mid;
        mid = (start + end) ~/ 2;
      }
    }
    print('循环次数 ${time}');
    return mid;
  }

  /// 计算待绘制文本
  /// 未超出边界返回true
  /// 超出边界返回false
  bool layout(String text) {
    text = text ?? '';
    var textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter
      ..text = getTextSpan(text)
      ..layout(maxWidth: ReadTextWidth);
    return !didExceed(textPainter);
  }

  /// 是否超出边界
  bool didExceed(textPainter) {
    return textPainter.didExceedMaxLines ||
        textPainter.size.height > ReadTextHeight;
  }

  /// 获取带样式的文本对象
  TextSpan getTextSpan(String text) {
//    if (text.startsWith('\n')) {
//      text = text.substring(1);
//    }
    // 判定时，移除可能是本页文本的最后一个换行符，避免造成超过一页
    if (text.endsWith('\n')) {
      text = text.substring(0, text.length - 1);
    }
    return new TextSpan(text: text, style: textStyle);
  }
}
