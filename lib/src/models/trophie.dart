import 'package:draw/draw.dart';
import 'package:draw/src/base_impl.dart';

class Trophy extends RedditBase with RedditBaseInitializedMixin {
  Trophy.parse(Reddit reddit, Map data) : super(reddit) {
    setData(this, data);
  }

  @override
  String get id => data['award_id'];

  String get description => data['description'];

  String get icon_40 => data['icon_40'];

  String get icon_70 => data['icon_70'];

  String get name => data['name'];

  String get url => data['url'];
}
