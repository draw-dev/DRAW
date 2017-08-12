// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import '../api_paths.dart';
import '../base.dart';
import '../exceptions.dart';
import '../listing/mixins/base.dart';
import '../listing/mixins/gilded.dart';
import '../listing/mixins/redditor.dart';
import '../reddit.dart';
import 'comment.dart';
import 'multireddit.dart';
import 'submission.dart';
import 'subreddit.dart';

enum TimeFilter {
  all,
  day,
  hour,
  month,
  week,
  year,
}

class Redditor extends RedditBase {
  String _name;
  Uri _path;
  final _userRegExp = new RegExp(r'{user}');

  Redditor.parse(Reddit reddit, Map data) : super.loadData(reddit, data) {
    if (!data.containsKey('name') &&
        !(data.containsKey('kind') && data['kind'] == 't2')) {
      // TODO(bkonyi) throw invalid object exception
      throw new DRAWUnimplementedError();
    }
    _name = data['name'];
    _path = apiPath['user'].replaceAll(_userRegExp, _name);
  }

  Redditor.name(Reddit reddit, String name)
      : _name = name,
        _path = apiPath['user'].replaceAll(_userRegExp, name),
        super.withPath(reddit, Redditor._generateInfoPath(name));

  static String _generateInfoPath(String name) =>
      apiPath['user_about'].replaceAll(_userRegExp, name);

  /// Adds the [Redditor] as a friend. [note] is an optional string that is
  /// associated with the friend entry. Providing [note] requires Reddit Gold.
  Future friend({String note = ''}) async =>
      reddit.put(apiPath['friend_v1'].replaceAll(_userRegExp, _name),
          body: JSON.encode({'note': note}));

  // TODO(bkonyi): Do we want to return a new Redditor object or just populate
  // the fields in this object?
  Future<Redditor> friendInfo() async =>
      reddit.get(apiPath['friend_v1'].replaceAll(_userRegExp, _name));

  /// Returns the object's fullname.
  ///
  /// A fullname is an object's kind mapping (i.e., t3), followed by an
  /// underscore and the object's ID (i.e., t1_c5s96e0).
  Future<String> get fullname async => property('fullname');

  /// Gives Reddit Gold to the [Redditor]. [months] is the number of months of
  /// Reddit Gold to be given to the [Redditor].
  Future gild({int months = 1}) async {
    final body = {
      'months': months.toString(),
    };
    await reddit.post(
        apiPath['gild_user'].replaceAll(_userRegExp, _name), body);
  }

  /// Send a message to the [Redditor]. [subject] is the subject of the message,
  /// [message] is the content of the message, and [fromSubreddit] is a
  /// [Subreddit] that the message should be sent from. [fromSubreddit] must be
  /// a subreddit that the current user is a moderator of and has permissions to
  /// send mail on behalf of the subreddit.
  Future message(String subject, String message,
          {Subreddit fromSubreddit}) async =>
      throw new DRAWUnimplementedError();

  /// Returns a [List] of the [Redditor]'s public [Multireddit]'s.
  Future<List<Multireddit>> multireddits() async =>
      reddit.get(apiPath['multi_user'].replaceAll(_userRegExp, _name));

  // TODO(bkonyi): Add code samples.
  /// Provides a [RedditorStream] for the current [Redditor].
  ///
  /// [RedditorStream] can be used to retrieve new comment and submissions made
  /// by a [Redditor] indefinitely.
  RedditorStream get stream => new RedditorStream(this);

  // TODO(bkonyi): implement.
  /// Unblock the [Redditor].
  Future unblock() async => throw new DRAWUnimplementedError();

  /// Unfriend the [Redditor].
  Future unfriend() async =>
      reddit.delete(apiPath['friend_v1'].replaceAll(_userRegExp, _name));
}

// TODO(bkonyi): implement.
class RedditorStream extends RedditBase {
  final Redditor redditor;

  RedditorStream(this.redditor) : super(redditor.reddit);

  Stream<Comment> comments() {
    throw new DRAWUnimplementedError();
  }

  Stream<Submission> submissions() {
    throw new DRAWUnimplementedError();
  }

  Stream<Submission> controversial({TimeFilter timeFilter: all, Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> downvoted({Map params}) =>
      ListingGenerator.generator<RedditBase>(
          reddit, apiPath['downvoted'].replace(_userRegExp, _name),
          params: params);

  // TODO(bkonyi) implement Reddit.put()?
  Future friend({String note = ''}) =>
      reddit.put(apiPath['friend_v1'], {'name': _name, 'note': note});

  Future<Redditor> friendInfo() {
    throw new DRAWUnimplementedError();
  }

  String get fullname => this['fullname'];

  Future gild({int months = 1}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> gilded({Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> gildings({Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> hidden({Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> hot({Map params}) {
    throw new DRAWUnimplementedError();
  }

  Future message(String subject, String message, {Subreddit fromSubreddit}) {
    throw new DRAWUnimplementedError();
  }

  Future<List<Multireddit>> multireddits() {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> newItems({Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> saved({Map params}) {
    throw new DRAWUnimplementedError();
  }

  RedditorStream get stream => new RedditorStream(this);

  SubmissionStream get submissions => throw new DRAWUnimplementedError();

  Stream<RedditBase> top({TimeFilter timeFiler: all, Map params}) {
    throw new DRAWUnimplementedError();
  }

  Future unblock() {
    throw new DRAWUnimplementedError();
  }

  Future unfriend() {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> upvoted({Map params}) =>
      ListingGenerator.generator<RedditBase>(
          reddit, apiPath['upvoted'].replace(_userRegExp, _name),
          params: params);
}

class RedditorStream extends RedditBase {
  final Redditor redditor;

  RedditorStream(this.redditor);

  Stream<Comment> comments() {
    throw new DRAWUnimplementedError();
  }

  Stream<Submission> submissions() {
    throw new DRAWUnimplementedError();
  }
}
