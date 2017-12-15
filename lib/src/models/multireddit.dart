// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../base.dart';
import '../reddit.dart';

/// A class which represents a Multireddit, which is a collection of
/// [Subreddit]s. This is not yet implemented.
class Multireddit extends RedditBase {
  Multireddit.parse(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']);
}
