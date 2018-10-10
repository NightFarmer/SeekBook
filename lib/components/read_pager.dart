// 翻页阅读容器组件

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:seek_book/components/read_option_layer.dart';
import 'package:seek_book/components/read_pager_item.dart';
import 'package:seek_book/components/text_canvas.dart';
import 'package:seek_book/utils/screen_adaptation.dart';
import 'package:seek_book/globals.dart' as Globals;

class ReadPager extends StatefulWidget {
  Map bookInfo;
  final GlobalKey<ReadOptionLayerState> optionLayerKey;

  ReadPager({
    Key key,
    @required this.bookInfo,
    this.optionLayerKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReadPagerState();
  }
}

int maxInt = 999999;

class _ReadPagerState extends State<ReadPager> {
//  int maxInt = 999999999999999;

  var currentPageIndex = 0;
  var currentChapterIndex = 0;

//  var pageEndIndexList = [];

  Map<String, List> chapterPagerDataMap = Map(); //调整字体后需要清空,url为key
  Map<String, String> chapterTextMap =
      Map(); //章节内容缓存,已缓存到内存的章节，若没有则从网络和本地读取，url为key

  Map<int, bool> loadingMap = Map(); //章节加载状态，key为章节索引，value为true则为加载中

//  var content = "";

  TextStyle textStyle;
  double ReadTextWidth;
  double ReadTextHeight;
  double LineHeight;

  PageController pageController;

  int initScrollIndex = (maxInt / 2).floor();

//  int initPageIndex = 0;
//  int initChapterIndex = 0;

  @override
  void initState() {
    ReadTextWidth = ScreenAdaptation.screenWidth - dp(32);
    ReadTextHeight =
        ScreenAdaptation.screenHeight - dp(35) - dp(44); //减去头部章节名称高度，减去底部页码高度
    LineHeight = dp(27);
    var lineNum = (ReadTextHeight / LineHeight).floor();
    LineHeight = (ReadTextHeight / lineNum).floorToDouble();
    textStyle = new TextStyle(
      height: 1.2,
      fontSize: dp(17),
      letterSpacing: dp(1),
      color: Color(0xff383635),
//        fontFamily: 'ReadFont',
    );

    List chapterList = widget.bookInfo['chapterList'];

    this.pageController = PageController(initialPage: initScrollIndex);
    this.pageController.addListener(() {
      widget.optionLayerKey.currentState.hide();
//      var currentPageIndex =
//          pageController.page - initScrollIndex + initPageIndex;
//      print(currentPageIndex);
      var currentPageIndexOffset = pageController.page;
//      print("currentPageIndexOffset  $currentPageIndexOffset");
      if (currentPageIndexOffset < currentPageIndexOffset.round() &&
          currentPageIndex == 0 &&
          currentPageIndexOffset.round() - currentPageIndexOffset < 0.3 &&
          currentChapterIndex == 0) {
//        print('currentPageIndexOffset.round() - currentPageIndexOffset  ${currentPageIndexOffset.round() - currentPageIndexOffset}');
        print("禁止滑动");
        pageController.jumpToPage(currentPageIndexOffset.round());
        return;
      }
//      print(
//          "$currentPageIndexOffset ${currentPageIndexOffset.round()} $currentPageIndex ${currentChapterIndex} ");
      if (currentPageIndexOffset > currentPageIndexOffset.round() &&
          currentPageIndexOffset - currentPageIndexOffset.round() < 0.3 &&
//          currentPageIndex == pageCount - 1 &&
//          currentChapterIndex == chapterList.length - 1) {
          currentPageIndex == 0 &&
          currentChapterIndex == chapterList.length) {
//        print('currentPageIndexOffset.round() - currentPageIndexOffset  ${currentPageIndexOffset.round() - currentPageIndexOffset}');
        print("禁止滑动");
        pageController.jumpToPage(currentPageIndexOffset.round());
        return;
      }
    });
    this.initReadState();
    super.initState();
  }

  initReadState() async {
//    this.initPageIndex = widget.bookInfo['currentPageIndex'];
    this.currentPageIndex = widget.bookInfo['currentPageIndex'];
    this.currentChapterIndex = widget.bookInfo['currentChapterIndex'];
//    this.initPageIndex = 1;
//    print("init initPageIndex   $initPageIndex");
    loadingMap[currentChapterIndex] = true;
    loadingMap[currentChapterIndex + 1] = true;
    loadingMap[currentChapterIndex - 1] = true;
    await Future.delayed(Duration(milliseconds: 350));
    await this.loadChapterText(currentChapterIndex, false);
    await this.loadChapterText(currentChapterIndex + 1, false);
    await this.loadChapterText(currentChapterIndex - 1, false);
    setState(() {});
  }

