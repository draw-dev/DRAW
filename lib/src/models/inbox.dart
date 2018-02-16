// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/message.dart';

class Inbox extends RedditBase {
  static final _messagesRegExp = new RegExp(r'{id}');

  Inbox(Reddit reddit) : super(reddit);

  /// Returns a [Stream] of all inbox comments and messages.
  Stream all() =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['inbox']);

  /// Marks a list of [Comment] and/or [Message] objects as collapsed.
  Future collapse(List items) => _itemHelper(apiPath['collapse'], items);

  /// Returns a [Stream<Comment>] of all comment replies.
  Stream<Comment> commentReplies() =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['comment_replies']);

  /// Marks a list of [Comment] and/or [Message] objects as read.
  Future markRead(List items) => _itemHelper(apiPath['read_message'], items);

  /// Marks a list of [Comment] and/or [Message] objects as unread.
  Future markUnread(List items) =>
      _itemHelper(apiPath['unread_message'], items);

  Future _itemHelper(String api, List items) async {
    var start = 0;
    var end = min(items.length, 25);
    while (true) {
      final sublist = items.sublist(start, end);
      final nameList = <String>[];
      for (final m in sublist) {
        nameList.add(await m.fullname);
      }
      final data = {
        'id': nameList.join(','),
      };
      await reddit.post(api, data, discardResponse: true);
      start = end;
      end = min(items.length, end + 25);
      if (start == end) {
        break;
      }
    }
  }

  /// Returns a [Stream<Comment>] of comments in which the currently
  /// authenticated user was mentioned.
  ///
  /// A mention is a [Comment] in which the authorized user is named in the
  /// form: ```/u/redditor_name```.
  Stream<Comment> mentions() =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['mentions']);

  /// Returns a [Message] associated with a given fullname.
  ///
  /// If [messageId] is not a valid fullname for a message, null is returned.
  Future<Message> message(String messageId) async {
    final listing = await reddit
        .get(apiPath['message'].replaceAll(_messagesRegExp, messageId));
    final messages = <Message>[];
    final message = listing['listing'][0];
    messages.add(message);
    messages.addAll(await message.replies);
    for (final m in messages) {
      if (await m.fullname == messageId) {
        return m;
      }
    }
    return null;
  }

  /// Returns a [Stream<Message>] of inbox messages.
  Stream<Message> messages() =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['messages']);

  /// Returns a [Stream<Message>] of sent messages.
  Stream<Message> sent() =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['sent']);

  /// Returns a live [Stream] of [Comment] and [Message] objects.
  ///
  /// If [pauseAfter] is provided, the [Stream] will close after [pauseAfter]
  /// results are yielded. Oldest items are yielded first.
  Stream stream({int pauseAfter}) =>
      streamGenerator(unread, pauseAfter: pauseAfter);

  /// Returns a [Stream<Comment>] of replies to submissions made by the
  /// currently authenticated user.
  Stream<Comment> submissionReplies() => ListingGenerator.createBasicGenerator(
      reddit, apiPath['submission_replies']);

  /// Marks a list of [Comment] and/or [Message] objects as uncollapsed.
  Future uncollapse(List items) => _itemHelper(apiPath['uncollapse'], items);

  /// Returns a [Stream] of [Comment] and/or [Message] objects that have not yet
  /// been read.
  ///
  /// [markRead] specifies whether or not to mark the inbox as having no new
  /// messages.
  Stream unread({int limit, bool markRead = false}) {
    final params = {
      'mark': markRead.toString(),
    };
    return ListingGenerator.generator(reddit, apiPath['unread'],
        params: params, limit: limit);
  }
}
