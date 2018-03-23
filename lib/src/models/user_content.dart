// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/base.dart';
import 'package:draw/src/reddit.dart';

/// An abstract base class for user created content, which is one of
/// [Submission] or [Comment].
abstract class UserContent extends RedditBase {
  UserContent.withPath(Reddit reddit, String infoPath)
      : super.withPath(reddit, infoPath);
}
