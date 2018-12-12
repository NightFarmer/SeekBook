import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seek_book/book_site/book_site.dart';
import 'package:seek_book/components/book_img.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/components/top_bar.dart';
import 'package:seek_book/globals.dart' as Globals;
import 'package:seek_book/pages/read_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';

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
    var body = Column(
      children: <Widget>[
        Stack(
          children: [
            Image.network(
              imgUrl,
              width: vw(100),
              height: dp(180),
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: new Container(
                color: Colors.black.withOpacity(0.5),
                width: vw(100),
                height: dp(180),
                child: Padding(
                  padding: EdgeInsets.all(dp(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      BookImg(
                        imgUrl: imgUrl,
                        width: dp(110),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: dp(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(bottom: dp(10)),
                                child: Text(
                                  '${bookInfo['name']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dp(24),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: dp(5)),
                                child: Text(
                                  '作者：${bookInfo['author']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dp(15),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: dp(5)),
                                child: Text(
//                                  '第一千二百七十八章 历史性的一幕',
                                  chapterList.length > 0
                                      ? '${chapterList[chapterList.length - 1]["title"]}'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dp(15),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: dp(5)),
                                padding:
                                    EdgeInsets.symmetric(horizontal: dp(3)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(dp(6))),
                                ),
                                child: Text(
                                  '玄幻小说',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dp(15),
                                  ),
                                ),
                              ),
//                              GestureDetector(
//                                onTap: () {
//                                  setState(() {
//                                    orderBy = (orderBy + 1) % 2;
//                                  });
//                                },
//                                child: Text("倒序"),
//                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
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
//        title: bookInfo['name'],
        title: "书籍详情",
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dp(10), vertical: dp(6)),
        child: Text(
          "${item['title']}",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: dp(17),
          ),
        ),
      ),
    );
  }

  void loadData([local = false]) async {
    var name = this.bookInfo['name'];
    var author = this.bookInfo['author'];
    var url = this.bookInfo['url'];
    imgUrl = this.bookInfo['imgUrl'];
    var siteRule = BookSite.findSiteRule(this.bookInfo['siteHost']);
    var bookInfo =
        await BookSite().bookDetail(name, author, url, siteRule, (exist) {
      if (exist.length > 0) {
        setState(() {
          bookActive = exist[0]['active'] ?? 0;
          imgUrl = exist[0]['imgUrl'];
//          this.bookInfo["siteName"] = exist[0]['siteName'];
//          this.bookInfo["siteHost"] = exist[0]['siteHost'];
          this.bookInfo["currentPageIndex"] = exist[0]['currentPageIndex'];
          this.bookInfo["currentChapterIndex"] =
              exist[0]['currentChapterIndex'];
        });
      } else {
        setState(() {
          bookActive = 0;
        });
      }
    }, imgUrl);
    if (local) return;

    if (!mounted) return;
    print("详情页，，， ${this.bookInfo["siteHost"]}");
    setState(() {
      if (bookInfo != null) {
        this.imgUrl = this.imgUrl ?? bookInfo['imgUrl'];
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
                'siteName': bookInfo['siteName'],
                'siteHost': bookInfo['siteHost'],
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
