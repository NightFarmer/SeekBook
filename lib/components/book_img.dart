import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:seek_book/utils/screen_adaptation.dart';

class BookImg extends StatelessWidget {
  final double width;
  final String imgUrl;
  final String label;

  BookImg({Key key, @required this.imgUrl, this.width, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
//    print(imgUrl);
    var imgWidth = width ?? dp(50);
    if (imgUrl == null || imgUrl == '') {
      return Container(
        width: dp(imgWidth),
        height: dp(imgWidth / 144 * 192),
        color: Color(0xFFDDDDDD),
      );
    }
    return new CachedNetworkImage(
      imageUrl: imgUrl,
      placeholder: Container(
        width: dp(imgWidth),
        height: dp(imgWidth / 144 * 192),
        color: Color(0xFFDDDDDD),
      ),
      errorWidget: Container(
        width: dp(imgWidth),
        height: dp(imgWidth / 144 * 192),
        color: Color(0xFFDDDDDD),
      ),
      width: dp(imgWidth),
      height: dp(imgWidth / 144 * 192),
      fit: BoxFit.cover,
    );
  }
}
