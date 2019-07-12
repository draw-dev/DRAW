// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../listing_generator.dart';
import '../../reddit.dart';
import '../../models/user_content.dart';

mixin RisingListingMixin {
  Reddit get reddit;
  String get path;

  /// Returns a random [UserContent] that is "rising".
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  Stream<UserContent> randomRising(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'randomrising',
          limit: limit, after: after, params: params);

  /// Returns a [UserContent] that is "rising".
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  Stream<UserContent> rising(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'rising',
          limit: limit, after: after, params: params);
}
