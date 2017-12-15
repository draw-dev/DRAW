// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../exceptions.dart';
import '../../reddit.dart';

/// A mixin containing inbox functionality.
abstract class InboxableMixin {
  String get fullname;
  Reddit get reddit;

  /// Block the user who sent the item.
  ///
  /// Note: Reddit does not permit blocking users unless you have a [Comment] or
  /// [Message] from them in your inbox.
  Future block() async => await reddit.post(apiPath['block'], {'id': fullname});

  // TODO(bkonyi): implement.
  /// Mark the item as collapsed.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  /// void collapse() => throw new DRAWUnimplementedError();

  // TODO(bkonyi): implement.
  /// Mark the item as read.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  /// void markRead() => throw new DRAWUnimplementedError();

  // TODO(bkonyi): implement.
  /// Mark the item as unread.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  /// void markUnread() => throw new DRAWUnimplementedError();

  // TODO(bkonyi): implement.
  /// Mark the item as collapsed.
  ///
  /// This method pertains only to objects which were retrieved via the inbox.
  /// void uncollapse() => throw new DRAWUnimplementedError();
}
