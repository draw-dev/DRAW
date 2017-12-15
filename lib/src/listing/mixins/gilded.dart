// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../reddit.dart';
import '../../models/user_content.dart';
import '../listing_generator.dart';

/// A mixin which contains the functionality required to get a [Stream] of
/// gilded content.
abstract class GildedListingMixin {
  Reddit get reddit;
  String get path;

  /// Returns a [Stream] of content that has been gilded.
  Stream<UserContent> gilded({Map params}) =>
      ListingGenerator.createBasicGenerator<UserContent>(
          reddit, path + 'gilded',
          params: params);
}
