// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../base.dart';
import '../exceptions.dart';
import '../reddit.dart';

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
    if (!data.containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception
      throw new DRAWUnimplementedError();
    }
    _name = data['name'];
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
