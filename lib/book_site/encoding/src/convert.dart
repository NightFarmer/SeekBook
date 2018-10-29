import 'gbk.dart';
import 'unicode.dart';
import 'dart:convert';

List<int> gbk2utf8(List<int> gbk_buf) {
  return unicode2utf8(gbk2unicode(gbk_buf));
}

String decodeGbk(List<int> gbk_buf) {
  return Encoding.getByName("utf-8").decode(gbk2utf8(gbk_buf));
}

/// gbk => unicode word array
/// @param gbk_buf byte array
/// @return   word array
List<int> gbk2unicode(List<int> gbk_buf) {
  int uni_ind = 0, gbk_ind = 0, uni_num = 0;
  int ch;
  int word; //unsigned short
  int word_pos;
  List<int> uni_ptr = new List()..length = gbk_buf.length;

  for (; gbk_ind < gbk_buf.length;) {
    ch = gbk_buf[gbk_ind];
    if (ch > 0x80) {
      word = gbk_buf[gbk_ind];
      word <<= 8;
      word += gbk_buf[gbk_ind + 1];
      gbk_ind += 2;
      word_pos = word - gbk_first_code;
      if (word >= gbk_first_code &&
          word <= gbk_last_code &&
          (word_pos < unicode_buf_size)) {
        uni_ptr[uni_ind] = unicodeTables[word_pos];
        uni_ind++;
        uni_num++;
      }
    } else {
      gbk_ind++;
      uni_ptr[uni_ind] = ch;
      uni_ind++;
      uni_num++;
    }
  }

  uni_ptr.length = uni_num;

  return uni_ptr;
}

///Word array to utf-8
List<int> unicode2utf8(List<int> wordArray) {
  // a utf-8 character is 3 bytes
  List<int> list = new List()..length = wordArray.length * 3;
  int pos = 0;

  for (int i = 0, c = wordArray.length; i < c; ++i) {
    int word = wordArray[i];
    if (word <= 0x7f) {
      list[pos++] = word;
    } else if (word >= 0x80 && word <= 0x7ff) {
      list[pos++] = 0xc0 | ((word >> 6) & 0x1f);
      list[pos++] = 0x80 | (word & 0x3f);
    } else if (word >= 0x800 && word < 0xffff) {
      list[pos++] = 0xe0 | ((word >> 12) & 0x0f);
      list[pos++] = 0x80 | ((word >> 6) & 0x3f);
      list[pos++] = 0x80 | (word & 0x3f);
    } else {
      //-1
      list[pos++] = -1;
    }
  }

  list.length = pos;
  return list;
}




//https://segmentfault.com/a/1190000015282324

//https://blog.csdn.net/bladeandmaster88/article/details/54837338
// utf8转Unicode
List<int> utf82unicode(List<int> wordArray) {
  List<int> list = [];
  for (int i = 0, c = wordArray.length; i < c; ++i) {
    int word = wordArray[i];
    if (word > 0x00 && word <= 0x7F) {
      list.add(word);
//      list.add(0);
    } else if ((word & 0xE0) == 0xC0) {
      int high = word;
      ++i;
      word = wordArray[i];
      int low = word;
      if ((low & 0xC0) != 0x80) {
        return list;
      }
      list.add((high << 6) + (low & 0x3F));
      list.add((high >> 2) & 0x07);
    } else if ((word & 0xF0) == 0xE0) {
      int high = word;
      ++i;
      int middle = wordArray[i];
      ++i;
      int low = wordArray[i];
      word = wordArray[i];
      if (((middle & 0xC0) != 0x80) || ((low & 0xC0) != 0x80)) {
        return list;
      }
      var newLow = ((middle & 0x3) << 6) + (low & 0x3F);
//      list.add(newLow);
//      var newHigh = (high << 4) + ((middle >> 2) & 0x0F);
      var newHigh = ((high & 0xF) << 4) + ((middle >> 2) & 0xF);
//      list.add(newHigh);
      var value = (newHigh << 8) + newLow;
      list.add(value);
//      print(
//          "$newLow  $newHigh  ${charToUnicode(newHigh)} ${charToUnicode(newLow)} ${charToUnicode(newHigh << 8)}  ${charToUnicode(value)}");
//      print('${charToUnicode(10<<8)}');
//      print('${10.toRadixString(16)}');
//      print('${10.toRadixString(16)}');
    } else {
      return list;
    }
  }
//  list.add(0);
//  list.add(0);
  return list;
}

String charToUnicode(int char) {
  if (char == null || char < 0 || char > 0xfffffffff) {
    throw new ArgumentError('c: $char');
  }

  var hex = char.toRadixString(16);
  var length = hex.length;
  var count = 0;
  if (char <= 0xffff) {
    count = 4;
  } else {
    count = 8;
  }

  for (var i = 0; i < count - length; i++) {
    hex = '0$hex';
  }

  return '\\u$hex';
}

//http://www.52im.net/thread-1693-1-1.html
//https://blog.csdn.net/tge7618291/article/details/7608510
List<int> unicode2gbk(List<int> unicodeWordList) {
  List<int> list = [];

  for (int i = 0; i < unicodeWordList.length; i++) {
    //映射成两个字符
    var word = unicodeWordList[i];
//    if(word<=0x80){
//    }
    if (word > 0x80) {
//      print("$word ${charToUnicode(word)}");
      word = gbkTables[word - unicode_first_code];
//      print(charToUnicode(word));
    }
    var low = word & 0xFF;
    var high = word >> 8;
//    print(charToUnicode(low));
//    print(charToUnicode(high));
    if (high != 0) {
      list.add(high);
    }
    list.add(low);
  }

  return list;
}
