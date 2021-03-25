// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';

/// Interface for classes that can be gilded.
mixin GildableMixin implements RedditBaseInitializedMixin {
  /// Gild the author of the item.
  Future<void> gild() async => reddit.post(
      apiPath['gild_thing'].replaceAll(RegExp(r'{fullname}'), fullname), null);
}
