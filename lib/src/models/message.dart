/// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
/// Please see the AUTHORS file for details. All rights reserved.
/// Use of this source code is governed by a BSD-style license that
/// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/base_impl.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/reddit.dart';

class Message extends RedditBase with InboxableMixin {
  var _replies;

  Message(Reddit reddit) : super(reddit);

  Message.parse(Reddit reddit, Map data) : super.loadData(reddit, data);

  Future<String> get author async => await property('author');
  Future<String> get body async => await property('body');

  Future<List<Message>> get replies async {
    if (_replies == null) {
      _replies = <Message>[];
      final repliesListing = await property('replies');
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

  Future<String> get subject async => await property('subject');
}
