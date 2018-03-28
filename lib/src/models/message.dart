/// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'package:draw/src/base_impl.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/reddit.dart';

/// A fully initialized class which represents a Message from the [Inbox].
class Message extends RedditBase
    with InboxableMixin, RedditBaseInitializedMixin {
  var _replies;

  Message.parse(Reddit reddit, Map data) : super(reddit) {
    setData(this, data);
  }

  /// The author of the [Message].
  String get author => data['author'];

  /// The body of the [Message].
  String get body => data['body'];

  /// When was this [Message] created.
  DateTime get createdUtc => new DateTime.fromMillisecondsSinceEpoch(
      data['created_utc'].round() * 1000,
      isUtc: true);

  /// Who is this [Message] for.
  ///
  /// Can be for either a [Redditor] or [Subreddit].
  String get destination => data['dest'];

  /// The type of distinguishment that is assigned to this message.
  ///
  /// Can be `null` if the [Message] isn't distinguished. An example value for
  /// this field is 'moderator'
  String get distinguished => data['distinguished'];

  /// The [List] of replies to this [Message].
  ///
  /// Returns and empty list if there are no replies.
  List<Message> get replies {
    if (_replies == null) {
      _replies = <Message>[];
      final repliesListing = data['replies'];
      if (repliesListing == null) {
        return <Message>[];
      }
      final replies = repliesListing['data']['children'];
      for (final reply in replies) {
        _replies.add(reddit.objector.objectify(reply));
      }
    }
    return _replies;
  }

  /// A [SubredditRef] representing the subreddit this message was sent to,
  /// for ModMail [Message]s.
  ///
  /// Returns `null` if this is not a ModMail [Message].
  SubredditRef get subreddit =>
      GetterUtils.subredditRefOrNull(reddit, data['subreddit']);
}
