// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'api_paths.dart';
import 'base.dart';
import 'reddit.dart';
import 'listing/listing_generator.dart';
import 'models/multireddit.dart';
import 'models/redditor.dart';
import 'models/subreddit.dart';

/// The [User] class provides methods to access information about the currently
/// authenticated user.
class User extends RedditBase {
  User(Reddit reddit) : super(reddit);

  /// Returns a [Future<List<Redditor>>] of blocked Redditors.
  Future<List<Redditor>> blocked() async {
    return reddit.get(apiPath['blocked']);
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// contributor of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> contributorSubreddits(
          {int limit = ListingGenerator.defaultRequestLimit, Map params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_contributor'],
          limit: limit, params: params);

  /// Returns a [Future<List<Redditor>>] of friends.
  Future<List<Redditor>> friends() async {
    return reddit.get(apiPath['friends']);
  }

  /// Returns a [Future<Map>] mapping subreddits to karma earned on the given
  /// subreddit.
  Future<Map<Subreddit, Map<String, int>>> karma() async {
    return reddit.get(apiPath['karma']);
  }

  // TODO(bkonyi): actually do something with [useCache].
  /// Returns a [Future<Redditor>] which represents the current user.
  Future<Redditor> me({useCache: true}) async {
    return reddit.get(apiPath['me']);
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// moderator of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> moderatorSubreddits(
          {int limit = ListingGenerator.defaultRequestLimit, Map params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_moderator'],
          limit: limit, params: params);

  /// Returns a [Stream] of [Multireddit]s that belongs to the currently
  /// authenticated user.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Future<List<Multireddit>> multireddits() async {
    return reddit.get(apiPath['my_multireddits']);
  }

  /// Returns a [Stream] of [Subreddit]s the currently authenticated user is a
  /// subscriber of.
  ///
  /// [limit] is the number of [Subreddit]s to request, and [params] should
  /// contain any additional parameters that should be sent as part of the API
  /// request.
  Stream<Subreddit> subreddits(
          {int limit = ListingGenerator.defaultRequestLimit, Map params}) =>
      ListingGenerator.generator<Subreddit>(reddit, apiPath['my_subreddits'],
          limit: limit, params: params);
}
