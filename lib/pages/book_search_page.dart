import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/kenwen.dart';
import 'package:seek_book/components/book_img.dart';
import 'package:seek_book/components/clickable.dart';
import 'package:seek_book/components/top_bar.dart';
import 'package:seek_book/pages/book_detail_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:dio/dio.dart';

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
    var theme = Theme.of(context);
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
        color: Color(0x00FFFFFF),
        padding: EdgeInsets.all(dp(10)),
        child: Row(
          children: <Widget>[
            Container(
              child: BookImg(
                imgUrl: item['imgUrl'],
                width: dp(60),
              ),
              margin: EdgeInsets.only(right: dp(10)),
            ),
//            Text('${item['name']}--- ${item['author']}')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: dp(18),
                      color: Color(0xFF333333),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: dp(8)),
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
                Text("${item['kind']}"),
                Text("${item['lastChapter']}"),
              ],
            )
          ],
        ),
      ),
    );
  }

  void searchBook() async {
    if (_controller.text.isNotEmpty) {
      var resultList = await BookSiteKenWen().searchBook(_controller.text);
      setState(() {
        this.resultList = resultList;
      });
    } else {
      var resultList = await BookSiteKenWen().searchBook("最强装逼");
      setState(() {
        this.resultList = resultList;
      });
    }
  }
}