  Future loadChapterText(chapterIndex, [bool reLayout = true]) async {
    print('loadChapterText');
    loadingMap[chapterIndex] = true;
//    setState(() {
//      this.content = 'loading';
//    });
    var chapterList = widget.bookInfo['chapterList'];
    if (chapterIndex < 0 || chapterIndex > chapterList.length - 1) {
      loadingMap.remove(chapterIndex); //不在章节索引中，移除加载状态
      setState(() {});
      return;
    }
    var url = chapterList[chapterIndex]['url'];
    if (chapterTextMap[url] != null) {
      if (chapterPagerDataMap[url] != null &&
          chapterPagerDataMap[url].length == 0) {
        calcPagerData(url);
      }
      loadingMap.remove(chapterIndex); //从内存中加载，移除加载状态
      return;
    }
    print("loadChapterText =======");

    var database = Globals.database;
    List<Map> existData =
        await database.rawQuery('select text from chapter where id = ?', [url]);
    var content = '';
    if (existData.length > 0) {
      content = existData[0]['text'];
    } else {
      await Future.delayed(Duration(milliseconds: 5000));
      Dio dio = new Dio();
//    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
      Response response = await dio.get(url);
      var document = parse(response.data);
      content = document.querySelector('#content').innerHtml;
      content = content
          .replaceAll('<script>chaptererror();</script>', '')
          .split("<br>")
          .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
          .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
          .join('\n');
      await database.transaction((txn) async {
        List<Map> existData =
            await txn.rawQuery('select text from chapter where id = ?', [url]);
        if (existData.length > 0) {
          loadingMap.remove(chapterIndex); //并发以完成，移除加载状态
          return;
        }
        await txn.insert('chapter', {
          "id": url,
          "text": content,
        });
      });
    }
    chapterTextMap[url] = content;

    calcPagerData(url);
//    this.pageEndIndexList = pageEndIndexList;
    loadingMap.remove(chapterIndex); //加载完成，移除加载状态

//    if (chapterIndex == currentChapterIndex) {
    if (reLayout) {
      setState(() {});
    }
//    }
  }

  calcPagerData(url) {
    var exist = chapterPagerDataMap[url];
    if (exist != null && exist.length > 0) {
      return exist;
    }
    if (chapterTextMap[url] == null) {
      return [0];
    }
//    var pageEndIndexList = parseChapterPager(chapterTextMap[url]);
    var pageEndIndexList = ChapterTextPainter.calcPagerData(
      chapterTextMap[url],
      ReadTextWidth,
      ReadTextHeight,
      textStyle,
      LineHeight,
    );
    chapterPagerDataMap[url] = pageEndIndexList;
//    print(pageEndIndexList);
//    print("页数 ${pageEndIndexList.length}");
    return pageEndIndexList;
  }

  bool onPageScrollNotify(Notification notification) {
//    print(notification.runtimeType);
    if (notification is ScrollEndNotification) {
//      setState(() {
//      var initScrollIndex = pageController.page.round();
//      print(initScrollIndex);
//      });
//      print("xxx");

      var index = pageController.page.round();
//      var currentPageIndex = index - initScrollIndex + initPageIndex;
      initScrollIndex = index;
//      initPageIndex = currentPageIndex;
      this.saveReadState();

      this.loadChapterText(currentChapterIndex + 1);
      this.loadChapterText(currentChapterIndex - 1);
    }
    return false;
  }

  saveReadState() async {
    var database = Globals.database;
    await database.update(
      'Book',
      {
        "currentPageIndex": this.currentPageIndex,
        "currentChapterIndex": this.currentChapterIndex,
      },
      where: "id=?",
      whereArgs: [widget.bookInfo['id']],
    );
//    print("asdfsadfasdfasdf ${widget.bookInfo['id']}  ${currentPageIndex}");
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: new PageView.builder(
        onPageChanged: (index) {
          print('onPageChanged');
//          currentPageIndex
//        currentChapterIndex
          var pageChange = index - initScrollIndex;
          var newPageIndex = currentPageIndex + pageChange;
          print("pagechange $pageChange");
          if (pageChange > 0) {
            List chapterList = widget.bookInfo['chapterList'];
            var url = chapterList[currentChapterIndex]['url'];
            var chapterPagerList = chapterPagerDataMap[url];
            if (chapterPagerList == null ||
                newPageIndex > chapterPagerList.length - 1) {
              currentPageIndex = 0;
              currentChapterIndex++;
            } else {
              currentPageIndex = newPageIndex;
            }
          } else {
            if (newPageIndex < 0) {
              List chapterList = widget.bookInfo['chapterList'];
              var url = chapterList[currentChapterIndex - 1]['url'];
              var chapterPagerList = chapterPagerDataMap[url];
              currentChapterIndex--;
              if (chapterPagerList == null || chapterPagerList.length == 0) {
                currentPageIndex = 0;
              } else {
                currentPageIndex = chapterPagerList.length - 1;
              }
            } else {
              currentPageIndex = newPageIndex;
            }
          }
          print("页码 $currentPageIndex,  章节 $currentChapterIndex");
          initScrollIndex = index;
//        print(index);
//        pageController.jumpTo(pageController.offset - 1);
        },
        controller: pageController,
        itemBuilder: (BuildContext context, int index) {
          return buildPage(index);
        },
//      itemCount: 3,
        itemCount: maxInt,
        physics: ClampingScrollPhysics(),
//      physics: PagerScrollPhysics(),
      ),
      onNotification: onPageScrollNotify,
    );
  }

