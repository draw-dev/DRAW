// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';
import '../subreddit.dart';

/// A mixin containing functionality to send messages to other [Redditor]s or
/// [Subreddit] moderators.
abstract class MessageableMixin {
  Reddit get reddit;
  String get displayName;

  /// Send a message.
  ///
  /// [subject] is the subject of the message, [message] is the content of the
  /// message, and [fromSubreddit] is a [Subreddit] that the message should be
  /// sent from. [fromSubreddit] must be a subreddit that the current user is a
  /// moderator of and has permissions to send mail on behalf of the subreddit.
  Future message(String subject, String message, {Subreddit fromSubreddit}) {
    var messagePrefix = '';
    if (this is Subreddit) {
      messagePrefix = '#';
    }
    final Map<String, String> data = {
      'subject': subject,
      'text': message,
      'to': messagePrefix + displayName,
    };

    if (fromSubreddit != null) {
      data['from_sr'] = fromSubreddit.displayName;
    }
    return reddit.post(apiPath['compose'], data, discardResponse: true);
  }
}
