// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/reddit.dart';

abstract class GetterUtils {
  static DateTime? dateTimeOrNull(double? time) {
    if (time == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(time.round() * 1000,
        isUtc: true);
  }

  static DateTime? dateTimeOrNullFromString(String? time) {
    if (time == null) {
      return null;
    }
    return DateTime.parse(time);
  }

  static RedditorRef? redditorRefOrNull(Reddit reddit, String? redditor) =>
      (redditor == null) ? null : reddit.redditor(redditor);

  static SubredditRef? subredditRefOrNull(Reddit reddit, String? subreddit) =>
      (subreddit == null) ? null : reddit.subreddit(subreddit);

  static Uri? uriOrNull(String? uri) => (uri == null) ? null : Uri.parse(uri);
}
