// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/models/comment.dart';

enum DistinctionType {
  yes,
  no,
  admin,
  special,
}

String _distinctionTypeToString(DistinctionType type) {
  switch (type) {
    case DistinctionType.yes:
      return 'yes';
    case DistinctionType.no:
      return 'no';
    case DistinctionType.admin:
      return 'admin';
    case DistinctionType.special:
      return 'special';
    default:
      throw new DRAWInternalError(
          'Invalid user content distinction type: $type.');
  }
}

/// Provides moderation methods for [Comment]s and [Submission]s.
abstract class UserContentModerationMixin {
  dynamic get content;

  /// Approve a [Comment] or [Submission].
  ///
  /// Approving a comment or submission reverts removal, resets the report
  /// counter, adds a green check mark which is visible to other moderators
  /// on the site, and sets the `approvedBy` property to the authenticated
  /// user.
  Future approve() async =>
      content.reddit.post(apiPath['approve'], {'id': content.fullname},
          discardResponse: true);

  /// Distinguish a [Comment] or [Submission].
  ///
  /// `how` is a [DistinctionType] value, where `yes` distinguishes the content
  /// as a moderator, and `no` removes distinction. `admin` and `special`
  /// require special privileges.
  ///
  /// If `sticky` is `true` and the comment is top-level, the [Comment] will be
  /// placed at the top of the comment thread. If the item to be distinguished
  /// is not a [Comment] or is not a top-level [Comment], this parameter is
  /// ignored.
  Future distinguish({DistinctionType how, bool sticky: false}) async {
    final data = {
      'how': _distinctionTypeToString(how),
      'id': content.fullname,
      'api_type': 'json'
    };
    if (sticky && (content is Comment) && content.isRoot) {
      data['sticky'] = 'true';
    }
    return content.reddit.post(apiPath['distinguish'], data);
  }

  /// Ignore future reports on a [Comment] or [Submission].
  ///
  /// Prevents future reports on this [Comment] or [Submission] from triggering
  /// notifications and appearing in the mod queue. The report count will
  /// continue to increment.
  Future ignoreReports() async =>
      content.reddit.post(apiPath['ignore_reports'], {'id': content.fullname},
          discardResponse: true);

  /// Remove a [Comment] or [Submission].
  ///
  /// Set `spam` to `true` to help train the subreddit's spam filter.
  Future remove({bool spam: false}) async => content.reddit.post(
      apiPath['remove'], {'id': content.fullname, 'spam': spam.toString()},
      discardResponse: true);

  /// Remove distinguishing on a [Comment] or [Submission].
  Future undistinguish() async => distinguish(how: DistinctionType.no);

  /// Resume receiving future reports for a [Comment] or [Submission].
  ///
  /// Future reports will trigger notifications and appear in the mod queue.
  Future unignoreReports() async =>
      content.reddit.post(apiPath['unignore_reports'], {'id': content.fullname},
          discardResponse: true);
}
