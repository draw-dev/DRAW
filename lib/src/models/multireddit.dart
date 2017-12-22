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
  List<Subreddit> _subreddits;
  Redditor _author;
  String _displayName;
  String _name;
  String _path;
  final String _infoPath = apiPath['multireddit_api']
      .replaceAll(_multiredditRegExp, _name)
      .replaceAll(reddit.user._userRegExp, _author.displayName);

  String get displayName => _displayName;
  String get name => _name;
  String get path => _path ?? '/';
  final RegExp _invalidRegExp = new RegExp(r'(\s|\W|_)+');
  static final RegExp _multiredditRegExp = new RegExp(r'{multi}');

  /// Returns a slug version of the [title].
  static String sluggify(String title) {
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
      : super.loadData(reddit, data['data']) {
    _name = data['data']['name'];
    _author = Redditor(reddit, _path.split('/')[2]);
    _path = apiPath['multireddit']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(reddit.user._userREgExp, _author.displayName);
  }

  /// Add a [subreddit] to this [multireddit].
  ///
  /// [subreddit] is the string name of the subreddit to be added to this multi.
  Future add(String subreddit) async {
    String url = apiPath['multireddit_update']
        .replaceAll(reddit.user._userRegExp, _author.displayName)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(reddit.subreddit._subredditRegExp, subreddit);
    Map data = {'model': "{'name': $subreddit}"};
    await reddit.put(url, data);
    // TODO(ckartik): Find API path to GET subreddits list and construct into list.
    // May need to add the path: /api/multi/multipath to api_path.dart
  }

  /// Copy this [Multireddit], and return the new [Multireddit].
  ///
  /// [displayName] is an optional string that will become the display name of the new
  /// multireddit and be used as the source for the [name]. If [displayName] is not
  /// provided, the [name] and [displayName] of the muti being copied will be used.
  ///
  /// Returns  an instance of a [Multireddit].
  Future<Multireddit> copy([String displayName = null]) async {
    String url = apiPath['multireddit_copy'];

    name = sluggify(displayName) ?? _name;
    displayName ??= _displayName;

    data = const {
      kDisplayName: displayName,
      kFrom: _path,
      kTo: apiPath['multiredit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(reddit.user._userRegExp, reddit.user.me()),
    };
    return await reddit.post(url, data);
  }

  /// Delete this [multireddit].
  Future delete() async {
    await reddit.delete(_infoPath);
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
  /// [displayName] is the new display for this [multireddit].
  /// The [name] will be auto generated from the displayName.
  Future rename(displayName) async {
    String url = apiPath['multireddit_rename'];
    data = {
      kFrom: _path,
      kDisplayName: _displayName,
    };
    await reddit.post(url, data);
    _displayName = displayName;
  }

  /// Update this [Multireddit].
  ///
  /// [newSettings] is a map potentially containing a list of keyword args
  /// that should be updated. These include:
  /// [display_name]: the display_name for the multireddit.
  /// [subreddits]: A list of subreddits in this multireddit.
  /// [description_md]: A description of this multireddit, formated in markdown.
  /// [icon_name]: can be one of: [art and design], [ask], [books], [business],
  /// [cars], [comic], [cute animals], [diy], [entertainment], [food and drink],
  /// [funny], [games], [grooming], [health], [life advice], [military],
  /// [models pinup], [music], [news], [philosophy], [pictures and gifs], [science],
  /// [shopping], [sports], [style], [tech], [travel], [unusual stories], [video],
  /// or [None].
  /// [key_color]: RGB Hex color code of the form i.e "#FFFFFF".
  /// [visibility]: Can be one of: [hidden], [private], [public].
  /// [weighting_scheme]: Can be one of: [classic], [fresh].
  void update(Map newSettings) async {
    if (newSettings.containsKey('subreddits')) {
      List newSubredditsList = [];
      newSettings['subreddits'].forEach((item) {
        newSubredditsList.add({'name': item});
      });
      //TODO(ckartik): Test if this type change in a map works.
      newSettings['subreddits'] = newSubredditsList;
    }
    var res = await reddit.put(_infoPath, newSettings.toString());
    Multireddit newMulti = new Multireddit(reddit, response['data']);
    _displayName = newMulti.displayName;
    _name = newMulti.name;
  }
}
