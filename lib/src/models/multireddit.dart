// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import '../api_paths.dart';
import '../base.dart';
import '../exceptions.dart';
import '../listing/listing_generator.dart';
import '../listing/mixins/base.dart';
import '../listing/mixins/gilded.dart';
import '../listing/mixins/rising.dart';
import '../listing/mixins/subreddit.dart';
import '../reddit.dart';
import '../util.dart';
import 'comment.dart';
import 'mixins/messageable.dart';
import 'redditor.dart';
import 'submission.dart';
import 'user_content.dart';

///A class representing a collection of Reddit communities, also known as a Multireddit.
class Multireddit extends RedditBase
    with
        BaseListingMixinm,
        GildedListingMixin,
        MessageableMixin,
        RisingListingMixin,
        SubredditListingMixin {
  String _name;
  String _path;

  String get displayName => _name;
  String get path => _path;

  String _authorName;

  static final RegExp _invalidRegExp = new RegExp(r'(\s|\W|_)+');

  final RegExp _multiredditRegExp = new RegExp(r'{multi}');
  final RegExp _subredditRegExp = new RegExp(r'{subreddit}');
  final RegExp _userRegExp = new RegExp(r'{user}');

  ///Returns a slug versio of the title
  static String sluggify(String title) {
    title = title.replaceAll(_invalidRegExp, '_').trim();
    if (title.length > 21) {
      title = title.substring(21);
      String last_word = title.lastIndexOf('_');
      if (last_word > 0) {
        title = title.substring(last_word);
      }
    }
    return title ?? '_';
  }

  Multireddit.parse(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']);

  void add(String subreddit) {
    String url = apiPath['multireddit_update']
        .replaceAll(_userRegExp, _authorName)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(_subredditRegExp, subreddit);
    var data = "I DONT KNOW WHAT TO PUT HERE YET";
    reddit.put(url, data);
  }
}
