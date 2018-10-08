import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
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
    return Scaffold(
      body: Column(
        children: <Widget>[
          SafeArea(child: Text('111')),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text("back"),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    fontSize: dp(14.5),
                    color: Color(0xFF666666),
                  ),
                  decoration: InputDecoration(
                    hintText: "搜索书名或者作者",
                    hintStyle: TextStyle(
                      fontSize: dp(14.5),
                      color: Color(0xFF999999),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: dp(4.0)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print(_controller.text);
                  searchBook();
                },
                child: Text("搜索"),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: buildRow,
              itemCount: resultList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildRow(context, int) {
    var item = resultList[int];
    return GestureDetector(
      onTap: () {
//        Navigator.pushNamed(context, '/bookDetail');
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BookDetailPage(bookInfo: item),
          ),
        );
      },
      child: Text('${item['name']}'),
    );
  }

  void searchBook() async {
    Dio dio = new Dio();
    var book = '逆天邪神';
    var url = 'https://sou.xanbhx.com/search?siteid=kenwencom&q=${book}';
    Response response = await dio.get(url);
    var document = parse(response.data);
    var querySelector = document.querySelectorAll('ul li');
    var resultList = querySelector
        .where((it) => it.querySelector('.s1').text != '作品分类')
        .map((row) {
      var bookLink = row.querySelector('.s2 a');
      var name = bookLink.text;
      var url = bookLink.attributes['href'];
      var author = row.querySelector('.s4').text;
      return {
        "name": name,
        "url": url,
        "author": author,
      };
    }).toList();
    print(resultList);
    setState(() {
      this.resultList = resultList;
    });
  }
}
