// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';

/// Interface for ReddieBase classes that can be reported.
mixin ReportableMixin {
  Reddit get reddit;
  String get fullname;

  /// Report this object to the moderators of its [Subreddit].
  ///
  /// [reason] is the reason for the report.
  Future<void> report(String reason) async => reddit.post(
      apiPath['report'], {'id': fullname, 'reason': reason, 'api_type': 'json'},
      discardResponse: true);
}
