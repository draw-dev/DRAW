// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../reddit.dart';
import 'user_content.dart';

class Submission extends UserContent {
  final String _id;
  final String _name;
  Submission.parse(Reddit reddit, Map data)
      : _id = data['id'],
        _name = data['name'],
        super.loadData(reddit, data);

  Submission.withPath(Reddit reddit, String path)
      : super.withPath(reddit, path);
}
