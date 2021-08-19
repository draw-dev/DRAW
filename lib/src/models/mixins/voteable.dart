// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/models/redditor.dart';

enum VoteState {
  none,
  upvoted,
  downvoted,
}

int _voteStateToIndex(VoteState vote) {
  switch (vote) {
    case VoteState.none:
      return 0;
    case VoteState.upvoted:
      return 1;
    case VoteState.downvoted:
      return -1;
  }
}

/// A mixin which provides voting functionality for [Comment] and [Submission].
mixin VoteableMixin implements RedditBaseInitializedMixin {
  /// The author of the item.
  // String get author => data!['author'];

  /// Returns the [Redditor] associated with this item.
  RedditorRef get author => RedditorRef.name(reddit, data!['author']);

  /// The body of the item.
  ///
  /// Returns null for non-text [Submission]s.
  String? get body => data!['body'];

  /// The karma score of the voteable item.
  int get score => data!['score'];

  /// Has the currently authenticated [User] voted on this [UserContent].
  ///
  /// Returns [VoteState.upvoted] if the content has been upvoted,
  /// [VoteState.downvoted] if it has been downvoted, and [VoteState.none]
  /// otherwise.
  VoteState get vote {
    if (data!['likes'] == null) {
      return VoteState.none;
    } else if (data!['likes']) {
      return VoteState.upvoted;
    } else {
      return VoteState.downvoted;
    }
  }

  void _updateScore(VoteState newVote) {
    if (vote == VoteState.upvoted) {
      if (newVote == VoteState.downvoted) {
        data!['score'] = score - 2;
      } else if (newVote == VoteState.none) {
        data!['score'] = score - 1;
      }
    } else if (vote == VoteState.none) {
      if (newVote == VoteState.downvoted) {
        data!['score'] = score - 1;
      } else if (newVote == VoteState.upvoted) {
        data!['score'] = score + 1;
      }
    } else if (vote == VoteState.downvoted) {
      if (newVote == VoteState.upvoted) {
        data!['score'] = score + 2;
      } else if (newVote == VoteState.none) {
        data!['score'] = score + 1;
      }
    }
  }

  Future<void> _vote(VoteState direction, bool waitForResponse) async {
    if (vote == direction) {
      return;
    }
    final response = reddit.post(
        apiPath['vote'],
        {
          'dir': _voteStateToIndex(direction).toString(),
          'id': fullname,
        },
        discardResponse: true);
    if (waitForResponse) {
      await response;
    }

    _updateScore(direction);

    switch (direction) {
      case VoteState.none:
        data!['likes'] = null;
        break;
      case VoteState.upvoted:
        data!['likes'] = true;
        break;
      case VoteState.downvoted:
        data!['likes'] = false;
    }
  }

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> clearVote({bool waitForResponse = true}) async =>
      _vote(VoteState.none, waitForResponse);

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> downvote({bool waitForResponse = true}) async =>
      _vote(VoteState.downvoted, waitForResponse);

  /// Clear the authenticated user's vote on the object.
  ///
  /// Note: votes must be cast on behalf of a human user (i.e., no automatic
  /// voting by bots). See Reddit rules for more details on what is considered
  /// vote cheating or manipulation.
  Future<void> upvote({bool waitForResponse = true}) async =>
      _vote(VoteState.upvoted, waitForResponse);
}
