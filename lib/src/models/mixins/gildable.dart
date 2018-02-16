// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../api_paths.dart';
import '../../reddit.dart';

/// Interface for classes that can be gilded.
abstract class GildableMixin {
  Reddit get reddit;
  Future<String> get fullname;

  /// Gild the author of the item.
  Future gild() async => reddit.post(
      apiPath['gild_thing']
          .replaceAll(new RegExp(r'{fullname}'), await fullname),
      null);
}
