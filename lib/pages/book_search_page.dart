import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seek_book/book_site/book_site.dart';
import 'package:seek_book/book_site/book_source.dart';
import 'package:seek_book/components/book_img.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/components/top_bar.dart';
import 'package:seek_book/pages/book_detail_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/globals.dart' as Globals;

class BookSearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _BookSearchPageState();
  }
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _controller = new TextEditingController();

  List resultList = [];

  @override
  Widget build(BuildContext context) {
    var leftButton = Clickable(
      onClick: () {
        Navigator.pop(context);
      },
      child: Container(
//        color: Colors.grey,
        child: Container(
          child: Image.asset(
            'assets/images/ab_back.png',
            width: dp(25),
            height: dp(25),
          ),
          width: dp(60),
          height: dp(55),
          alignment: Alignment.center,
          color: Color(0x00ffffff),
        ),
        alignment: Alignment.center,
      ),
    );
    var rightButton = Clickable(
      onClick: () {
        searchBook();
      },
      child: Container(
        child: Container(
          child: Image.asset(
            'assets/images/ic_action_search.png',
            width: dp(40),
            height: dp(40),
          ),
          width: dp(60),
          height: dp(55),
          alignment: Alignment.center,
          color: Color(0x00ffffff),
        ),
      ),
    );
    return Scaffold(
      appBar: TopBar(
        child: Container(
          height: dp(55),
          child: Row(
            children: <Widget>[
              leftButton,
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    fontSize: dp(17),
                    color: Color(0xFFffffff),
                  ),
                  decoration: InputDecoration(
                    hintText: "搜索书名或者作者",
                    hintStyle: TextStyle(
                      fontSize: dp(17),
                      color: Color(0x99ffffff),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: dp(4.0)),
                  ),
                ),
              ),
              rightButton,
            ],
          ),
        ),
      ),
//      body: ListView.builder(
//        itemBuilder: buildRow,
//        itemCount: resultList.length,
//      ),
      body: ListView(
        children: ListTile.divideTiles(
          tiles: resultList.map((item) => buildRow(context, item)).toList(),
          context: context,
        ).toList(),
      ),
    );
  }

//  Widget buildRow(context, int) {
  Widget buildRow(context, item) {
//    var item = resultList[int];
//    var theme = Theme.of(context);
    return Clickable(
      pressedOpacity: 0.4,
      onClick: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BookDetailPage(bookInfo: item),
          ),
        );
      },
      child: Container(
        height: dp(130),
        color: Color(0x00FFFFFF),
        padding: EdgeInsets.all(dp(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: BookImg(
                imgUrl: item['imgUrl'],
                width: dp(70),
              ),
              margin: EdgeInsets.only(right: dp(10)),
            ),
//            Text('${item['name']}--- ${item['author']}')
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      item['name'] + " - ${item['source'].length}个书源",
                      style: TextStyle(
                        fontSize: dp(18),
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    margin: EdgeInsets.only(bottom: dp(5)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Image.asset(
                          'assets/images/author_icon.png',
                          width: dp(13),
                          height: dp(13),
//                      color: theme.primaryColor,
                          color: Color(0xFF999999),
                        ),
                        margin: EdgeInsets.only(right: dp(5)),
                      ),
                      Text(
                        item['author'],
                        style: TextStyle(
                          fontSize: dp(14),
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFff0000).withOpacity(0.4),
                      borderRadius: BorderRadius.all(Radius.circular(dp(4))),
                    ),
                    margin: EdgeInsets.symmetric(vertical: dp(3)),
                    padding: EdgeInsets.symmetric(
                      vertical: dp(2),
                      horizontal: dp(5),
                    ),
                    child: Text(
                      "${(item['kind'] == null || item['kind'] == '') ? "其他" : item['kind']}",
                      style: TextStyle(
                        fontSize: dp(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "${item['lastChapter']}",
                    style: TextStyle(
                      fontSize: dp(14),
                      color: Color(0xFF999999),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  var localBook=[];

  void searchBook() async {
    List<Map> list = await Globals.database.rawQuery(
        'SELECT * FROM Book where active=? order by updateTime desc', [1]);
    localBook = list.map((it) {
      return {
        'id': it['id'],
        'name': it['name'],
        'author': it['author'],
        'url': it['url'],
        'updateTime': it['updateTime'],
        'imgUrl': it['imgUrl'],
        'chapterList':
            it['chapters'] == null ? [] : json.decode(it['chapters']),
        'site': it['site'],
        'currentPageIndex': it['currentPageIndex'],
        'currentChapterIndex': it['currentChapterIndex'],
        'active': it['active'],
        'hasNew': it['hasNew'],
      };
    }).toList();

    setState(() {
      this.resultList = [];
    });

    if (_controller.text.isNotEmpty) {
      var bookSource = BookSource;
      bookSource.forEach((siteRule) {
        BookSite().searchBook(_controller.text, siteRule).then((result) {
          appendResult(result);
        });
      });
    } else {
      var bookSource = BookSource;
      bookSource.forEach((siteRule) {
//        BookSite().searchBook("最强装逼", siteRule).then((result) {
        BookSite().searchBook("大王饶命", siteRule).then((result) {
//        BookSite().searchBook("全球高武", siteRule).then((result) {
          appendResult(result);
        });
      });
    }
  }

  void appendResult(result) {
    print('result');
    print(result.runtimeType);
    result.forEach((book) {
      var resultHasBook = false;
      for (int i = 0; i < this.resultList.length; i++) {
        var exist = this.resultList[i];
        if (book['name'] == exist['name'] &&
            book['author'] == exist['author']) {
          //增加书源结果
//          print('列表存在，增加书源结果');
          exist['source'].add(book);
          if (book['chapterList'] != null &&
              book['chapterList'].length > exist['chapterList'].length) {
            exist['chapterList'] = book['chapterList'];
            exist['chapters'] = book['chapters'];
            exist['url'] = book['url'];
          }
          if (exist['imgUrl'] == null && book['imgUrl'] != null) {
            exist['imgUrl'] = book['imgUrl'];
          }
          if (exist['kind'] == null && book['kind'] != null) {
            exist['kind'] = book['kind'];
          }
          resultHasBook = true;
          break;
        }
      }
      if (!resultHasBook) {
//        print('列表不存在，增加');
        book['source'] = [book];
        this.resultList.add(book);
      }
      this.resultList.sort((b, a) => (a['source'].length - b['source'].length));

      setState(() {});
    });
  }
}
