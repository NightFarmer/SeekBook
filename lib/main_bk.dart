import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as HtmlDom;
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:sqflite/sqflite.dart';

void main2222() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
//      home: new MyHomePage2(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String text = "";

  Database database;

  List<int> pageEndIndexList;
  int pageIndex = 0;
  String content = "";

  var ReadTextWidth;

  var ReadTextheight;

  @override
  void initState() {
    // TODO: implement initState
    this.initDb();
    ScreenAdaptation.designSize = 500.0;

    ReadTextWidth = dp(500);
    ReadTextheight = dp(500);

    super.initState();
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

// Delete the database
    await deleteDatabase(path);

// open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
    });
  }

  void _incrementCounter() async {
//    var httpClient = new HttpClient();
//    var uri = new Uri.
//    var request = await httpClient.getUrl()

//    await htmlParseDemo();

//    for (var i = 0; i < 100; i++) {
//      await sqliteDemo();
//    }

//    dateTimeDemo();

    await chapterParse();

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      _counter++;
    });
  }

  Future chapterParse() async {
    Dio dio = new Dio();
    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
    Response response = await dio.get(url);
    var document = parse(response.data);
    var content = document.querySelector('#content').innerHtml;
//    print(content);
    content = content
        .split("<br>")
        .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
        .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
        .join('\n');
//    print(content);
//    setState(() {
//      text = content;
//    });
//    content = "123456";
    var pageEndIndexList = parseChapterPager(content);
    print(pageEndIndexList);
    print("页数 ${pageEndIndexList.length}");
    this.pageEndIndexList = pageEndIndexList;

    setState(() {
      text = content.substring(0, this.pageEndIndexList[pageIndex]);
    });
    this.content = content;
  }

  // parse hole
  List<int> parseChapterPager(String content) {
    List<int> pageEndPointList = List();
    do {
      var contentNeedToParse = content;
      var prePageEnd = 0;
      if (pageEndPointList.length > 0) {
        prePageEnd = pageEndPointList[pageEndPointList.length - 1];
        contentNeedToParse = content.substring(
          prePageEnd,
          min(prePageEnd + pageEndPointList[0] * 2, content.length),
        );
//        contentNeedToParse = content.substring(prePageEnd);
      }
      pageEndPointList.add(prePageEnd + getOnePageEnd(contentNeedToParse));
    } while (pageEndPointList.length == 0 ||
        pageEndPointList[pageEndPointList.length - 1] != content.length);

    return pageEndPointList;
  }

  void dateTimeDemo() {
//    DateTime.parse("2018-04-22 21:13:15");

//    DateTime.parse("+20180422");

    var dateTime = new DateTime.now();
    print(dateTime.year);
    print(dateTime.month);
    print(dateTime.day);
    print(dateTime.hour);
    print(dateTime.minute);
    print(dateTime.second);
    print(dateTime);

    new DateTime(2018, 4, 22);
    print(new DateTime(2018, 4, 22));

    //    DateTime.parse("2018-04-22 21:13:15");

    //    DateTime.parse("+20180422");
  }

  Future htmlParseDemo() async {
    //    var httpClient = new HttpClient();
    //    var uri = new Uri.
    //    var request = await httpClient.getUrl()

    Dio dio = new Dio();
    Response response =
        await dio.get("http://www.kenwen.com/cview/241/241355/");
    //    print(response.data);

    var document =
        parse('<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks!');

    document = parse(response.data);

    //    https://github.com/dart-lang/html/
    //    https://github.com/html5lib/html5lib-python
    //    https://html5lib.readthedocs.io/en/latest/
    //    var html = parse(response.body, encoding: "gb2312");
    //    var tipsRoot = html.querySelector("div.pingshu_ysts8_i");
    //    var items = tipsRoot.querySelectorAll("li.qx");
    //    items.forEach((f) {
    //      print(f.text);
    //    });
    //    print(document.outerHtml);
    //    print(document.querySelector('a').outerHtml);
    //    print(document.querySelector('a').text);
    //    print(document.querySelector('a').attributes["href"]);
    var chapterRowList = document.querySelector('div#list dl').children;
    var currentRowIndex = 0;
    var groupIndex = 0;
    //    List<HtmlDom.Element> chapterList = new List();
    List chapterList = new List();
    chapterRowList.forEach((el) {
      var isGroupTitle = el.children.length == 0;
      if (isGroupTitle) {
        groupIndex++;
      }
      if (groupIndex > 1 && !isGroupTitle) {
        //        chapterList.add(el);
        chapterList.add({
          "title": el.children[0].text,
          "url": el.children[0].attributes['href'],
        });
      }
      currentRowIndex++;
    });
    print(chapterList);
  }

  Future sqliteDemo() async {
    // Get a location using getDatabasesPath

// Insert some records in a transaction
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
      print("inserted1: $id1");
      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ["another name", 12345678, 3.1416]);
      print("inserted2: $id2");
    });

