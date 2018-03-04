// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

// Required for `hash2`
import 'package:quiver/core.dart';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/comment_forest.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/models/mixins/user_content_mixin.dart';

void setSubmissionInternal(commentLike, SubmissionRef s) {
  commentLike._submission = s;

  // A MoreComment should never be a parent of any other comments, so don't add
  // it into the Submission lookup table of id->Comment.
  if (commentLike is Comment) {
    insertCommentById(s, commentLike);
  }
  if ((commentLike is Comment) && (commentLike._replies != null)) {
    for (var i = 0; i < commentLike._replies.length; ++i) {
      final comment = commentLike._replies[i];
      setSubmissionInternal(comment, s);
    }
  }
}

void setRepliesInternal(commentLike, CommentForest comments) {
  commentLike._replies = comments;
}

/// Represents comments which have been collapsed under a 'load more comments'
/// or 'continue this thread' section.
class MoreComments extends RedditBase {
  static final RegExp _submissionRegExp = new RegExp(r'{id}');
  List<Comment> _comments;
  List<String> _children;
  int _count;
  String _parentId;
  SubmissionRef _submission;

  List get children => _children;

  int get count => _count;

  int get hashCode => hash2(_count.hashCode, _children.hashCode);

  /// The ID of the parent [Comment] or [Submission].
  String get parentId => _parentId;

  MoreComments.parse(Reddit reddit, Map data)
      : _children = data['children'],
        _count = data['count'],
        _parentId = data['parent_id'],
        super.loadData(reddit, data);

  bool operator ==(other) {
    return ((other is MoreComments) &&
        (count == other.count) &&
        (children == other.children));
  }

  bool operator <(other) => (count > other.count);

  String toString() {
    final buffer = new StringBuffer();
    buffer.write('<MoreComments count=${_children.length}, children=');
    if (_children.length > 4) {
      final _tmp = _children.sublist(0, 4);
      _tmp.add('...');
      buffer.write(_tmp);
    } else {
      buffer.write(_children);
    }
    buffer.write('>');
    return buffer.toString();
  }

  Future<List<Comment>> _continueComments(bool update) async {
    assert(_children.isEmpty);
    final parent = await _loadComment(_parentId.split('_')[1]);
    _comments = parent.replies.comments;
    if (update) {
      for (final comment in _comments) {
        if (comment is! MoreComments) {
          setSubmissionInternal(comment, _submission);
        }
      }
    }
    return _comments;
  }

  Future<Comment> _loadComment(String commentId) async {
    if (_submission is! Submission) {
      _submission = await _submission.populate();
    }
    final path = apiPath['submission'].replaceAll(
            _submissionRegExp, fullnameSync(_submission).split('_')[1]) +
        '_/' +
        commentId;
    final response = await reddit.get(path, params: {
      'limit': _submission.data['commentLimit'],
      'sort': _submission.data['commentSort'],
    });

    final comments = response[1]['listing'];
    assert(comments.length == 1);
    return comments[0];
  }

  /// Expand [MoreComments] into the list of actual [Comments] it represents.
  Future<List<Comment>> comments({bool update: true}) async {
    if (_comments == null) {
      if (_count == 0) {
        return await _continueComments(update);
      }
      // TODO(bkonyi): Fix comment sorting.
      assert(_children != null);
      final data = {
        'children': _children.join(','),
        'link_id': fullnameSync(_submission),
        'sort': 'best', //(await _submission.property('commentSort')),
        'api_type': 'json',
      };
      _comments = await reddit.post(apiPath['morechildren'], data);

      if (update) {
        for (final comment in _comments) {
          comment._submission = _submission;
        }
      }
    }
    return _comments;
  }
}

class Comment extends CommentRef with UserContentMixin {
  // CommentModeration get mod; // TODO(bkonyi): implement

  /// Returns true if the current [Comment] is a top-level comment. A [Comment]
  /// is a top-level comment if its parent is a [Submission].
  bool get isRoot {
    final parentIdType = parentId.split('_')[0];
    return (parentIdType == reddit.config.submissionKind);
  }

  /// The ID of the parent [Comment] or [Submission].
  String get parentId => data['parent_id'];

  /// Return the parent of the comment.
  ///
  /// The returned parent will be an instance of either [Comment] or
  /// [Submission].
  Future<UserContent> parent() async {
    if (_submission is! Submission) {
      _submission = await _submission.populate();
    }
    if (parentId == _submission.fullname) {
      return submission;
    }

    // Check if the comment already exists.
    var parent = getCommentByIdInternal(_submission, parentId);
    if (parent == null) {
      parent = new CommentRef.withID(reddit, parentId.split('_')[1]);
      parent._submission = _submission;
    }
    return parent;
  }

  String _extractSubmissionId() {
    var id = data['context'];
    if (id != null) {
      final split = id.split('/');
      print(split);
      throw new DRAWUnimplementedError();
      return split[split.length - 4];
    }
    id = data['link_id'];
    if (id != null) {
      return id.split('_')[1];
    }
    throw new DRAWInternalError('Cannot extract submission ID from a'
        ' lazy-comment');
  }

  Comment.parse(Reddit reddit, Map data) : super.loadData(reddit, data);

  /// The [Submission] which this comment belongs to.
  SubmissionRef get submission {
    if (_submission == null) {
      _submission = reddit.submission(id: _extractSubmissionId());
    }
    return _submission;
  }
}

/// A class which represents a single Reddit comment.
class CommentRef extends UserContent with InboxableMixin {
  SubmissionRef _submission;
  CommentForest _replies;

  static final RegExp _commentRegExp = new RegExp(r'{id}');

  CommentRef.loadData(Reddit reddit, Map data)
      : super.loadDataWithPath(reddit, data, _infoPath(data['id']));

  CommentRef.withID(Reddit reddit, String id)
      : super.withPath(reddit, _infoPath(id));

  static String _infoPath(String id) =>
      apiPath['comment'].replaceAll(_commentRegExp, id);

  /// A forest of replies to the current comment.
  CommentForest get replies => _replies;
}
