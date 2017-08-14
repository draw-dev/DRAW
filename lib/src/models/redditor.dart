// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import '../api_paths.dart';
import '../base.dart';
import '../exceptions.dart';
import '../reddit.dart';
import '../listing/listing_generator.dart';
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
  final _userRegExp = new RegExp(r'{user}');

  Redditor.parse(Reddit reddit, Map data) : super.loadData(reddit, data) {
    if (!data.containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception
      throw new DRAWUnimplementedError();
    }
    _name = data['name'];
  }

  Redditor.name(Reddit reddit, String name)
      : _name = name,
        super(reddit);

  Stream<Submission> controversial(
      {TimeFilter timeFilter: TimeFilter.all, Map params}) {
    throw new DRAWUnimplementedError();
  }

  Stream<RedditBase> downvoted({Map params}) =>
      ListingGenerator.generator<RedditBase>(
          reddit, apiPath['downvoted'].replaceAll(_userRegExp, _name),
          params: params);

  Future friend({String note = ''}) =>
      reddit.put(
          apiPath['friend_v1'].replaceAll(_userRegExp, _name),
          body: JSON.encode({'note': note}));

  Future<Redditor> friendInfo() {
    throw new DRAWUnimplementedError();
  }

  String get fullname => this['fullname'];

  Future gild({int months = 1}) async {
    final body = {
      'months': months.toString(),
    };
    reddit.post(apiPath['gild_user'].replaceAll(_userRegExp, _name), body);
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

  // TODO(bkonyi): SubmissionStream
  dynamic get submissions => throw new DRAWUnimplementedError();

  Stream<RedditBase> top({TimeFilter timeFiler: TimeFilter.all, Map params}) {
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
          reddit, apiPath['upvoted'].replaceAll(_userRegExp, _name),
          params: params);
}

class RedditorStream extends RedditBase {
  final Redditor redditor;

  RedditorStream(this.redditor) : super(redditor.reddit);

  Stream<Comment> comments() {
    throw new DRAWUnimplementedError();
  }

  Stream<Submission> submissions() {
    throw new DRAWUnimplementedError();
  }
}
