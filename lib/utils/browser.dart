import 'package:url_launcher/url_launcher.dart';

class Browser {
  static openURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('url 打开失败');
//        throw 'Could not launch $url';
    }
  }
}
