import 'dart:convert';
import 'dart:isolate';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:seek_book/book_site/book_source.dart';
import 'package:seek_book/book_site/gbk.dart';
import 'package:seek_book/globals.dart' as Globals;
import 'package:http/http.dart' as http;

import 'package:gbk2utf8/gbk2utf8.dart';

class BookSite {
  //最多请求3次，失败则返回失败。
  Future request(String url, [retryTime = 3]) async {
    try {
      if (retryTime == 0) {
        return null;
      }
      print("request");
//      Dio dio = new Dio();
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
        case 'parseBookListByRoleInBack':
          var result = await instance.parseBookListByRoleInBack(param);
          replyTo.send(result);
          return;
        case 'parseBookDetailByRoleInBack':
          var result = await instance.parseBookDetailByRoleInBack(param);
          replyTo.send(result);
          return;
        case 'parseChapterByRoleInBack':
          var result = await instance.parseChapterByRoleInBack(param);
          replyTo.send(result);
          return;
      }
      replyTo.send(null);
      return;
    }
  }

  bookDetail(name, author, url, siteRule, [onFindExist, imgUrl]) async {
//    var bookSource = BookSource;
//    Map siteRule = bookSource[0];

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
    print(siteRule);
    String bookSourceName = siteRule['bookSourceName'];
    String bookSourceUrl = siteRule['bookSourceUrl'];
//    print(data);

    Map bookInfo = await runOnIsoLate(this, 'parseBookDetailByRoleInBack', {
//      'data': data,
      'url': url,
//      'dataMulu': dataMulu,
      'siteRule': json.encode(siteRule),
    });
    bookInfo['url'] = url;
    bookInfo['name'] = name;
    bookInfo['author'] = author;
    bookInfo['imgUrl'] = imgUrl ?? bookInfo['imgUrl'];
    bookInfo['siteName'] = bookSourceName;
    bookInfo['siteHost'] = bookSourceUrl;

    if (exist.length > 0) {
      bookInfo["currentPageIndex"] = exist[0]["currentPageIndex"];
      bookInfo["currentChapterIndex"] = exist[0]["currentChapterIndex"];
      print("更新");
//      bookInfo["hasNew"] = exist[0];
      if (bookInfo['hasNew'] != 1 &&
          bookInfo["chapters"] != exist[0]["chapters"]) {
        bookInfo['hasNew'] = 1;
      }
      await database.update(
        'Book',
        {
          "chapters": bookInfo["chapters"],
          "hasNew": bookInfo['hasNew'],
        },
        where: "name=? and author=?",
        whereArgs: [name, author],
      );
    } else {
      print("插入");
      var chapterList = bookInfo['chapterList'];
      bookInfo.remove('chapterList');
      await database.insert('Book', bookInfo);
      bookInfo["chapterList"] = chapterList;
    }
    return bookInfo;
  }

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
        eleList = doc.querySelectorAll('$typeValue');
//        print('找 tag ${typeValue}  $eleList ${eleList[0].innerHtml}'  );
        break;
      case 'id':
        eleList = doc.querySelectorAll('#$typeValue');
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
                  .replaceAll(
                      new RegExp(
                          '<script.*</script>|<p>|</p>|<p/>|<P>|</P>|<P/>'),
                      '')
