import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/main.dart';
import 'package:seek_book/globals.dart' as Globals;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SafeArea(child: Text("xxx")),
          Container(
            child: Text('${widget.bookInfo['name']}'),
          ),
          GestureDetector(
            onTap: () {
              toggleToSave();
            },
            child: Text("追书"),
          ),
          GestureDetector(
            onTap: () {},
            child: Text('阅读'),
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
    var item = chapterList[index];
    return GestureDetector(
      child: Text("${item['title']}"),
    );
  }

  void loadData() async {
    Dio dio = new Dio();
    var url = 'http://www.kenwen.com/cview/17/17265/';
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

    setState(() {
      this.imgUrl = imgUrl;
      this.updateTime = dateTime.millisecondsSinceEpoch;
      this.chapterList = chapterList;
    });

//    var encode = json.encode(chapterList);
//    print(encode);
//    print(json.decode(encode));
  }

  void toggleToSave() async {
    print('1');
    var name = widget.bookInfo['name'];
    var author = widget.bookInfo['author'];
    var url = widget.bookInfo['url'];
    print(name);
    print(author);
    print(url);
    print(updateTime);
    var chapterList = json.encode(this.chapterList);
    print(chapterList);
    print(imgUrl);
    print('啃文书库');

    var database = Globals.database;
    List<Map> list = await database.rawQuery('SELECT * FROM Book');
    print(list);

    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Book(name, author, imgUrl, url,site,updateTime,chapters,currentPageIndex,currentChapterIndex) VALUES("$name", "$author", "$imgUrl", "$url", "www", "$updateTime", \'${chapterList}\',0,0)');
      print("inserted1: $id1");
    });
//    name TEXT, author TEXT, chapters Text, url Text, site Text, updateTime long,

//// Update some record
//    int count = await database.rawUpdate(
//        'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
//        ["updated name", "9876", "some name"]);
//    print("updated: $count");
// Count the records
//    count = Sqflite.firstIntValue(
//        await database.rawQuery("SELECT COUNT(*) FROM Test"));
////    assert(count == 2);
//
//// Delete a record
//    count = await database
//        .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
////    assert(count == 1);
  }
}
