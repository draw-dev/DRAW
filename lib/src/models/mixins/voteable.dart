// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/reddit.dart';

/// A mixin which implements voting functionality.
abstract class VoteableMixin implements RedditBase {
  Reddit get reddit;
  Future<String> get fullname;

  /// The author of the item.
  Future<String> get author async => await property('author');

  /// The body of the item.
  ///
  /// Returns null for non-text [Submission]s.
  Future<String> get body async => await property('body');

  /// The karma score of the voteable item.
  Future<int> get score async => await property('score');

  Future _vote(String direction) async =>
      reddit.post(apiPath['vote'], {'dir': direction, 'id': await fullname},
          discardResponse: true);

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future clearVote() async => _vote('0');

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future downvote() async => _vote('-1');

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future upvote() async => _vote('1');
}
