import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart';
import 'package:seek_book/book_site/book_source.dart';
import 'package:seek_book/book_site/kenwen.dart';
import 'package:seek_book/book_site/utf.dart';
import 'package:seek_book/globals.dart' as Globals;
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart' show rootBundle;
import 'package:gbk2utf8/gbk2utf8.dart';

abstract class BookSite {
  //最多请求3次，失败则返回失败。
  Future request(String url, [retryTime = 3]) async {
    try {
      if (retryTime == 0) {
        return null;
      }
      print("request");
      Dio dio = new Dio();
//      Response response;
      http.Response response;
      if (url.indexOf('@') != -1) {
//        response = await dio.post(
//          url.split('@')[0],
////          url.replaceAll('@', '?'),
//          options: Options(
//            connectTimeout: 5000,
//            receiveTimeout: 5000,
//          ),
//          data: FormData.from({'searchkey': "逆天邪神"}),
//          data: FormData.from({'searchkey': "逆天邪神"}),
//        );
//        http.Response response = await http.post(url.split('@')[0], body: {});
//        response = await http.post(url.replaceAll('@', '?'), body: {});
        Map<String, String> body = {
//          "searchkey": "逆天邪神",
        };
        url.split('@')[1].split('&').forEach((paramStr) {
          var paramKV = paramStr.split('=');
          body[paramKV[0]] = paramKV[1];
        });
        response = await http.post(
          url.replaceAll('@', '?'),
//          url.split('@')[0],
          body: body,
//          headers: {
//            "Content-Type": "application/x-www-form-urlencoded"
//          },
//          encoding: Encoding.getByName("gbk"),
//            encoding: Utf8Codec2(),
        );
//        print("post 请求");
//        print(response.body);
//        print(response.statusCode);
        if (response.statusCode == 302) {
          print('重定向！！！！！！ ${response.body}');
//          print(response.request.url.host);
//          print(response.request.url.scheme);
//          print(response.request.url.query);
//          print(response.request.url.pathSegments);
//          print(response.request.url.queryParameters);
//          print(response.request.url.path);
          print(response.request.url.origin);
          print(response.headers['location']);
          var url2 =
              '${response.request.url.origin}${response.headers['location']}';
          print(url2);
          return await request(url2, retryTime - 1);
        }
        print("post 请求2");
      } else {
//        var res = await dio.get(
//          url,
//          options: Options(
//            connectTimeout: 5000,
//            receiveTimeout: 5000,
//          ),
//        );
//        print(res.data);
        response = await http.get(url);
        if (response.statusCode == 302) {
          print('get请求被重定向');
        }
//        var httpClient = new HttpClient();
//        var request = await httpClient.getUrl(Uri.parse(url));
//        request.followRedirects = false;
//        var response2 = await request.close();
//        print('test response2 ${response2.statusCode}');
//        print(await response2.transform(Utf8Decoder()).join());
      }
//      var data = response.data;
      print('ok');
      return response;
    } catch (e) {
      print(e);
      await Future.delayed(Duration(milliseconds: 500));
      return await request(url, retryTime - 1);
    }
  }

  Future sendReceive(SendPort port, msg) {
    ReceivePort response = new ReceivePort();
    port.send([msg, response.sendPort]);
    return response.first;
  }

  runOnIsoLate(instance, functionName, param) async {
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(_onIsoLate, receivePort.sendPort);

    // The 'echo' isolate sends it's SendPort as the first message
    SendPort sendPort = await receivePort.first;

    var result = await sendReceive(sendPort, {
      'instance': instance,
      'functionName': functionName,
      'param': param,
    });
    return result;
  }

  static _onIsoLate(SendPort sendPort) async {
    // Open the ReceivePort for incoming messages.
    ReceivePort port = new ReceivePort();

    // Notify any other isolates what port this isolate listens to.
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      var data = msg[0];
      SendPort replyTo = msg[1];
      var instance = data['instance'];
      var functionName = data['functionName'];
      var param = data['param'];
      switch (functionName) {
        case 'parseBookDetail':
          var result = await instance.parseBookDetail(param);
          replyTo.send(result);
          return;
        case 'parseChapterText':
          var result = await instance.parseChapterText(param);
          replyTo.send(result);
          return;
        case 'parseBookListByRoleInBack':
          var result = await instance.parseBookListByRoleInBack(param);
          replyTo.send(result);
          return;
        case 'parseBookDetailByRoleInBack':
          var result = await instance.parseBookDetailByRoleInBack(param);
          replyTo.send(result);
      }
      replyTo.send(null);
      return;
    }
  }

