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