// Update some record
    int count = await database.rawUpdate(
        'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
        ["updated name", "9876", "some name"]);
    print("updated: $count");

// Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
      {"name": "another name", "id": 2, "value": 12345678, "num": 3.1416}
    ];
    print(list);
    print(expectedList);
//    assert(const DeepCollectionEquality().equals(list, expectedList));

// Count the records
    count = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM Test"));
//    assert(count == 2);

// Delete a record
    count = await database
        .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
//    assert(count == 1);

// Close the database
//    await database.close();
  }

  var textStyle = new TextStyle(
      height: 1.1,
      fontSize: dp(20),
      fontFamily: 'ReadFont',
      textBaseline: TextBaseline.ideographic);

  @override
  Widget build(BuildContext context) {
    var text = content;
    if (text.length > 0) {
      if (this.pageEndIndexList.length > 1) {
        text = content.substring(
            pageIndex == 0 ? 0 : this.pageEndIndexList[pageIndex - 1],
            this.pageEndIndexList[pageIndex]);
      }
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${pageIndex}'),
            GestureDetector(
              onTap: () {
                if (pageIndex < pageEndIndexList.length - 1) {
                  setState(() {
                    pageIndex++;
                  });
                }
              },
              child: Text("+"),
            ),
            GestureDetector(
              onTap: () {
                if (pageIndex > 0) {
                  setState(() {
                    pageIndex--;
                  });
                }
              },
              child: Text("-"),
            ),
            Container(
              child: new Text(
//              '中文1234567890You have pushed the button this many times:',
                text,
                style: textStyle,
              ),
              height: ReadTextheight,
              width: ReadTextWidth,
              color: Colors.green.withOpacity(0.3),
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// 接收内容
  /// 追加内容返回false
  /// 计算完毕返回true
  int getOnePageEnd(String text) {
    if (layout(text)) {
//      return false;
      return text.length;
    }

    int start = 0;
    int end = text.length;
    int mid = (end + start) ~/ 2;

//    var time = 0;
    // 最多循环20次
    for (int i = 0; i < 20; i++) {
//      time++;
      if (layout(text.substring(0, mid))) {
        if (mid <= start || mid >= end) break;
        // 未越界
        start = mid;
        mid = (start + end) ~/ 2;
      } else {
        // 越界
        end = mid;
        mid = (start + end) ~/ 2;
      }
    }
//    print('循环次数 ${time}');
    return mid;
  }

  /// 计算待绘制文本
  /// 未超出边界返回true
  /// 超出边界返回false
  bool layout(String text) {
    text = text ?? '';
    var textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter
      ..text = getTextSpan(text)
//      ..layout(maxWidth: pageSize.width);
      ..layout(maxWidth: ReadTextWidth);
    return !didExceed(textPainter);
  }

  /// 是否超出边界
  bool didExceed(textPainter) {
    return textPainter.didExceedMaxLines ||
        textPainter.size.height > ReadTextheight;
  }

//  bool get didExceed {
//    return textPainter.didExceedMaxLines ||
////        textPainter.size.height > pageSize.height;
//        textPainter.size.height > ReadTextheight;
//  }

  /// 获取带样式的文本对象
  TextSpan getTextSpan(String text) {
//    if (text.startsWith('\n')) {
//      text = text.substring(1);
//    }
    // 判定时，移除可能是本页文本的最后一个换行符，避免造成超过一页
    if (text.endsWith('\n')) {
      text = text.substring(0, text.length - 1);
    }
    return new TextSpan(text: text, style: textStyle);
  }
}
