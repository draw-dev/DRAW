// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../listing_generator.dart';
import '../../reddit.dart';
import '../../models/user_content.dart';

abstract class RisingListingMixin {
  Reddit get reddit;
  String get path;

  /// Returns a random [UserContent] that is "rising".
  Stream<UserContent> randomRising({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'randomrising', params: params);

  /// Returns a [UserContent] that is "rising".
  Stream<UserContent> rising({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'rising', params: params);
}