//  bookDetail(name, author, siteHost, url, [onFindExist]) async {
//
//  }

  bookDetail(name, author, url, [onFindExist]) async {
    var bookSource = BookSource;
    Map siteRule = bookSource[0];

    var database = Globals.database;

    var exist = await database.rawQuery(
      'select * from Book where name=? and author=?',
      [name, author],
    );
    if (onFindExist != null) {
      onFindExist(exist);
    }
    //===
    print(url);
    String bookSourceUrl = siteRule['bookSourceUrl'];
    String searchUrl = siteRule['ruleSearchUrl'];
    var isGbk = searchUrl.indexOf('|char=gbk') != -1;

    http.Response response = await request(url);
    var data = requestBody2Utf8(response, isGbk);
//    print(data);

    var bookInfo = await runOnIsoLate(this, 'parseBookDetailByRoleInBack', {
      'data': data,
      'siteRule': json.encode(siteRule),
    });
    return bookInfo;

//    print("请求书籍详情  $name");
//    var name = this.bookInfo['name'];
//    var author = this.bookInfo['author'];
//    var url = this.bookInfo['url'];

//    var database = Globals.database;
//
//    var exist = await database.rawQuery(
//      'select * from Book where name=? and author=?',
//      [name, author],
//    );
//    if (onFindExist != null) {
//      onFindExist(exist);
//    }
//
////    print("书籍详情网络已返回0  $name  $url");
//    Dio dio = new Dio();
//    Response response;
//    try {
//      response = await dio.get(
//        url,
//        options: Options(
//          connectTimeout: 5000,
//          receiveTimeout: 5000,
//        ),
//      );
//    } catch (e) {
//      print(e);
//      return null;
//    }
//    var bookDetail = await runOnIsoLate(this, 'parseBookDetail', {
//      'data': response.data,
//      'url': url,
//    });
//    if (bookDetail == null) {
//      return null;
//    }
//    var imgUrl = bookDetail['imgUrl'];
//    var currentUpdateTime = bookDetail['updateTime'];
//
////    String chapters;
//    Map<String, dynamic> bookInfo = {
//      "name": name,
//      "author": author,
//      "imgUrl": imgUrl,
//      "url": url,
//      "site": 'www',
//      "updateTime": currentUpdateTime,
//      "currentPageIndex": 0,
//      "currentChapterIndex": 0,
//      "active": 0,
//      "chapterList": [],
//      "chapters": '[]',
//      "hasNew": 0,
//    };
//    if (exist.length > 0) {
//      bookInfo["currentPageIndex"] = exist[0]["currentPageIndex"];
//      bookInfo["currentChapterIndex"] = exist[0]["currentChapterIndex"];
//    }
//    if (exist.length > 0 && currentUpdateTime == exist[0]["updateTime"]) {
//      bookInfo = {
//        "name": exist[0]["name"],
//        "author": exist[0]["author"],
//        "imgUrl": exist[0]["imgUrl"],
//        "url": exist[0]["url"],
//        "site": exist[0]["site"],
//        "updateTime": exist[0]["updateTime"],
//        "chapters": exist[0]["chapters"],
//        "chapterList": exist[0]["chapters"] == null
//            ? []
//            : json.decode(exist[0]["chapters"]),
//        "currentPageIndex": exist[0]["currentPageIndex"],
//        "currentChapterIndex": exist[0]["currentChapterIndex"],
//        "active": exist[0]["active"],
//        "hasNew": exist[0]["hasNew"],
//      };
//      print("存在相同时间戳缓存");
//    } else {
////      List chapterList = parseChapterList(document, url);
////      chapters = json.encode(chapterList);
////      List chapterList = bookDetail['chapterList'];
//      bookInfo['chapters'] = bookDetail['chapters'];
//      bookInfo['chapterList'] = bookDetail['chapterList'];
//    }
//
//    await database.transaction((txn) async {
//      if (exist.length == 0) {
//        bookInfo = {
//          "name": name,
//          "author": author,
//          "imgUrl": imgUrl,
//          "url": url,
//          "site": 'www',
//          "updateTime": currentUpdateTime,
//          "chapters": bookDetail['chapters'],
//          "currentPageIndex": 0,
//          "currentChapterIndex": 0,
//          "active": 0,
//          "hasNew": 0,
//        };
//        print("插入");
//        await txn.insert('Book', bookInfo);
//        bookInfo["chapterList"] = bookDetail['chapterList'];
//      } else if (currentUpdateTime != exist[0]["updateTime"]) {
//        print("更新 ${currentUpdateTime}");
//        bookInfo["imgUrl"] = imgUrl;
//        bookInfo["updateTime"] = currentUpdateTime;
//        bookInfo["hasNew"] = 1;
//        await txn.update(
//          'Book',
//          {
//            "imgUrl": imgUrl,
//            "updateTime": currentUpdateTime,
//            "chapters": bookInfo["chapters"],
//            "hasNew": 1,
//          },
//          where: "name=? and author=?",
//          whereArgs: [name, author],
//        );
//      }
//    });
//    return bookInfo;
  }

