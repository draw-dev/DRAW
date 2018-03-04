/// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'package:draw/src/base_impl.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/reddit.dart';

class Message extends RedditBase with InboxableMixin {
  var _replies;

  Message.parse(Reddit reddit, Map data) : super.loadData(reddit, data);

  /// The author of the [Message].
  String get author => data['author'];

  /// The body of the [Message].
  String get body => data['body'];

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
}
