// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../api_paths.dart';
import '../reddit.dart';
import 'user_content.dart';

class Comment extends UserContent {
  static final RegExp _commentRegExp = new RegExp(r'{id}');
  String _id;
  String _name;

  Comment.parse(Reddit reddit, Map data)
      : _name = data['name'],
        super.loadDataWithPath(reddit, data, _infoPath(data['id']));

  static String _infoPath(String id) =>
      apiPath['comment'].replaceAll(_commentRegExp, id);

  String get fullname => _name;
}
