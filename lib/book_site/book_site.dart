import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart';
import 'package:seek_book/book_site/kenwen.dart';
import 'package:seek_book/globals.dart' as Globals;
import 'package:sqflite/sqflite.dart';
//import 'package:http/http.dart'  as http;

abc() {}

abstract class BookSite {
  Future sendReceive(SendPort port, msg) {
    ReceivePort response = new ReceivePort();
    port.send([msg, response.sendPort]);
    return response.first;
  }

  runOnIsoLate(instance, functionName, param) async {
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(_onIsoLate, receivePort.sendPort);

    // The 'echo' isolate sends it's SendPort as the first message
    SendPort sendPort = await receivePort.first;

    var result = await sendReceive(sendPort, {
      'instance': instance,
      'functionName': functionName,
      'param': param,
    });
    return result;
  }

  static _onIsoLate(SendPort sendPort) async {
    // Open the ReceivePort for incoming messages.
    ReceivePort port = new ReceivePort();

    // Notify any other isolates what port this isolate listens to.
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      var data = msg[0];
      SendPort replyTo = msg[1];
      var instance = data['instance'];
      var functionName = data['functionName'];
      var param = data['param'];
      switch (functionName) {
        case 'parseBookDetail':
          var result = await instance.parseBookDetail(param);
          replyTo.send(result);
          return;
        case 'parseChapterText':
          var result = await instance.parseChapterText(param);
          replyTo.send(result);
          return;
      }
      replyTo.send(null);
      return;
    }
  }

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
    Response response;
    try {
      response = await dio.get(
        url,
        options: Options(
          connectTimeout: 5000,
          receiveTimeout: 5000,
        ),
      );
    } catch (e) {
      print(e);
      return null;
    }
    var bookDetail = await runOnIsoLate(this, 'parseBookDetail', {
      'data': response.data,
      'url': url,
    });
    var imgUrl = bookDetail['imgUrl'];
    var currentUpdateTime = bookDetail['updateTime'];

//    String chapters;
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
      "chapters": '[]',
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
        "chapterList": exist[0]["chapters"] == null
            ? []
            : json.decode(exist[0]["chapters"]),
        "currentPageIndex": exist[0]["currentPageIndex"],
        "currentChapterIndex": exist[0]["currentChapterIndex"],
        "active": exist[0]["active"],
        "hasNew": exist[0]["hasNew"],
      };
      print("存在相同时间戳缓存");
    } else {
//      List chapterList = parseChapterList(document, url);
//      chapters = json.encode(chapterList);
//      List chapterList = bookDetail['chapterList'];
      bookInfo['chapters'] = bookDetail['chapters'];
      bookInfo['chapterList'] = bookDetail['chapterList'];
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
          "chapters": bookDetail['chapters'],
          "currentPageIndex": 0,
          "currentChapterIndex": 0,
          "active": 0,
          "hasNew": 0,
        };
        print("插入");
        await txn.insert('Book', bookInfo);
        bookInfo["chapterList"] = bookDetail['chapterList'];
      } else if (currentUpdateTime != exist[0]["updateTime"]) {
        print("更新 ${currentUpdateTime}");
        bookInfo["imgUrl"] = imgUrl;
        bookInfo["updateTime"] = currentUpdateTime;
        bookInfo["hasNew"] = 1;
        await txn.update(
          'Book',
          {
            "imgUrl": imgUrl,
            "updateTime": currentUpdateTime,
            "chapters": bookInfo["chapters"],
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

  Future<String> parseChapterText(param);

  List<Map> parseChapterList(Document document, String bookUrl);

  String parseBookImage(Document document, String bookUrl);

  int parseUpdateTime(Document document, String bookUrl);

  Future<String> parseChapter(String chapterUrl) async {
    Dio dio = new Dio();
//    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
    Response response = await dio.get(chapterUrl);
    var chapterText = await runOnIsoLate(this, 'parseChapterText', {
      'chapterUrl': chapterUrl,
      'data': response.data,
    });
    await Globals.database.transaction((txn) async {
      List<Map> existData = await txn
          .rawQuery('select text from chapter where id = ?', [chapterUrl]);
      if (existData.length > 0) {
        return existData[0]['text'];
      }
      await txn.insert('chapter', {
        "id": chapterUrl,
        "text": chapterText,
      });
    });
    return chapterText;
  }

  Future<Map> parseBookDetail(param) async {
    var document = parse(param['data']);
    var imgUrl = parseBookImage(document, param['url']);
    var updateTime = parseUpdateTime(document, param['url']);
    var chapterList = parseChapterList(document, param['url']);

    return {
      "updateTime": updateTime,
      "imgUrl": imgUrl,
      "chapters": jsonEncode(chapterList),
      "chapterList": chapterList,
    };
  }
}
