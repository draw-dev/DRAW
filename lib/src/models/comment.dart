// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../reddit.dart';
import 'user_content.dart';

class Comment extends UserContent {
  Comment.parse(Reddit reddit, Map data) : super.loadData(reddit, data);
}
