import 'dart:convert';

import 'package:draw/src/exceptions.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/redditor.dart';

enum FlairPosition { left, right, disabled }

String flairPositionToString(FlairPosition p) {
  switch (p) {
    case FlairPosition.left:
      return 'left';
    case FlairPosition.right:
      return 'right';
    default:
      throw DRAWUnimplementedError();
  }
}

FlairPosition stringToFlairPosition(String p) {
  switch (p) {
    case 'left':
      return FlairPosition.left;
    case 'right':
      return FlairPosition.right;
    default:
      return FlairPosition.disabled;
  }
}

class _FlairBase {
  String get flairCssClass => _data['flair_css_class'];
  String get flairText => _data['flair_text'];

  final Map<String, dynamic> _data;

  _FlairBase(String flairCssClass, String flairText)
      : _data = <String, dynamic>{
          'flair_css_class': flairCssClass,
          'flair_text': flairText
        };

  _FlairBase.parse(Map<String, dynamic> data) : _data = data;

  String toString() => JsonEncoder.withIndent('   ').convert(_data);
}

/// A simple representation of a template for Reddit flair.
class FlairTemplate extends _FlairBase {
  String get flairTemplateId => _data['flair_template_id'];
  bool get flairTextEditable => _data['flair_text_editable'];
  final FlairPosition position;

  FlairTemplate(String flairCssClass, String flairTemplateId,
      bool flairTextEditable, String flairText, this.position)
      : super(flairCssClass, flairText) {
    _data['flair_template_id'] = flairTemplateId;
    _data['flair_text_editable'] = flairTextEditable;
  }

  FlairTemplate.parse(Map<String, dynamic> data)
      : position = stringToFlairPosition(data['flair_position']),
        super.parse(data);
}

/// A simple representation of Reddit flair.
class Flair extends _FlairBase {
  final RedditorRef user;

  Flair(this.user, {String flairCssClass = '', String flairText = ''})
      : super(flairCssClass, flairText);

  Flair.parse(Reddit reddit, Map<String, dynamic> data)
      : user = RedditorRef.name(reddit, data['user']),
        super.parse(data);

  String toString() => JsonEncoder.withIndent('   ').convert(_data);
}
