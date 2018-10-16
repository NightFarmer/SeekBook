import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:seek_book/globals.dart' as Globals;
//import 'package:http/http.dart'  as http;

abstract class BookSite {
  bookDetail(name, author, url, [onFindExist]) async {
//    print("请求书籍详情  $name");
//    var name = this.bookInfo['name'];
//    var author = this.bookInfo['author'];
//    var url = this.bookInfo['url'];

    var database = Globals.database;

    var exist = await database.rawQuery(
      'select * from Book where name=? and author=?',
      [name, author],
    );
    if (onFindExist != null) {
      onFindExist(exist);
    }

//    print("书籍详情网络已返回0  $name  $url");
    Dio dio = new Dio();
    Response response = await dio.get(
      url,
      options: Options(
        connectTimeout: 5000,
        receiveTimeout: 5000,
      ),
    );
//    print("书籍详情网络已返回1  $name");
    var document = parse(response.data);
//    print("书籍详情网络已返回2  $name");
    var imgUrl = parseBookImage(document, url);
//    print(imgUrl);
    var currentUpdateTime = parseUpdateTime(document, url);

    var chapters;
    Map<String, dynamic> bookInfo = {
      "name": name,
      "author": author,
      "imgUrl": imgUrl,
      "url": url,
      "site": 'www',
      "updateTime": currentUpdateTime,
      "currentPageIndex": 0,
      "currentChapterIndex": 0,
      "active": 0,
      "chapterList": [],
      "hasNew": 0,
    };
    if (exist.length > 0) {
      bookInfo["currentPageIndex"] = exist[0]["currentPageIndex"];
      bookInfo["currentChapterIndex"] = exist[0]["currentChapterIndex"];
    }
    if (exist.length > 0 && currentUpdateTime == exist[0]["updateTime"]) {
      bookInfo = {
        "name": exist[0]["name"],
        "author": exist[0]["author"],
        "imgUrl": exist[0]["imgUrl"],
        "url": exist[0]["url"],
        "site": exist[0]["site"],
        "updateTime": exist[0]["updateTime"],
        "chapters": exist[0]["chapters"],
        "chapterList": json.decode(exist[0]["chapters"]),
        "currentPageIndex": exist[0]["currentPageIndex"],
        "currentChapterIndex": exist[0]["currentChapterIndex"],
        "active": exist[0]["active"],
        "hasNew": 0,
      };
      chapters = exist[0]["chapters"];
      print("存在相同时间戳缓存");
    } else {
      List chapterList = parseChapterList(document, url);
      chapters = json.encode(chapterList);
    }

    await database.transaction((txn) async {
      if (exist.length == 0) {
        bookInfo = {
          "name": name,
          "author": author,
          "imgUrl": imgUrl,
          "url": url,
          "site": 'www',
          "updateTime": currentUpdateTime,
          "chapters": chapters,
          "currentPageIndex": 0,
          "currentChapterIndex": 0,
          "active": 0,
          "hasNew": 0,
        };
        print("插入");
        await txn.insert('Book', bookInfo);
      } else if (currentUpdateTime != exist[0]["updateTime"]) {
        print("更新 ${currentUpdateTime}");
        bookInfo["imgUrl"] = imgUrl;
        bookInfo["updateTime"] = currentUpdateTime;
        bookInfo["chapters"] = chapters;
        bookInfo["hasNew"] = 1;
        await txn.update(
          'Book',
          {
            "imgUrl": imgUrl,
            "updateTime": currentUpdateTime,
            "chapters": chapters,
            "hasNew": 1,
          },
          where: "name=? and author=?",
          whereArgs: [name, author],
        );
      }
    });
    return bookInfo;
  }

  searchBook(String text);

  Future<String> parseChapter(String chapterUrl);

  List<Map> parseChapterList(Document document, String bookUrl);

  String parseBookImage(Document document, String bookUrl);

  int parseUpdateTime(Document document, String bookUrl);
}
