// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';

/// Interface for classes that can optionally receive inbox replies.
mixin InboxToggleableMixin implements RedditBaseInitializedMixin {
  /// Disable inbox replies for the item.
  Future<void> disableInboxReplies() async =>
      reddit.post(apiPath['sendreplies'], {'id': fullname, 'state': 'false'},
          discardResponse: true);

  /// Enable inbox replies for the item.
  Future<void> enableInboxReplies() async =>
      reddit.post(apiPath['sendreplies'], {'id': fullname, 'state': 'true'},
          discardResponse: true);
}
