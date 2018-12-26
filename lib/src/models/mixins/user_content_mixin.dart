// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/base_impl.dart';

mixin UserContentInitialized implements RedditBaseInitializedMixin {
  /// The amount of silver gilded to this [UserContent].
  int get silver => data['gildings']['gid_1'];

  /// The amount of gold gilded to this [UserContent].
  int get gold => data['gildings']['gid_2'];

  /// The amount of platinum gilded to this [UserContent].
  int get platinum => data['gildings']['gid_3'];

  /// A [List] of reports made by moderators.
  ///
  /// Each report consists of a list with two entries. The first entry is the
  /// name of the moderator who submitted the report. The second is the report
  /// reason.
  List<List<String>> get modReports {
    final reports = data['mod_reports'] as List;
    return reports.map<List<String>>((e) => e.cast<String>()).toList();
  }

  /// A [List] of reports made by users.
  ///
  /// Each report consists of a list with two entries. The first entry is the
  /// report reason. The second is the number of times this reason has been
  /// reported.
  List<List<dynamic>> get userReports =>
      (data['user_reports'] as List).cast<List<dynamic>>();

  /// True if the currently authenticated user has marked this content as saved.
  bool get saved => data['saved'];
}
