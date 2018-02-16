// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';

/// A mixin which implements voting functionality.
abstract class VoteableMixin {
  Reddit get reddit;
  Future<String> get fullname;

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
