import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/main.dart';
import 'package:seek_book/globals.dart' as Globals;
import 'package:seek_book/pages/read_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';
import 'package:sqflite/sqflite.dart';

class BookDetailPage extends StatefulWidget {
  final Map bookInfo;

  BookDetailPage({Key key, @required this.bookInfo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _BookDetailState();
  }
}

class _BookDetailState extends State<BookDetailPage> {
  var imgUrl = "";
  var updateTime = 0;
  var chapterList = [];
  var bookActive = 0;

  Map bookInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.bookInfo = widget.bookInfo;
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SafeArea(child: Text("xxx")),
          Container(
            child: Text('${bookInfo['name']}'),
          ),
          GestureDetector(
            onTap: () {
              toggleToSave();
            },
            child: Text("${bookActive == 1 ? '取消' : '追书'}"),
          ),
          GestureDetector(
            onTap: () {},
            child: Text('阅读'),
          ),
          imgUrl != ''
              ? Image.network(
                  imgUrl,
                  width: dp(100),
                )
              : Text("封面"),
          Text('追书状态：$bookActive'),
          Expanded(
            child: ListView.builder(
              itemBuilder: buildRow,
              itemCount: chapterList.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(context, index) {
    var item = chapterList[index];
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ReadPage(bookInfo: {
                  'id': bookInfo['id'],
                  'name': bookInfo['name'],
                  'author': bookInfo['author'],
                  'url': bookInfo['url'],
                  'updateTime': bookInfo['updateTime'],
                  'imgUrl': bookInfo['imgUrl'],
                  'chapterList': json.decode(bookInfo['chapters']),
                  'site': bookInfo['site'],
                  'currentPageIndex': 0,
                  'currentChapterIndex': index,
                }),
          ),
        );
        StatusBar.show();
//        loadData();
      },
      child: Text("${item['title']}"),
    );
  }

  void loadData() async {
    var name = this.bookInfo['name'];
    var author = this.bookInfo['author'];
    var url = this.bookInfo['url'];

    var database = Globals.database;

    var exist = await database.rawQuery(
      'select * from Book where name=? and author=?',
      [name, author],
    );
    if (exist.length > 0) {
      setState(() {
        bookActive = exist[0]['active'];
      });
    }

    Dio dio = new Dio();
    Response response = await dio.get(url);
    var document = parse(response.data);
    var imgUrl = 'http://www.kenwen.com' +
        document.querySelector('#fmimg img').attributes['src'];
    print(imgUrl);
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
    print(dateTime);

    var chapters;
    Map<String, dynamic> bookInfo;
    if (exist.length > 0 &&
        dateTime.millisecondsSinceEpoch == exist[0]["updateTime"]) {
      bookInfo = {
        "name": exist[0]["name"],
        "author": exist[0]["author"],
        "imgUrl": exist[0]["imgUrl"],
        "url": exist[0]["url"],
        "site": exist[0]["site"],
        "updateTime": exist[0]["updateTime"],
        "chapters": exist[0]["chapters"],
        "currentPageIndex": exist[0]["currentPageIndex"],
        "currentChapterIndex": exist[0]["currentChapterIndex"],
      };
    } else {
      List chapterList = [];
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
            'url': url + chapterRow.attributes['href'],
          });
        }
      });
      print(chapterList);
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
          "updateTime": dateTime.millisecondsSinceEpoch,
          "chapters": chapters,
          "currentPageIndex": 0,
          "currentChapterIndex": 0,
        };
        await txn.insert('Book', bookInfo);
      } else if (dateTime.millisecondsSinceEpoch != exist[0]["updateTime"]) {
        bookInfo["imgUrl"] = imgUrl;
        bookInfo["updateTime"] = dateTime.millisecondsSinceEpoch;
        bookInfo["chapters"] = chapters;
        await txn.update(
          'Book',
          {
            "imgUrl": imgUrl,
            "updateTime": updateTime,
            "chapters": chapters,
          },
          where: "name=? and author=?",
          whereArgs: [name, author],
        );
      }
    });

    setState(() {
      this.imgUrl = imgUrl;
      this.updateTime = dateTime.millisecondsSinceEpoch;
      this.chapterList = chapterList;
      this.bookInfo = bookInfo;
    });

//    var encode = json.encode(chapterList);
//    print(encode);
//    print(json.decode(encode));
  }

  void toggleToSave() async {
    var name = bookInfo['name'];
    var author = bookInfo['author'];

    var database = Globals.database;

    await database.transaction((txn) async {
      var newState = (bookActive + 1) % 2;
      await txn.update(
        'Book',
        {
          'active': newState,
        },
        where: 'name=? and author=?',
        whereArgs: [name, author],
      );
      setState(() {
        bookActive = newState;
      });
    });
  }
}
