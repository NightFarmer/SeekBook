import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:seek_book/pages/book_search_page.dart';
import 'package:seek_book/pages/read_page.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/utils/status_bar.dart';
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

    var scaffold = Container(
      color: Colors.red,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
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
        ),
      ),
    );
    //浅色状态栏文字
    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.light;
//    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle.dark;
    return new AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: scaffold,
      sized: false,
    );
//    return scaffold;
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
//        _scaffoldKey.currentState.showSnackBar(SnackBar(
//            content: Text('You selected: $value')
//        ));
      }
    });
  }

  void showRowChoice(context, Map item) {
    final ThemeData theme = Theme.of(context);
    var title = item['name'];
    print(item['currentChapterIndex']);
    showDemoDialog<String>(
      context: context,
      child: SimpleDialog(
        title: Container(
          padding: EdgeInsets.only(bottom: dp(20)),
          child: Text(
            '$title',
            style: TextStyle(fontSize: dp(17), color: theme.primaryColor),
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
        ),
        children: <Widget>[
          DialogRowItem(
            icon: Icons.account_circle,
            color: theme.primaryColor,
            text: '置顶',
            onPressed: () {
              Navigator.pop(context, 'username@gmail.com');
            },
          ),
          DialogRowItem(
            icon: Icons.account_circle,
            color: theme.primaryColor,
            text: '书籍详情',
            onPressed: () {
              Navigator.pop(context, 'user02@gmail.com');
            },
          ),
          DialogRowItem(
            icon: Icons.account_circle,
            color: theme.primaryColor,
            text: '删除',
            onPressed: () {
              Navigator.pop(context, 'user02@gmail.com');
              deleteBook(item);
            },
          ),
//              DialogDemoItem(
//                  icon: Icons.add_circle,
//                  text: 'add account',
//                  color: theme.disabledColor
//              )
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
        StatusBar.show();
        loadData();
      },
      onLongPress: () {
//        SimpleDialog
        showRowChoice(context, item);
      },
      child: Container(
        width: ScreenAdaptation.screenWidth,
        color: Colors.green.withOpacity(0.1),
        child: Row(
          children: <Widget>[
            Text("${item['name'].trim()}"),
            Expanded(
              child: Text("${latestChapter}"),
            ),
          ],
        ),
      ),
    );
  }

  void loadData() async {
//    var database = Globals.database;
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "seek_book.db");

    var database = await openDatabase(path);
    List<Map> list =
        await database.rawQuery('SELECT * FROM Book where active=?', [1]);
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

  void deleteBook(Map item) async {
    await Globals.database.update(
      'Book',
      {'active': false},
      where: 'name=? and author=?',
      whereArgs: [item['name'], item['author']],
    );
    this.loadData();
  }
}

class DialogRowItem extends StatelessWidget {
  const DialogRowItem(
      {Key key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
//          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
