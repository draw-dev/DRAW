import 'dart:convert';

import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/redditor.dart';

class Flair {
  String get flairCssClass => _data['flair_css_class'];
  String get flairText => _data['flair_text'];
  final RedditorRef user;

  final Map<String, String> _data;

  Flair(this.user, {String flairCssClass, String flairText})
      : _data = <String, String>{
          'flair_css_class': flairCssClass,
          'flair_text': flairText
        };

  Flair.parse(Reddit reddit, Map<String, String> data)
      : user = RedditorRef.name(reddit, data['user']),
        _data = data;

  String toString() => JsonEncoder.withIndent('   ').convert(_data);
}
