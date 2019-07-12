// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/mixins/user_content_mixin.dart';
import 'package:draw/src/reddit.dart';

/// A mixin which contains the functionality required to get a [Stream] of
/// gilded content.
mixin GildedListingMixin {
  Reddit get reddit;
  String get path;

  /// Returns a [Stream] of content that has been gilded.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  Stream<UserContentInitialized> gilded(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator<UserContentInitialized>(
          reddit, path + 'gilded',
          limit: limit, after: after, params: params);
}
