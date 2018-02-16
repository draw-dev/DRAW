// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';
import '../comment.dart';

/// A mixin for RedditBase classes that can be replied to.
abstract class ReplyableMixin {
  Reddit get reddit;
  Future<String> get fullname;

  // TODO(bkonyi): check if we actually need to access an array element.
  /// Reply to the object.
  ///
  /// [body] is the markdown formatted content for a comment. Returns a
  /// [Comment] for the newly created comment.
  Future<Comment> reply(String body) async => (await reddit.post(
      apiPath['comment'],
      {'text': body, 'thing_id': await fullname, 'api_type': 'json'}))[0];
}
