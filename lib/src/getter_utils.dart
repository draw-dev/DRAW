// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/reddit.dart';

abstract class GetterUtils {
  static DateTime dateTimeOrNull(double time) {
    if (time == null) {
      return null;
    }
    return new DateTime.fromMillisecondsSinceEpoch(time.round() * 1000,
        isUtc: true);
  }

  static RedditorRef redditorRefOrNull(Reddit reddit, String redditor) {
    if (redditor == null) {
      return null;
    }
    return reddit.redditor(redditor);
  }
}
