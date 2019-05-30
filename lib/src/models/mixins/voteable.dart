// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/reddit.dart';

enum VoteState {
  none,
  upvoted,
  downvoted,
}

/// A mixin which provides voting functionality for [Comment] and [Submission].
mixin VoteableMixin implements RedditBaseInitializedMixin {
  Reddit get reddit;
  String get fullname;

  /// The author of the item.
  String get author => data['author'];

  /// The body of the item.
  ///
  /// Returns null for non-text [Submission]s.
  String get body => data['body'];

  /// The karma score of the voteable item.
  int get score => data['score'];

  /// Has the currently authenticated [User] voted on this [UserContent].
  ///
  /// Returns [VoteState.upvoted] if the content has been upvoted,
  /// [VoteState.downvoted] if it has been downvoted, and [VoteState.none]
  /// otherwise.
  VoteState get vote {
    if (data['likes'] == null) {
      return VoteState.none;
    } else if (data['likes']) {
      return VoteState.upvoted;
    } else {
      return VoteState.downvoted;
    }
  }

  Future<void> _vote(String direction) async {
    await reddit.post(apiPath['vote'], {'dir': direction, 'id': fullname},
        discardResponse: true);
    switch (direction) {
      case '0':
        data['likes'] = null;
        break;
      case '1':
        data['likes'] = true;
        break;
      case '-1':
        data['likes'] = false;
    }
  }

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> clearVote() async => _vote('0');

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> downvote() async => _vote('-1');

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> upvote() async => _vote('1');



  Future<void> _riskyVote(String direction) async {
    switch (direction) {
      case '0':
        data['likes'] = null;
        break;
      case '1':
        data['likes'] = true;
        break;
      case '-1':
        data['likes'] = false;
    }
    await reddit.post(apiPath['vote'], {'dir': direction, 'id': fullname},
      discardResponse: true);
  }

  /// Clear the authenticated user's vote on the object.
  /// Does **not** waitfor the post request to be resolved before updating the local object
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> riskyClearVote() async => _riskyVote('0');
    /// Casts a downvote for the authenticated user's vote on the object.
  /// Does **not** wait for the post request to be resolved before updating the local object
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> riskyDownvote() async => _riskyVote('-1');
  /// Casts an upvote for the authenticated user's vote on the object.
  /// Does **not** wait for the post request to be resolved before updating the local object
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> friskyUpvote() async => _riskyVote('1');





}
