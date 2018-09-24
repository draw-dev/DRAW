// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';

import 'comment_impl.dart';
import 'submission_impl.dart';

void setSubmission(CommentForest f, SubmissionRef s) {
  assert(f != null);
  f._submission = s;
}

/// A user-friendly representation of a forest of [Comment] objects.
class CommentForest {
  final List _comments;
  SubmissionRef _submission;

  /// The number of top-level comments associated with the current
  /// [CommentForest].
  int get length => (_comments?.length) ?? 0;

  /// A list of top-level comments associated with the current [CommentForest].
  List get comments => _comments;

  CommentForest(SubmissionRef submission, [List comments])
      : _comments = new List(),
        _submission = submission {
    if (comments != null) {
      _comments.addAll(comments);
      _comments.forEach((c) => setSubmissionInternal(c, _submission));
    }
  }

  void _insertComment(comment) {
    assert((comment is MoreComments) ||
        ((comment is Comment) &&
            (getCommentByIdInternal(_submission, comment.fullname) == null)));
    setSubmissionInternal(comment, _submission);
    assert((comment is MoreComments) ||
        (getCommentByIdInternal(_submission, comment.fullname) != null));

    if ((comment is MoreComments) || comment.isRoot) {
      _comments.add(comment);
    } else {
      final parent = getCommentByIdInternal(_submission, comment.parentId);
      assert(parent != null);
      parent.replies._comments.add(comment);
    }
  }

  void _removeMore(MoreComments more) {
    final parent = getCommentByIdInternal(_submission, more.parentId);
    assert(parent != null);
    parent.replies._comments.remove(more);
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

  /// Iterate through the [CommentForest], expanding instances of [MoreComments].
  ///
  /// [limit] represents the maximum number of [MoreComments] to expand
  /// (default: 32), and [threshold] is the minimum number of comments that a
  /// [MoreComments] object needs to represent in order to be expanded (default:
  /// 0).
  Future<void> replaceMore({limit: 32, threshold: 0}) async {
    var remaining = limit;
    final moreComments = _getMoreComments(_comments);
    final skipped = [];

    while (moreComments.isNotEmpty) {
      final moreComment = moreComments.removeFirst();

      // If we have already expanded `limit` instances of MoreComments or this
      // instance's comment count is below the threshold, add the comments to
      // the skipped list.
      if (((remaining != null) && remaining <= 0) ||
          (moreComment.count < threshold)) {
        skipped.add(moreComment);
        _removeMore(moreComment);
        continue;
      }

      final newComments = await moreComment.comments(update: false);
      if (remaining != null) {
        --remaining;
      }

      // Add any additional MoreComments objects to the heap.
      for (final more in _getMoreComments(newComments, _comments)?.toList()) {
        setSubmissionInternal(more, _submission);
        moreComments.add(more);
      }

      newComments.forEach(_insertComment);
      _removeMore(moreComment);
    }
  }

  static final _kNoParent = null;
  // static final _kParentIndex = 0;
  static final _kCommentIndex = 1;

  static HeapPriorityQueue<MoreComments> _getMoreComments(List currentRoot,
      [List rootParent]) {
    final int Function(MoreComments, MoreComments) comparator = (a, b) {
      return a.count.compareTo(b.count);
    };
    final moreComments = new HeapPriorityQueue<MoreComments>(comparator);
    final queue = new Queue<List>();

    for (final rootComment in currentRoot) {
      queue.add([_kNoParent, rootComment]);
    }
    // Keep track of which comments we've seen already.
    final seen = Set();

    while (queue.isNotEmpty) {
      final pair = queue.removeFirst();
      // final parent = pair[_kParentIndex];
      final comment = pair[_kCommentIndex];

      if (comment is MoreComments) {
        moreComments.add(comment);
      } else if (comment.replies != null) {
        for (final item in comment.replies.toList()) {
          if (!seen.contains(comment)) {
            queue.add([comment, item]);
            seen.add(comment);
          }
        }
      }
    }
    return moreComments;
  }
}
