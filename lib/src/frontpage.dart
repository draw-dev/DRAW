// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/base.dart';
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
}
