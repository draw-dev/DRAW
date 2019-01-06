// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/reddit.dart';

/// Mixin for ReddieBase classes that can be saved.
mixin SaveableMixin {
  Reddit get reddit;
  String get fullname;

  /// Save the object.
  ///
  /// [category] (Gold only) is the category to save the object to. If your user does not
  /// have gold, this value is ignored.
  Future<void> save({String category}) async =>
      reddit.post(apiPath['save'], {'category': category ?? '', 'id': fullname},
          discardResponse: true);

  /// Unsave the object.
  Future<void> unsave() async =>
      reddit.post(apiPath['unsave'], {'id': fullname}, discardResponse: true);
}
