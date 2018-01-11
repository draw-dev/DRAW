// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../api_paths.dart';
import '../base.dart';
import '../reddit.dart';
import '../user.dart';
import 'redditor.dart';
import 'subreddit.dart';

/// A class which repersents a Multireddit, which is a collection of
/// [Subreddit]s. This is not yet implemented.
class Multireddit extends RedditBase {
  final String kDisplayName = 'display_name';
  final String kFrom = "from";
  final String kTo = "to";
  final String multiApi = 'multireddit_api';
  final String multiRename = 'multireddit_rename';

  final int redditorNameInPathIndex = 2;

  static final RegExp _multiredditRegExp = new RegExp(r'{multi}');
  static RegExp get multiredditRegExp => _multiredditRegExp;

  Redditor _author;

  String _displayName;
  String _infoPath;
  String _name;
  String _path;

  String get displayName => _displayName;
  String get name => _name;
  String get path => _path ?? '/';

  Multireddit.parse(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']) {
    _name = data['data']['name'];

    _author = new Redditor.name(
        reddit, data['data']['path'].split('/')[redditorNameInPathIndex]);
    _path = apiPath['multireddit']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(User.userRegExp, _author.displayName);
    _infoPath = apiPath[multiApi]
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(User.userRegExp, _author.displayName);
  }

  /// Returns a slug version of the [title].
  static String sluggify(String title) {
    if (title == null) {
      return null;
    }
    final RegExp _invalidRegExp = new RegExp(r'(\s|\W|_)+');
    var titleScoped = title.replaceAll(_invalidRegExp, '_').trim();
    if (titleScoped.length > 21) {
      titleScoped = titleScoped.substring(21);
      final lastWord = titleScoped.lastIndexOf('_');
      //TODO(ckartik): Test this well.
      if (lastWord > 0) {
        titleScoped = titleScoped.substring(lastWord);
      }
    }
    return titleScoped ?? '_';
  }

  /// Add a [Subreddit] to this [Multireddit].
  ///
  /// [subreddit] is the name of the [Subreddit] to be added to this [Multireddit].
  Future add(String subreddit) async {
    final url = apiPath['multireddit_update']
        .replaceAll(User.userRegExp, _author.displayName)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(Subreddit.subredditRegExp, subreddit);
    final data = {'model': "{'name': $subreddit}"};
    // TODO(ckartik): Check if it may be more applicable to use POST here.
    // Direct Link: (https://www.reddit.com/dev/api/#DELETE_api_multi_{multipath}).
    await reddit.put(url, body: data);
    // TODO(ckartik): Research if we should GET subreddits.
  }

  /// Copy this [Multireddit], and return the new [Multireddit].
  ///
  /// [displayName] is an optional string that will become the display name of the new
  /// multireddit and be used as the source for the [name]. If [displayName] is not
  /// provided, the [name] and [displayName] of the muti being copied will be used.
  Future<Multireddit> copy([String displayName]) async {
    final url = apiPath['multireddit_copy'];
    final name = sluggify(displayName) ?? _name;

    displayName ??= _displayName;

    final data = {
      kDisplayName: displayName,
      kFrom: _path,
      kTo: apiPath['multiredit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(User.userRegExp, reddit.user.me()),
    };
    return await reddit.post(url, data);
  }

  /// Delete this [Multireddit].
  Future delete() async {
    await reddit.delete(_infoPath);
  }

  /// Remove a [Subreddit] from this [Multireddit].
  ///
  /// [subreddit] contains the name of the subreddit to be deleted.
  Future remove(String subreddit) async {
    final url = apiPath['multireddit_update']
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(User.userRegExp, _author)
        .replaceAll(Subreddit.subredditRegExp, subreddit);
    final data = {'model': "{'name': $subreddit}"};
    await reddit.delete(url, body: data);
  }

  /// Rename this [Multireddit].
  ///
  /// [displayName] is the new display for this [Multireddit].
  /// The [name] will be auto generated from the displayName.
  Future rename(displayName) async {
    final url = apiPath[multiRename];
    final data = {
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
  // TODO(chkartik): Import Color into here.
  /// [key_color]: RGB Hex color code of the form i.e "#FFFFFF".
  /// [visibility]: Can be one of: [hidden], [private], [public].
  /// [weighting_scheme]: Can be one of: [classic], [fresh].
  // TODO(ckartik): Pass in optional params instead of Map, and turn these into enums! Not smart Kartik! :(
  Future update(Map newSettings) async {
    if (newSettings.containsKey('subreddits')) {
      final List newSubredditsList = [];
      newSettings['subreddits'].forEach((item) {
        newSubredditsList.add({'name': item});
      });
      //TODO(ckartik): Test if this type change in a map works.
      newSettings['subreddits'] = newSubredditsList;
    }
    final res = await reddit.put(_infoPath, body: newSettings.toString());
    final Multireddit newMulti = new Multireddit.parse(reddit, res['data']);
    _displayName = newMulti.displayName;
    _name = newMulti.name;
  }
}
