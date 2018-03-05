// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/base_impl.dart';

abstract class UserContentMixin implements RedditBaseInitializedMixin {
  /// A [List] of reports made by moderators.
  ///
  /// Each report consists of a list with two entries. The first entry is the
  /// name of the moderator who submitted the report. The second is the report
  /// reason.
  List<List<String>> get modReports => data['mod_reports'];

  /// True if the currently authenticated user has marked this content as saved.
  bool get saved => data['saved'];
}
