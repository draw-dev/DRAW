// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';

import 'comment_impl.dart';
import 'submission_impl.dart';

/// A user-friendly representation of a forest of [Comment] objects.
class CommentForest {
  final List _comments;
  final Submission _submission;

  /// The number of top-level comments associated with the current
  /// [CommentForest].
  int get length => (_comments?.length) ?? 0;

  /// A list of top-level comments associated with the current [CommentForest].
  List get comments => _comments;

  CommentForest(Submission submission, [List<Comment> comments])
      : _comments = new List(),
        _submission = submission {
    _update(comments);
  }

  dynamic operator [](int i) => _comments[i];

  /// Returns a list of all [Comment]s in the [CommentForest].
  ///
  /// The resulting [List] of [Comment] objects is built in a breadth-first
  /// manner. For example, the [CommentForest]:
  ///
  /// 1
  /// + 2
  /// + + 3
  /// + 4
  /// 5
  ///
  /// Will return the comments in the following order: [1, 5, 2, 4, 3].
  List toList() {
    final comments = [];
    final queue = new Queue.from(_comments);
    while (queue.isNotEmpty) {
      final comment = queue.removeFirst();
      comments.add(comment);
      if ((comment is! MoreComments) && (comment.replies != null)) {
        queue.addAll(comment.replies._comments);
      }
    }
    return comments;
  }

  Future _insertComment(comment) async {
    if ((comment is MoreComments) || (await comment.isRoot)) {
      _comments.add(comment);
    } else {
      final parent = getCommentByIdInternal(
          _submission, (await comment.property('parentId')));
      parent.replies._comments.add(comment);
    }
  }

  void _update(List comments) {
    _comments.clear();
    _comments.addAll(comments);
    for (final comment in _comments) {
      setSubmissionInternal(comment, _submission);
    }
  }

  /// Iterate through the [CommentForest], expanding instances of [MoreComments].
  ///
  /// [limit] represents the maximum number of [MoreComments] to expand
  /// (default: 32), and [threshold] is the minimum number of comments that a
  /// [MoreComments] object needs to represent in order to be expanded (default:
  /// 0).
  Future replaceMore({limit: 32, threshold: 0}) async {
    var remaining = limit;
    final moreComments = _getMoreComments(_comments);
    final skipped = [];

    while (moreComments.isNotEmpty) {
      final item = moreComments.removeFirst();
      final commentItem = item[0];
      if (((remaining != null) && (remaining <= 0)) ||
          (commentItem.count < threshold)) {
        skipped.add(commentItem);
        item[1].remove(commentItem);
        continue;
      }

      final newComments = commentItem.comments(update: false);
      if (remaining != null) {
        --remaining;
      }

      for (final more in _getMoreComments(newComments, _comments).toList()) {
        setSubmissionInternal(more, _submission);
        moreComments.add(more);
      }

      for (final comment in newComments) {
        await _insertComment(comment);
      }

      // Remove entry from forest.
      item[1].remove(commentItem);
    }
    return skipped;
  }

  static HeapPriorityQueue<List> _getMoreComments(List<Comment> tree,
      [List<Comment> parentTree]) {
    final int Function(List, List) comparator = (List a, List b) {
      return a[0].count.compareTo(b[0].count);
    };
    final moreComments = new HeapPriorityQueue<List>(comparator);
    final queue = new Queue<List>();
    for (final x in tree) {
      queue.add([null, x]);
    }

    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      final parent = entry[0];
      final comment = entry[1];
      if (comment is MoreComments) {
        if (parent != null) {
          moreComments.add([comment, parent.replies._comments]);
        } else {
          moreComments.add([comment, parentTree ?? tree]);
        }
      } else {
        for (final item in comment.replies) {
          queue.add([comment, item]);
        }
      }
    }
    return moreComments;
  }
}
