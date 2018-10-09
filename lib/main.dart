import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:seek_book/pages/main_page.dart';
import 'package:seek_book/utils/battery.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:sqflite/sqflite.dart';

import 'pages/read_page.dart';

import 'package:seek_book/globals.dart' as Globals;

void main() {
  Battery.init();
  return runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
//  Database database;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  void initData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "seek_book.db");

//     Delete the database
//    await deleteDatabase(path);

    var database = await openDatabase(
      path,
      version: Globals.db_version,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
          "CREATE TABLE Book (id INTEGER PRIMARY KEY, name TEXT, author TEXT, chapters Text, url Text, site Text, updateTime long, imgUrl Text, currentPageIndex INTEGER,currentChapterIndex INTEGER,active int)",
        );
        await db
            .execute('create table chapter (id String primary key, text text)');
      },
    );

    List<Map> list = await database.rawQuery('SELECT * FROM Book');
    print(list);
    Globals.database = database;
  }

  @override
  Widget build(BuildContext context) {
//    ScreenAdaptation.designSize = 414.0;
//    ScreenAdaptation.init(context);

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        platform: TargetPlatform.android,
//        fontFamily: "ReadFont",
      ),
      home: new MainPage(),
//      home: new WindowSizeQuery(),
//      routes: {
//        '/': (context) => MainPage(),
//        '/read': (context) => ReadPage(),
//        '/search': (context) => BookSearchPage(),
//      },
//      initialRoute: '/',
    );
  }
}

//class WindowSizeQuery extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    ScreenAdaptation.designSize = 414.0;
//    ScreenAdaptation.init(context);
//    return new ReadPage();
//  }
//}
