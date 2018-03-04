// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/base.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/mixins/editable.dart';
import 'package:draw/src/models/mixins/gildable.dart';
import 'package:draw/src/models/mixins/inboxtoggleable.dart';
import 'package:draw/src/models/mixins/replyable.dart';
import 'package:draw/src/models/mixins/reportable.dart';
import 'package:draw/src/models/mixins/saveable.dart';
import 'package:draw/src/models/mixins/voteable.dart';

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