//  searchBook(String text);

  Future<ChapterText> parseChapterText(param);

  List<Map> parseChapterList(Document document, String bookUrl);

  String parseBookImage(Document document, String bookUrl);

  int parseUpdateTime(Document document, String bookUrl);

  bool isBookDetailEmpty(String data);

  parseOneRole(doc, String role) {
    var roleList = role.split('|');
    List result = [];
    try {
      for (int i = 0; i < roleList.length; i++) {
        List temp = _parseOneRole(doc, roleList[i]);
        if (temp != null && temp.length > 0) {
          result = temp;
          break;
        }
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  // 现在只支持一级，后续扩展支持级联多级 如class.item-pic.tag.p.0@tag.i.0
  _parseOneRole(doc, String role) {
    List<String> words = role.split('.');
    String type = words[0];
    String typeValue = words[1];
    typeValue = typeValue.split('!')[0];
    List<Element> eleList;
    switch (type) {
      case 'class':
        typeValue = typeValue.split(' ').map((it) => ".$it").join('');
        eleList = doc.querySelectorAll(typeValue);
//        print('找 class ${typeValue}  $eleList');
//        print('找 class ${doc.querySelectorAll('.bd.booklist-subject')}');
        break;
      case 'tag':
        eleList = doc.querySelectorAll('${typeValue}');
//        print('找 tag ${typeValue}  $eleList ${eleList[0].innerHtml}'  );
        break;
      case 'id':
        eleList = doc.querySelectorAll('#${typeValue}');
        break;
      case 'children':
        return doc.children;
    }
    if (words.length == 3) {
      int index = int.parse(words[2]);
      if (index > eleList.length - 1) {
        return [];
      }
      Element ele = eleList[index];
      return [ele];
    } else if (words.length == 2) {
      if (words[1].indexOf("!") == -1) {
        return eleList;
      } else {
        var countRule = words[1].split('!')[1];
        var countRuleList = countRule.split(':');
        var result = [];
//        print(' xxx  $countRule  $eleList');
        for (int i = 0; i < eleList.length; i++) {
//          print('第几个：$i');
          var valid = true;
          for (int j = 0; j < countRuleList.length; j++) {
            var count = countRuleList[j];
            if (count == '%' && i == eleList.length - 1) {
              valid = false;
              break;
            }
            if (count != '%' && int.parse(count) == i) {
              valid = false;
              break;
            }
          }
//          print("结果是否加入 $valid");
          if (valid) {
            result.add(eleList[i]);
          }
        }
        return result;
      }
    }
    return null;
  }

  parseWholeRole(doc, String role) {
    var roles = role.split('#');
    String roleWithoutRes = roles[0]; //去掉尾部正则
    var roleList = roleWithoutRes.split('|');
    List result = [];
    try {
      for (int i = 0; i < roleList.length; i++) {
//        print('执行规则 ${roleList[i]}');
        List temp = _parseWholeRole(doc, roleList[i]);
//        print('规则结果 ${temp}');
        if (temp != null && temp.length > 0) {
          result = temp;
          break;
        }
      }
    } catch (e) {
      print(e);
    }
    if (roles.length == 1) return result;
    List resultRegExp = [];
    result.forEach((item) {
      if (item is String) {
        var regRole = roles[1];
        item = item.replaceAll(new RegExp('\\s'), '');
//        print('正则过滤 ${item} ${regRole}');
        resultRegExp.add(item.replaceAll(new RegExp(regRole), ''));
      } else {
        resultRegExp.add(item);
      }
    });
    return resultRegExp;
  }

  _parseWholeRole(doc, String role) {
    var temp = [doc];

    // 拆分多个规则
    List<String> roleList = role.split('@');

    for (int i = 0; i < roleList.length; i++) {
      var roleD = roleList[i];
      var newTmpList = [];
      temp.forEach((tempItem) {
//        print("执行规则 ${roleD}  $tempItem");
        if (roleD.split('.').length > 1 || roleD == 'children') {
          var tempResult = parseOneRole(tempItem, roleD);
          newTmpList.addAll(tempResult);
//        print('规则执行完成.');
        } else {
          // 取数值
          switch (roleD) {
            case 'text':
//              print("text test test test test");
//              print(tempItem.firstChild);
//              print(tempItem.children);
//              print(tempItem.firstChild.runtimeType);
//              print(tempItem.firstChild.text);
              String text = tempItem.firstChild.text;
//              if (text == null || text.trim().length == 0) {
              text = tempItem.text;
//              }
//              text = text.replaceAll(new RegExp('\\s'), '');
              newTmpList.add(text);
              break;
            case 'href':
              newTmpList.add(tempItem.attributes['href']);
              break;
            case 'src':
              newTmpList.add(tempItem.attributes['src']);
              break;
            case 'html':
              newTmpList.add(tempItem.outerHtml);
              break;
            case 'textNodes':
              String nodesHtml = tempItem.innerHtml;
              String content = nodesHtml;
              content = content
                  .replaceAll('<script>chaptererror();</script>', '')
                  .split("<br>")
                  .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
                  .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
                  .join('\n');
              newTmpList.add(content);
              break;
          }
        }
      });
      temp = newTmpList;
    }
    return temp;
  }

  parseBookListByRoleInBack(param) async {
    var data = param['data'];
    var siteRule = json.decode(param['siteRule']);
    String ruleSearchUrl = siteRule['ruleSearchUrl'];
    var doc = parse(data);
    List chapterItemEleList = parseWholeRole(doc, siteRule['ruleSearchList']);
    print('查找到N本书： ${chapterItemEleList.length}');
    var bookList = chapterItemEleList
        .map((item) {
          var searchBookNameResult =
              parseWholeRole(item, siteRule['ruleSearchName']);
          if (searchBookNameResult.length == 0) {
            print('书名解析失败，忽略 ${siteRule['ruleSearchName']}');
            return null;
          }
          String name = searchBookNameResult[0];
//          print('书名：$name');
          var urlResult = parseWholeRole(item, siteRule['ruleSearchNoteUrl']);
          if (urlResult.length == 0) {
//            print('书籍地址解析失败，忽略 ${siteRule['ruleSearchNoteUrl']}');
            print('书籍地址解析失败 ${siteRule['ruleSearchNoteUrl']}');
            urlResult = [param['queryUrl']];
//            return null;
          }
          String url = urlResult[0];
          if (url != null && url.startsWith('//')) {
            url = Uri.parse(ruleSearchUrl).scheme + ":" + url;
          }
          if (url != null && url.startsWith('/')) {
            url = Uri.parse(ruleSearchUrl).origin + url;
          }
//          print('地址：$url');
          var kindRule = siteRule['ruleSearchKind'];
          String kind = '';
          if (kindRule != null && kindRule.length > 0) {
            var kindResult = parseWholeRole(item, kindRule);
            if (kindResult.length > 0) {
              kind = kindResult[0];
            }
          }
          String imgUrl = '';
          var imgUrlRule = siteRule['ruleSearchCoverUrl'];
          if (imgUrlRule != null && imgUrlRule.length > 0) {
            var imgResult = parseWholeRole(item, imgUrlRule);
            if (imgResult.length > 0) {
              imgUrl = imgResult[0];
//              print('封面：$imgUrl');

              if (imgUrl != null && imgUrl.startsWith('//')) {
//                print(Uri.parse(bookSourceUrl).scheme);
                imgUrl = Uri.parse(ruleSearchUrl).scheme + ":" + imgUrl;
              }

              if (imgUrl != null && imgUrl.startsWith('/')) {
                imgUrl = Uri.parse(ruleSearchUrl).origin + imgUrl;
              }
            }
          }
          var authorResult = parseWholeRole(item, siteRule['ruleSearchAuthor']);
          if (authorResult.length == 0) {
            print('作者信息解析失败，忽略 ${siteRule['ruleSearchAuthor']}');
            return null;
          }
          String author = authorResult[0];
//          print('作者：$author');
          var lastChapterResult =
              parseWholeRole(item, siteRule['ruleSearchLastChapter']);
          String lastChapter = '';
          if (lastChapterResult.length > 0) {
            lastChapter = lastChapterResult[0];
          }
          return {
            'name': name.trim(),
            'url': url.trim(),
            'author': author.trim(),
            'lastChapter': lastChapter.trim(),
            'kind': kind.trim(),
            'imgUrl': imgUrl.trim(),
          };
        })
        .where((it) => it != null)
        .toList();
    print(bookList);
    print("解析到N本书 ${bookList.length}");
    return jsonEncode(bookList);
  }

  parseBookDetailByRoleInBack(param) async {
    var data = param['data'];
    var siteRule = json.decode(param['siteRule']);
    var doc = parse(data);

    String bookSourceUrl = siteRule['bookSourceUrl'];
    String searchUrl = siteRule['ruleSearchUrl'];
    var isGbk = searchUrl.indexOf('|char=gbk') != -1;

    String ruleChapterList = siteRule['ruleChapterList'];
    String ruleBookName = siteRule['ruleBookName'];
    String ruleBookAuthor = siteRule['ruleBookAuthor'];
    String ruleChapterName = siteRule['ruleChapterName'];
    String ruleContentUrl = siteRule['ruleContentUrl'];
    String ruleCoverUrl = siteRule['ruleCoverUrl'];
//    String ruleChapterList = siteRule['ruleChapterList'];
//    var doc = parse(data);
    List nameResult = parseWholeRole(doc, ruleBookName);
    var name;
    if (nameResult.length > 0) {
      name = nameResult[0];
    }
    List authorResult = parseWholeRole(doc, ruleBookAuthor);
    var author;
    if (authorResult.length > 0) {
      author = authorResult[0];
    }
    List chapterListDocs = parseWholeRole(doc, ruleChapterList);
    print('章节节点数量: ${chapterListDocs.length}');
    List chapterList = [];
    chapterListDocs.forEach((item) {
      var chapterName = parseWholeRole(item, ruleChapterName)[0];
//      print(chapterName);
      String contentUrl = parseWholeRole(item, ruleContentUrl)[0];
      if (contentUrl.indexOf('http') == -1) {
        contentUrl = bookSourceUrl + contentUrl;
      }
//      print(contentUrl);
      chapterList.add({
        'title': chapterName,
        'url': contentUrl,
      });
    });
    var imgUrlResult = parseWholeRole(doc, ruleCoverUrl);
    String imgUrl;
    if (imgUrlResult.length > 0) {
      imgUrl = imgUrlResult[0];
    }

    Map<String, dynamic> bookInfo = {
      "name": name,
      "author": "不重要使用列表书名",
      "imgUrl": imgUrl,
//      "url": url,
      "site": bookSourceUrl,
//      "updateTime": currentUpdateTime,
      "currentPageIndex": 0,
      "currentChapterIndex": 0,
      "active": 0,
      "chapterList": chapterList,
      "chapters": json.encode(chapterList),
      "hasNew": 0,
    };
    return bookInfo;
  }

  searchBook(String text) async {
//    var bookSource =
//        BookSource.where((it) => jsonEncode(it).indexOf('|char=gbk') == -1)
//            .toList();
    var bookSource = BookSource;
//    var bookSourceStr = await rootBundle.loadString('assets/file/booksource.json');
//    var bookSource = json.decode(bookSourceStr);
    // 10 11 13 29 33 51解析出现问题
    // 13 29 33 因为gbk的post出现问题，改为get可以解决
    // 51 gbk的post问题
    // 20 书源异常
    // 1 302调整到书籍详情了，手动默认章节地址为当前地址
    Map siteRule = bookSource[0];
    //一共54个书源
    print(siteRule);

    String searchUrl = siteRule['ruleSearchUrl'];

    var isGbk = searchUrl.indexOf('|char=gbk') != -1;
//    searchUrl = searchUrl.replaceAll('searchKey', Uri.encodeComponent('逆天邪神'));
    if (isGbk) {
//      searchUrl = searchUrl.replaceAll('searchKey', '%C4%E6%CC%EC');
      searchUrl = searchUrl.replaceAll('searchKey',
          '${Uri.encodeQueryComponent('修真聊天群', encoding: Utf8Codec2())}');
    } else {
      searchUrl = searchUrl.replaceAll('searchKey', '逆天邪神');
//      print('%C4%E6%CC%EC');
//      print("ggggg  ${Uri.encodeComponent('逆天')}");
//      print("ggggg  ${Uri.encodeQueryComponent('逆天1',encoding: Utf8Codec2())}");
//      return [];
//      searchUrl =
//          searchUrl.replaceAll('searchKey', Uri.encodeComponent('逆天邪神'));
    }
//    searchUrl = searchUrl.replaceAll('searchKey', '%C4%E6%CC%EC%D0%B0%C9%F1');
    searchUrl = searchUrl.replaceAll('searchPage-1', '0');
    searchUrl = searchUrl.replaceAll('searchPage', '0');
    searchUrl = searchUrl.replaceAll('|char=gbk', '');
    print(searchUrl);
    print(searchUrl.replaceAll('@', '?'));
    searchUrl = searchUrl.replaceAll('@', '?');
    http.Response response = await request(searchUrl, 5);
//    var data = response.data;

    var data = '';
    data = requestBody2Utf8(response, isGbk);
//    print(data);
//    print(response);
//    print(response.runtimeType);
//    print(response.data);
//    print(gbk2utf8(response.data));
//    String responseBody = await response.data.transform(GbkDecoder(allowMalformed: true)).join();
//    print(responseBody);

    String bookListJSON =
        await runOnIsoLate(this, 'parseBookListByRoleInBack', {
      'data': data,
      'siteRule': json.encode(siteRule),
      'queryUrl': searchUrl,
    });
    return json.decode(bookListJSON);
  }

  String requestBody2Utf8(http.Response response, bool isGbk) {
    print(response.headers);
    if (json.encode(response.headers).indexOf('gbk') != -1 ||
        json.encode(response.headers).indexOf('GBK') != -1 ||
        json.encode(response.headers).indexOf('gb2312') != -1 ||
        json.encode(response.headers).indexOf('GB2312') != -1) {
      isGbk = true;
    }
    if (!isGbk && response.body.indexOf('charset="gbk"') != -1) {
      isGbk = true;
    }
    if (isGbk) {
      print('GBK编码，转一下');
      return decodeGbk(response.bodyBytes);
    } else {
      print('默认Utf8编码');
      return utf8.decode(response.bodyBytes);
//      return response.body;
    }
  }

  Future<String> parseChapter(String chapterUrl) async {
    var bookSource = BookSource;
    Map siteRule = bookSource[0];
    var ruleBookContent = siteRule['ruleBookContent'];
    print(chapterUrl);
    http.Response response = await request(chapterUrl);

    String searchUrl = siteRule['ruleSearchUrl'];
    var isGbk = searchUrl.indexOf('|char=gbk') != -1;
    String data = requestBody2Utf8(response, isGbk);
//    print(data);
    var doc = parse(data);
    var bookContentResult = parseWholeRole(doc, ruleBookContent)[0];
    return bookContentResult;

//    Dio dio = new Dio();
////    var url = 'http://www.kenwen.com/cview/241/241355/1371839.html';
//    Response response = await dio.get(chapterUrl);
//    ChapterText chapterText = await runOnIsoLate(this, 'parseChapterText', {
//      'chapterUrl': chapterUrl,
//      'data': response.data,
//    });
//    if (!chapterText.valid) {
//      return chapterText.text;
//    }
//    await Globals.database.transaction((txn) async {
//      List<Map> existData = await txn
//          .rawQuery('select text from chapter where id = ?', [chapterUrl]);
//      if (existData.length > 0) {
//        return existData[0]['text'];
//      }
//      await txn.insert('chapter', {
//        "id": chapterUrl,
//        "text": chapterText.text,
//      });
//    });
//    return chapterText.text;
  }

  Future<Map> parseBookDetail(param) async {
    var data = param['data'];
    if (isBookDetailEmpty(data)) return null;
    var document = parse(data);
    var imgUrl = parseBookImage(document, param['url']);
    var updateTime = parseUpdateTime(document, param['url']);
    var chapterList = parseChapterList(document, param['url']);

    return {
      "updateTime": updateTime,
      "imgUrl": imgUrl,
      "chapters": jsonEncode(chapterList),
      "chapterList": chapterList,
    };
  }
}

class ChapterText {
  String text;
  bool valid = true;
}