  String loadPageText(url, int pageIndex) {
    var pageEndIndexList = chapterPagerDataMap[url];
    var chapterText = chapterTextMap[url];
    if (pageEndIndexList == null || chapterText == null) {
      return "";
    }
    return chapterText.substring(
      pageIndex == 0 ? 0 : pageEndIndexList[pageIndex - 1],
      pageEndIndexList[pageIndex],
    );
  }

  Widget buildPage(int index) {
//    print("buildPage========");
    var blankPage = false;
    var finishPage = false;
    var pageIndex = currentPageIndex + (index - initScrollIndex);
    var chapterIndex = currentChapterIndex;
    List chapterList = widget.bookInfo['chapterList'];

    var url;
    var title;

    var loading = loadingMap[chapterIndex];
//    print("loadingggggggggggggggg   $loading $chapterIndex");
    if (loading == null) {
//    var chapterText = chapterTextCacheMap[pageIndex];
//      print("aaaaaaaaaaa , $chapterIndex, ${chapterList.length}");
      if (chapterIndex < chapterList.length) {
        var chapter = chapterList[chapterIndex];
        url = chapter['url'];
        title = chapter['title'];
      }
      var chapterText = chapterTextMap[url] ?? '';
      var pageCount = calcPagerData(url).length;

//      print(
//          '加载页 $pageIndex,  章节$currentChapterIndex, $title, ${chapterText.length}, $pageCount');

      while (pageIndex > pageCount - 1) {
        print("${chapterIndex}  ${chapterList.length}");
        if (chapterIndex + 1 > chapterList.length - 1) {
          finishPage = true;
          break;
        } //越界停止
        //当前章节有内容，且分页数大于0才参与多次分页
        chapterIndex++;
        pageIndex -= pageCount;
        //翻页超过本章最后一页，加载下一章，并计算页数
        print("NNNNN $pageIndex  , $pageCount ");
        url = chapterList[chapterIndex]['url'];
//      title = chapterList[currentChapterIndex + 1]['title'];
        chapterText = chapterTextMap[url] ?? '';
        var parseChapterPagerList = calcPagerData(url);
        pageCount = parseChapterPagerList.length;
        print(parseChapterPagerList);
      }
      while (pageIndex < 0) {
        if (chapterIndex - 1 < 0) {
          blankPage = true;
          break;
        } //越界停止

        print("PPPPPPPPPPP  ${chapterIndex - 1}");
        chapterIndex--;
        url = chapterList[chapterIndex]['url'];
//      title = chapterList[currentChapterIndex - 1]['title'];
        chapterText = chapterTextMap[url] ?? '';
        pageCount = calcPagerData(url).length;
        pageIndex += pageCount;
      }
    }

    var text = "";
    var pageLabel = "";

    if (loading == true) {
      text = '加载中1';
      pageLabel = '';
      title = '';
    } else if (loading == false) {
      text = '加载失败';
      pageLabel = '';
      title = '';
    } else if (blankPage) {
      text = '越界了';
      pageLabel = '';
      title = '';
    } else if (finishPage || chapterIndex > chapterList.length - 1) {
      text = '没有最新章节';
      pageLabel = '';
      title = '';
    } else {
      var chapter = chapterList[chapterIndex];
      url = chapter['url'];
      title = chapter['title'];
      var pageEndIndexList = chapterPagerDataMap[url];
//      print('bbbbbbb ${chapterIndex}  ${url}');
      if (pageEndIndexList != null && pageEndIndexList.length > 0) {
        text = loadPageText(url, pageIndex);
        pageLabel = '${pageIndex + 1}/${pageEndIndexList.length}';
      } else {
        text = "加载中2";
      }
    }

    return GestureDetector(
      onTap: () {
        widget.optionLayerKey.currentState.toggle();
      },
      child: ReadPagerItem(
        text: new TextCanvas(
          text: text,
          width: ReadTextWidth,
          height: ReadTextHeight,
          lineHeight: LineHeight,
        ),
        title: title,
        pageLabel: pageLabel,
      ),
    );
  }
}