//                  .replaceAll('<p>', '')
//                  .replaceAll('</p>', '')
//                  .replaceAll('<P>', '')
//                  .replaceAll('</P>', '')
                  .split("<br>")
                  .map((it) => "　　" + it.trim().replaceAll('&nbsp;', ''))
                  .where((it) => it.length != 2) //剔除掉只有两个全角空格的行
                  .join('\n');
              newTmpList.add(content);
              print(content);
              break;
          }
        }
      });
      temp = newTmpList;
    }
    return temp;
  }

  parseBookListByRoleInBack(param) async {
    var text = param['text'];
    var siteRule = json.decode(param['siteRule']);

    print(siteRule);

    String searchUrl = siteRule['ruleSearchUrl'];

    var isGbk = searchUrl.indexOf('|char=gbk') != -1;
//    searchUrl = searchUrl.replaceAll('searchKey', Uri.encodeComponent('逆天邪神'));
    if (isGbk) {
//      searchUrl = searchUrl.replaceAll('searchKey', '%C4%E6%CC%EC');
      searchUrl = searchUrl.replaceAll(
          'searchKey',
          '${Uri.encodeQueryComponent(
            text,
            encoding: Utf8Codec2(),
          )}');
    } else {
      searchUrl = searchUrl.replaceAll('searchKey', text);
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
    print('返回的response ${response}');
    var data = '';
    data = requestBody2Utf8(response, isGbk);

    String bookSourceName = siteRule['bookSourceName'];
    String bookSourceUrl = siteRule['bookSourceUrl'];
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
          author = author.replaceAll('作者：', '');
          author = author.replaceAll('作者:', '');
//          print('作者：$author');
          var lastChapterResult =
              parseWholeRole(item, siteRule['ruleSearchLastChapter']);
          String lastChapter = '';
          if (lastChapterResult.length > 0) {
            lastChapter = lastChapterResult[0];
          }
          return {
            'name': name.trim(),
            'url': url == null ? '' : url.trim(),
            'author': author.trim(),
            'lastChapter': lastChapter.trim(),
            'kind': kind.trim(),
            'imgUrl': imgUrl.trim(),
            'siteName': bookSourceName,
            'siteHost': bookSourceUrl,
          };
        })
        .where((it) => it != null)
        .toList();
    print(bookList);
    print("解析到N本书 ${bookList.length}");
    return jsonEncode(bookList);
  }

  static findSiteRule(siteHost) {
    for (int i = 0; i < BookSource.length; i++) {
      if (BookSource[i]["bookSourceUrl"] == siteHost) {
        return BookSource[i];
      }
    }
  }

  parseBookDetailByRoleInBack(param) async {
//    var data = param['data'];
    var url = param['url'];
    var siteRule = json.decode(param['siteRule']);

    String bookSourceName = siteRule['bookSourceName'];
    String bookSourceUrl = siteRule['bookSourceUrl'];
    String searchUrl = siteRule['ruleSearchUrl'];
    String ruleChapterUrl = siteRule['ruleChapterUrl'];

    var isGbk = searchUrl.indexOf('|char=gbk') != -1;

    http.Response response = await request(url);
    var data = requestBody2Utf8(response, isGbk);

    var doc = parse(data);
    var chapterListDoc = doc;

    var dataMulu;
    print('ruleChapterUrl, ${ruleChapterUrl}');
    if (ruleChapterUrl != null && ruleChapterUrl.isNotEmpty) {
      List muluResult = parseWholeRole(doc, ruleChapterUrl);
      if (muluResult.length > 0) {
        String chapterListUrl = muluResult[0];
        if (chapterListUrl != null) {
          if (chapterListUrl.indexOf('http') == -1) {
            chapterListUrl = Uri.parse(url).origin + chapterListUrl;
          }
          var response = await request(chapterListUrl);
          var data2 = requestBody2Utf8(response, isGbk);
          chapterListDoc = parse(data2);
        }
      }
    }

    String ruleChapterList = siteRule['ruleChapterList'];
//    String ruleBookName = siteRule['ruleBookName'];
//    String ruleBookAuthor = siteRule['ruleBookAuthor'];
    String ruleChapterName = siteRule['ruleChapterName'];
    String ruleContentUrl = siteRule['ruleContentUrl'];
    String ruleCoverUrl = siteRule['ruleCoverUrl'];
//    String ruleChapterList = siteRule['ruleChapterList'];
//    var doc = parse(data);
//    List nameResult = parseWholeRole(doc, ruleBookName);
//    var name;
//    if (nameResult.length > 0) {
//      name = nameResult[0];
//    }
//    List authorResult = parseWholeRole(doc, ruleBookAuthor);
//    var author;
//    if (authorResult.length > 0) {
//      author = authorResult[0];
//    }
    List chapterListDocs = parseWholeRole(chapterListDoc, ruleChapterList);
    print('章节节点数量: ${chapterListDocs.length}');
    List chapterList = [];
    chapterListDocs.forEach((item) {
      var chapterNameResult = parseWholeRole(item, ruleChapterName);
      if (chapterNameResult.length == 0) {
        print('章节名解析失败， 跳过');
        return;
      }
      var chapterName = chapterNameResult[0];
//      print(chapterName);
      var contentUrlResult = parseWholeRole(item, ruleContentUrl);
      if (contentUrlResult.length == 0) {
        print('章节地址解析失败， 跳过');
        return;
      }
      String contentUrl = contentUrlResult[0];
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
//      "name": name,
//      "author": "不重要,使用列表书名",
      "imgUrl": imgUrl,
//      "url": url,
//      "site": bookSourceUrl,
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

  parseChapterByRoleInBack(param) async {
    var chapterUrl = param['chapterUrl'];
    var siteRule = json.decode(param['siteRule']);

    http.Response response = await request(chapterUrl);

    String searchUrl = siteRule['ruleSearchUrl'];
    var isGbk = searchUrl.indexOf('|char=gbk') != -1;
    String data = requestBody2Utf8(response, isGbk);

    var doc = parse(data);
    var ruleBookContent = siteRule['ruleBookContent'];
    var result = parseWholeRole(doc, ruleBookContent)[0];
    return result;
  }

  searchBook(String text, siteRule) async {
//    var bookSource =
//        BookSource.where((it) => jsonEncode(it).indexOf('|char=gbk') == -1)
//            .toList();
//    var bookSource = BookSource;
//    var bookSourceStr = await rootBundle.loadString('assets/file/booksource.json');
//    var bookSource = json.decode(bookSourceStr);
    // 10 11 13 29 33 51解析出现问题
    // 13 29 33 因为gbk的post出现问题，改为get可以解决
    // 51 gbk的post问题
    // 20 书源异常
    // 1 302调整到书籍详情了，手动默认章节地址为当前地址
//    Map siteRule = bookSource[0];
    //一共54个书源
//    print(siteRule);

    String bookListJSON =
        await runOnIsoLate(this, 'parseBookListByRoleInBack', {
      'text': text,
      'siteRule': json.encode(siteRule),
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
      var result;
      try {
        result = utf8.decode(response.bodyBytes);
      } catch (e) {
        print(e);
        try {
          print('Utf8解码失败，使用GBK解码');
          result = decodeGbk(response.bodyBytes);
        } catch (e) {
          print(e);
        }
      }
      return result;
    }
  }

  Future<String> parseChapter(String chapterUrl, siteRule) async {
    String bookContentResult =
        await runOnIsoLate(this, 'parseChapterByRoleInBack', {
      'chapterUrl': chapterUrl,
      'siteRule': json.encode(siteRule),
    });
    await Globals.database.transaction((txn) async {
      List<Map> existData = await txn
          .rawQuery('select text from chapter where id = ?', [chapterUrl]);
      if (existData.length > 0) {
        return existData[0]['text'];
      }
      await txn.insert('chapter', {
        "id": chapterUrl,
        "text": bookContentResult,
      });
    });
    return bookContentResult;
  }
}
