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

/// A class representing a collection of Reddit communities, also known as a Multireddit.
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

  final RegExp _invalidRegExp = new RegExp(r'(\s|\W|_)+');

  static final RegExp _multiredditRegExp = new RegExp(r'{multi}');

  final String _info_path = apiPath['multireddit_api']
      .replaceAll(_multiredditRegExp, _name)
      .replaceAll(reddit.user._userRegExp, _authorName);

  /// Returns a slug version of the title
  String sluggify(String title) {
    if (title == null) {
      return null;
    }
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

  /// Construct a instance of a [Multireddit] Object.
  Multireddit.parse(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']);

  /// Add a [subreddit] to this [multireddit].
  ///
  /// [subreddit] is the string name of the subreddit to be added to this multi.
  Future add(String subreddit) async {
    String url = apiPath['multireddit_update']
        .replaceAll(reddit.user._userRegExp, _authorName)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(reddit.subreddit._subredditRegExp, subreddit);
    Map data = {'model': "{'name': $subreddit}"};
    await reddit.put(url, data);
    //TODO(ckartik): call to def reset_attributes in base.py, check if we need in dart.
  }

  /// Copy this [Multireddit], and return the new [Multireddit].
  ///
  /// [display_name] is an optional string that will become the display name of the new
  /// multireddit and be used as the source for the [name]. If [display_name] is not
  /// provided, the [name] and [display_name] of the muti being copied will be used.
  ///
  /// Returns  an instance of a [Multireddit].
  Future<Multireddit> copy([String display_name = null]) async {
    String url = apiPath['multireddit_copy'];

    name = sluggify(display_name) ?? _name;
    display_name ??= _display_name;

    data = const {
      kDisplayName: display_name,
      kFrom: _path,
      kTo: apiPath['multiredit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(reddit.user._userRegExp, reddit.user.me()),
    };
    return await reddit.post(url, data);
  }

  /// Delete this [multireddit].
  Future delete() async {
    await reddit.delete(_info_path);
  }

  /// Remove a [Subreddit] from this [Multireddit].
  ///
  /// [subreddit] is a string containing the name of the subreddit to be deleted.
  Future remove(String subreddit) async {
    string url = apiPath['multireddit_update']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(reddit.user._userRegExp, _author)
        .replaceAll(reddit.subreddit._subredditRegExp, subreddit);
    Map data = {'model': "{'name': $subreddit}"};
    await reddit.delete(url, data);
  }

  /// Rename this [Multireddit].
  ///
  /// [display_name] is the new display for this [multireddit].
  /// The [name] will be auto generated from the display_name.
  Future rename(display_name) async {
    String url = apiPath['multireddit_rename'];
    data = {
      kFrom: _path,
      kDisplayName: _display_name,
    };
    await reddit.post(url, data);
    _display_name = display_name;
  }

  /// Update this [Multireddit].
  ///
  /// TODO(ckartik): implement!
  void update(Map newSettings) {
    
  }
}
