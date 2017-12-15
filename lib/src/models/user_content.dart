// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import '../base.dart';
import '../reddit.dart';
import 'mixins/editable.dart';
import 'mixins/gildable.dart';
import 'mixins/inboxtoggleable.dart';
import 'mixins/replyable.dart';
import 'mixins/reportable.dart';
import 'mixins/saveable.dart';
import 'mixins/voteable.dart';

/// An abstract base class for user created content, which is one of
/// [Submission] or [Comment].
abstract class UserContent extends RedditBase
    with
        EditableMixin,
        GildableMixin,
        InboxToggleableMixin,
        ReplyableMixin,
        ReportableMixin,
        SaveableMixin,
        VoteableMixin {
  UserContent.loadData(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']);

  UserContent.loadDataWithPath(Reddit reddit, Map data, String path)
      : super.loadDataWithPath(reddit, data, path);

  UserContent.withPath(Reddit reddit, String infoPath)
      : super.withPath(reddit, infoPath);
}
