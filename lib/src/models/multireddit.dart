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

  ///Returns a slug version of the title
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

  ///TODO(k5chopra): Research if this would be better off, pre-computed
  String _info_path() {
    return apiPath['multireddit_api']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(_userRegExp, _authorName);
  }

  void add(String subreddit) {
    String url = apiPath['multireddit_update']
        .replaceAll(_userRegExp, _authorName)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(_subredditRegExp, subreddit);
    var data = "I DONT KNOW WHAT TO PUT HERE YET";
    reddit.put(url, data);
  }

  Multireddit copy([String display_name = null]) {
    String name;
    String url = apiPath['multireddit_copy'];
    if (display_name != null) {
      name = sliggify(display_name);
    } else {
      display_name = _name;
      name = _name;
    }
    data = const {
      kDisplayName: display_name,
      kFrom: _path,
      kTo: apiPath['multiredit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(_userRegExp, reddit.user.me()),
    };
    return reddit.post(url, data);
  }

  ///Delete this [multireddit]
  void delete() {
    reddit.request(_info_path());
  }

  void remove(String subreddit) {
    string url = apiPath['multireddit_update']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(_userRegExp, _author)
        .replaceAll(_subredditRegExp, subreddit);
    data = "Need to do this part";
    reddit.delete(url, data);
  }

  void rename(display_name) {
    String url = apiPath['multireddit_rename'];
    data = {
      kFrom: _path,
      kDisplayName: display_name,
    };
    updated = reddit.post(url, data);
  }

  //Need to implment Update
}
