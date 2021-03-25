// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/subreddit.dart';

/// The [User] class provides methods to access information about the currently
/// authenticated user.
class User extends RedditBase {
  User(Reddit reddit) : super(reddit);

  /// Returns a [Future<List<Redditor>>] of blocked Redditors.
  Future<List<Redditor>> blocked() async {
    return (await reddit.get(apiPath['blocked'])).cast<Redditor>();
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// contributor of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> contributorSubreddits(
          {int limit = ListingGenerator.defaultRequestLimit,
          Map<String, String>? params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_contributor'],
          limit: limit, params: params);

  /// Returns a [Future<List<Redditor>>] of friends.
  Future<List<Redditor>> friends() async {
    return (await reddit.get(apiPath['friends'])).cast<Redditor>();
  }

  /// Returns a [Future<Map>] mapping subreddits to karma earned on the given
  /// subreddit.
  Future<Map<Subreddit, Map<String, int>>?> karma() async {
    return (await reddit.get(apiPath['karma']))
        as Map<Subreddit, Map<String, int>>?;
  }

  // TODO(bkonyi): actually do something with [useCache].
  /// Returns a [Future<Redditor>] which represents the current user.
  Future<Redditor?> me({useCache = true}) async {
    return (await reddit.get(apiPath['me'])) as Redditor?;
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// moderator of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> moderatorSubreddits(
          {int limit = ListingGenerator.defaultRequestLimit,
          Map<String, String>? params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_moderator'],
          limit: limit, params: params);

  /// Returns a [Stream] of [Multireddit]s that belongs to the currently
  /// authenticated user.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Future<List<Multireddit>?> multireddits() async {
    return (await reddit.get(apiPath['my_multireddits'])).cast<Multireddit>();
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// subscriber of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> subreddits(
          {int limit = ListingGenerator.defaultRequestLimit,
          Map<String, String>? params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_subreddits'],
          limit: limit, params: params);
}
