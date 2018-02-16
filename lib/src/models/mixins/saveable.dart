// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';

/// Mixin for ReddieBase classes that can be saved.
abstract class SaveableMixin {
  Reddit get reddit;
  Future<String> get fullname;

  /// Save the object.
  ///
  /// [category] (Gold only) is the category to save the object to. If your user does not
  /// have gold, this value is ignored.
  Future save({String category}) async => reddit.post(
      apiPath['save'], {'category': category ?? '', 'id': await fullname},
      discardResponse: true);

  /// Unsave the object.
  Future unsave() async => reddit
      .post(apiPath['unsave'], {'id': await fullname}, discardResponse: true);
}
