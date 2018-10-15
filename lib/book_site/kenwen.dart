import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/book_site.dart';
import 'package:seek_book/globals.dart' as Globals;

class BookSiteKenWen extends BookSite {
  final String site = '啃文书库';

  searchBook(String text) async {
    Dio dio = new Dio();
    var book = text ?? '逆天邪神';
    var url = 'https://sou.xanbhx.com/search?siteid=kenwencom&q=${book}';
    Response response = await dio.get(url);
    var document = parse(response.data);
    var querySelector = document.querySelectorAll('ul li');
    var resultList = querySelector
        .where((it) => it.querySelector('.s1').text != '作品分类')
        .map((row) {
      var bookLink = row.querySelector('.s2 a');
      var name = bookLink.text.trim();
      var url = bookLink.attributes['href'].trim();
      var author = row.querySelector('.s4').text.trim();
      return {
        "name": name,
        "url": url,
        "author": author,
      };
    }).toList();
//    print(resultList);
    return resultList;
  }

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
    print(updateTimeStr);
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
  Future<String> parseChapter(String chapterUrl) async {
    String content = '';
    //      await Future.delayed(Duration(milliseconds: 5000));
    Dio dio = new Dio();
//    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
    Response response = await dio.get(chapterUrl);
    var document = parse(response.data);
    content = document.querySelector('#content').innerHtml;
    content = content
        .replaceAll('<script>chaptererror();</script>', '')
        .split("<br>")
        .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
        .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
        .join('\n');
    await Globals.database.transaction((txn) async {
      List<Map> existData = await txn
          .rawQuery('select text from chapter where id = ?', [chapterUrl]);
      if (existData.length > 0) {
        return existData[0]['text'];
      }
      await txn.insert('chapter', {
        "id": chapterUrl,
        "text": content,
      });
    });
    return content;
  }
}
