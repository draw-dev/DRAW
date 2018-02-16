// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/reddit.dart';

/// A mixin containing inbox functionality.
abstract class InboxableMixin {
  Future<String> get fullname;
  Reddit get reddit;

  /// Block the user who sent the item.
  ///
  /// Note: Reddit does not permit blocking users unless you have a [Comment] or
  /// [Message] from them in your inbox.
  Future block() async =>
      await reddit.post(apiPath['block'], {'id': await fullname});

  /// Mark the item as collapsed.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  Future collapse() async => await reddit.inbox.collapse([this]);

  /// Mark the item as read.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  Future markRead() async => await reddit.inbox.markRead([this]);

  /// Mark the item as unread.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  Future markUnread() async => await reddit.inbox.markUnread([this]);

  /// Mark the item as collapsed.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  Future uncollapse() async => await reddit.inbox.uncollapse([this]);
}
