import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/kenwen.dart';
import 'package:seek_book/components/book_img.dart';
import 'package:seek_book/components/clickable.dart';
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

  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    this.bookInfo = widget.bookInfo;
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    var imgWidth = 80;
    var body = Column(
      children: <Widget>[
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
        BookImg(
          imgUrl: imgUrl,
          width: dp(80),
        ),
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
        PhysicalModel(
          color: Colors.white,
          elevation: dp(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Clickable(
                  onClick: toggleToSave,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/add_read.png',
                          width: dp(24),
                          height: dp(24),
                          color: Color(0xFF333333),
                        ),
                        Text(
                          "${bookActive == 1 ? '取消追书' : '加入追书'}", //已加入追书
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: dp(14),
                          ),
//                        style: TextStyle(color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: dp(8)),
                  color: Theme.of(context).primaryColor,
                  child: Clickable(
                    onClick: () {
                      startReadFromChapter(
                        bookInfo["currentChapterIndex"],
                        bookInfo["currentPageIndex"],
                      );
                    },
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/start_read.png',
                            width: dp(25),
                            height: dp(25),
                            color: Color(0xFFffffff),
                          ),
                          Text(
                            '开始阅读',
                            style: TextStyle(
                              color: Color(0xFFffffff),
                              fontSize: dp(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Clickable(
                  child: Container(
//                  child: Text('章节倒序'),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/change_read.png',
                          width: dp(24),
                          height: dp(24),
                          color: Color(0xFF333333),
                        ),
                        Text(
                          '切换书源',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: dp(14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: TopBar(
        title: bookInfo['name'],
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext _scaffoldContext) {
        this._scaffoldContext = _scaffoldContext;
        return body;
      }),
    );
  }

  Widget buildRow(context, index) {
    index = orderBy == 0 ? index : (chapterList.length - 1 - index);
    var item = chapterList[index];
    return GestureDetector(
      onTap: () {
        startReadFromChapter(index);
      },
      child: Text("${item['title']}"),
    );
  }

  void loadData([local = false]) async {
    var name = this.bookInfo['name'];
    var author = this.bookInfo['author'];
    var url = this.bookInfo['url'];
    imgUrl = this.bookInfo['imgUrl'];
    var bookInfo =
        await BookSiteKenWen().bookDetail(name, author, url, (exist) {
      if (exist.length > 0) {
        setState(() {
          bookActive = exist[0]['active'] ?? 0;
          imgUrl = exist[0]['imgUrl'];
          this.bookInfo["currentPageIndex"] = exist[0]['currentPageIndex'];
          this.bookInfo["currentChapterIndex"] =
              exist[0]['currentChapterIndex'];
        });
      } else {
        setState(() {
          bookActive = 0;
        });
      }
    });
    if (local) return;

    if (!mounted) return;
    setState(() {
      if (bookInfo != null) {
        this.imgUrl = bookInfo['imgUrl'];
        this.updateTime = bookInfo['updateTime'];
//        this.chapterList = json.decode(bookInfo['chapters']);
        this.chapterList = bookInfo['chapterList'];
        bookInfo['author'] = author;
        this.bookInfo = bookInfo;
        if (chapterList == null || chapterList.length == 0) {
          showSnack("书籍章节数量为0，请尝试切换书源。");
        }
      } else {
        print("查询失败，书籍不存在，请尝试切换书源。");
        showSnack("查询失败，书籍不存在，请尝试切换书源。");
      }
    });

//    var encode = json.encode(chapterList);
//    print(encode);
//    print(json.decode(encode));
  }

  startReadFromChapter([chapterIndex = 0, pageIndex = 0]) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ReadPage(
              bookInfo: {
                'id': bookInfo['id'],
                'name': bookInfo['name'],
                'author': bookInfo['author'],
                'url': bookInfo['url'],
                'updateTime': bookInfo['updateTime'],
                'imgUrl': bookInfo['imgUrl'],
//                  'chapterList': json.decode(bookInfo['chapters']),
                'chapterList': bookInfo['chapterList'],
                'site': bookInfo['site'],
                'currentPageIndex': pageIndex,
                'currentChapterIndex': chapterIndex,
              },
            ),
      ),
    );
    StatusBar.show();
    loadData(true);
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
      print('name $name, author $author, newState $newState');
      setState(() {
        bookActive = newState;
      });
    });
  }

  showSnack(String msg) {
    Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
      content: Text(msg),
      action: SnackBarAction(
          label: '确定',
          onPressed: () {
//            Scaffold.of(context).showSnackBar(SnackBar(
//                content: Text('You pressed snackbar $thisSnackBarIndex\'s action.')
//            ));
          }),
    ));
  }
}
