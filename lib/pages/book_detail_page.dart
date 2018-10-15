import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/kenwen.dart';
import 'package:seek_book/components/top_bar.dart';
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

  var orderBy = 0;

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
      appBar: TopBar(),
      body: Column(
        children: <Widget>[
          SafeArea(child: Text("xxx")),
          Container(
            child: Text('${bookInfo['name']}'),
          ),
          Container(
            child: Text('${bookInfo['author']}'),
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
          GestureDetector(
            onTap: () {
              setState(() {
                orderBy = (orderBy + 1) % 2;
              });
            },
            child: Text("倒序"),
          ),
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
    index = orderBy == 0 ? index : (chapterList.length - 1 - index);
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

    var bookInfo = await BookSiteKenWen().bookDetail(name, author, url, (exist) {
      if (exist.length > 0) {
        setState(() {
          bookActive = exist[0]['active'] ?? 0;
        });
      } else {
        bookActive = 0;
      }
    });

    if (!mounted) return;
    setState(() {
      this.imgUrl = bookInfo['imgUrl'];
      this.updateTime = bookInfo['updateTime'];
      this.chapterList = json.decode(bookInfo['chapters']);
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
