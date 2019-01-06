// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../listing_generator.dart';
import '../../base.dart';
import '../../models/comment.dart';
import '../../models/subreddit.dart';
import '../../reddit.dart';
import 'gilded.dart';

mixin SubredditListingMixin {
  Reddit get reddit;
  String get path;
  CommentHelper _commentHelper;
  CommentHelper get comments {
    if (_commentHelper == null) {
      _commentHelper = CommentHelper(this);
    }
    return _commentHelper;
  }
}

class CommentHelper extends RedditBase with GildedListingMixin {
  String get path => _subreddit.path;
  final SubredditRef _subreddit;
  CommentHelper(this._subreddit) : super(_subreddit.reddit);

  Stream<Comment> call({Map<String, String> params}) =>
      ListingGenerator.generator<Comment>(reddit, _path(),
          limit: ListingGenerator.getLimit(params), params: params);

  String _path() => _subreddit.path + 'comments/';
}
