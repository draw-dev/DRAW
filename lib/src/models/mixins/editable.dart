// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../base_impl.dart';
import '../../reddit.dart';
import '../user_content.dart';

/// Interface for classes that can be edited and deleted.
abstract class EditableMixin implements RedditBase {
  Reddit get reddit;
  String get fullname;

  /// Delete the object.
  Future delete() async =>
      reddit.post(apiPath['del'], {'id': fullname}, discardResponse: true);

  /// Replace the body of the object with [body].
  ///
  /// [body] is the markdown formatted content for the updated object. Returns
  /// the current instance of the object after updating its fields.
  Future<UserContent> edit(String body) async {
    final data = {'text': body, 'thing_id': fullname, 'api_type': 'json'};
    // TODO(bkonyi): figure out what needs to be done here.
    final updated = await reddit.post(apiPath['edit'], data);
    setData(this, updated[0].data);
    return this as UserContent;
  }
}
