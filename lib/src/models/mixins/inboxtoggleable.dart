// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';

/// Interface for classes that can optionally receive inbox replies.
abstract class InboxToggleableMixin {
  Reddit get reddit;
  Future<String> get fullname;

  /// Disable inbox replies for the item.
  Future disableInboxReplies() async => reddit.post(
      apiPath['sendreplies'], {'id': await fullname, 'state': 'false'},
      discardResponse: true);

  /// Enable inbox replies for the item.
  Future enableInboxReplies() async => reddit.post(
      apiPath['sendreplies'], {'id': await fullname, 'state': 'true'},
      discardResponse: true);
}
