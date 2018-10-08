import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:seek_book/pages/book_search_page.dart';
import 'package:seek_book/pages/read_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:seek_book/globals.dart' as Globals;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  List<Map> bookList = [];

  @override
  void initState() {
    super.initState();
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
//    ScreenAdaptation.designSize = 414.0;
//    ScreenAdaptation.init(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          SafeArea(child: Text('123123123')),
          Container(
            child: GestureDetector(
              onTap: () async {
//                Navigator.pushNamed(context, '/search');
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => BookSearchPage(),
                  ),
                );
                loadData();
              },
              child: Text('search'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: buildRow,
              itemCount: bookList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildRow(context, index) {
    var item = bookList[index];
    var latestChapter =
        item['chapterList'][item['chapterList'].length - 1]['title'];
    return new GestureDetector(
      onTap: () async {
//        print(item['currentPageIndex']);
//        return;
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ReadPage(bookInfo: item),
          ),
        );
        loadData();
      },
      child: Row(
        children: <Widget>[
          Text("${item['name']}"),
          Text("${latestChapter}"),
        ],
      ),
    );
  }

  void loadData() async {
//    var database = Globals.database;
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "seek_book.db");

    var database = await openDatabase(path);
    List<Map> list = await database.rawQuery('SELECT * FROM Book');
    list = list.map((it) {
      return {
        'id': it['id'],
        'name': it['name'],
        'author': it['author'],
        'url': it['url'],
        'updateTime': it['updateTime'],
        'imgUrl': it['imgUrl'],
        'chapterList': json.decode(it['chapters']),
        'site': it['site'],
        'currentPageIndex': it['currentPageIndex'],
        'currentChapterIndex': it['currentChapterIndex'],
      };
    }).toList();
    setState(() {
      bookList = list;
    });
  }
}
