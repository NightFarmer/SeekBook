import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/book_site.dart';
import 'package:seek_book/globals.dart' as Globals;

class BookSiteKenWen extends BookSite {
  final String site = '啃文书库';


  @override
  List<Map> parseChapterList(Document document, String bookUrl) {
    List<Map> chapterList = [];
    var groupIndex = 0;
    document.querySelector('#list dl').children.forEach((row) {
      var chapterRow = row.querySelector('a');
      if (chapterRow == null) {
        groupIndex++;
        return;
      }
      if (groupIndex > 1) {
        chapterList.add({
          'title': chapterRow.text,
          'url': bookUrl + chapterRow.attributes['href'],
        });
      }
    });
    return chapterList;
  }

  @override
  String parseBookImage(Document document, String bookUrl) {
    return 'http://www.kenwen.com' +
        document.querySelector('#fmimg img').attributes['src'];
  }

  @override
  int parseUpdateTime(Document document, String bookUrl) {
    var updateTimeStr = document.querySelector('#info').children[3].text;
//    print(updateTimeStr);
    var split = updateTimeStr.replaceAll('最后更新：', '').split(' ');
    var dateStr = split[0];
    var timeStr = split[1];
    var split2 = dateStr.split('/');
    var split3 = timeStr.split(':');
    var dateTime = new DateTime(
      int.parse(split2[0]),
      int.parse(split2[1]),
      int.parse(split2[2]),
      int.parse(split3[0]),
      int.parse(split3[1]),
      int.parse(split3[2]),
    );
//    print(dateTime);
    return dateTime.millisecondsSinceEpoch;
  }

  @override
  Future<ChapterText> parseChapterText(param) async {
    String data = param['data'];
    //      await Future.delayed(Duration(milliseconds: 5000));
    var document = parse(data);
    String content = document.querySelector('#content').innerHtml;
    content = content
        .replaceAll('<script>chaptererror();</script>', '')
        .split("<br>")
        .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
        .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
        .join('\n');
    var chapterText = new ChapterText();
    chapterText.text = content;
    if (content == null || content == '' || content.indexOf('正在努力手打中') != -1) {
      chapterText.valid = false;
    }
    return chapterText;
  }

  @override
  bool isBookDetailEmpty(String data) {
    if (data == null) return true;
    if (data.indexOf('你似乎来到了没有存在的地址') != -1) return true;
    return false;
  }
}
