import 'package:draw/draw.dart';
import 'package:draw/src/base_impl.dart';

// A Class representing an award or trophy
class Trophy extends RedditBase with RedditBaseInitializedMixin {
  Trophy.parse(Reddit reddit, Map data) : super(reddit) {
    setData(this, data);
  }

  // The ID of the [Trophy] (Can be None).
  String get awardId => data['award_id'];

  // The description of the [Trophy] (Can be None).
  String get description => data['description'];

  // The URL of a 41x41 px icon for the [Trophy].
  String get icon_40 => data['icon_40'];

  // The URL of a 71x71 px icon for the [Trophy].
  String get icon_70 => data['icon_70'];

  // The name of the [Trophy].
  String get name => data['name'];

  // A relevant URL (Can be None).
  String get url => data['url'];
}
