// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/draw.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/listing/mixins/gilded.dart';
import 'package:draw/src/listing/mixins/rising.dart';
import 'package:draw/src/reddit.dart';

/// The [FrontPage] class provides methods to access listings of content on the
/// Reddit front page.
class FrontPage extends RedditBase
    with BaseListingMixin, GildedListingMixin, RisingListingMixin {
  String path = '/';
  FrontPage(Reddit reddit) : super(reddit);

  /// Returns a [UserContent] that is "best".
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  Stream<UserContent> best(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'best',
          limit: limit, after: after, params: params);
}
