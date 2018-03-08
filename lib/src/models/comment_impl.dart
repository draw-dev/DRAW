// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

// Required for `hash2`
import 'package:quiver/core.dart' show hash2;

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/comment_forest.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/models/mixins/user_content_mixin.dart';
import 'package:draw/src/models/mixins/editable.dart';
import 'package:draw/src/models/mixins/gildable.dart';
import 'package:draw/src/models/mixins/inboxtoggleable.dart';
import 'package:draw/src/models/mixins/replyable.dart';
import 'package:draw/src/models/mixins/reportable.dart';
import 'package:draw/src/models/mixins/saveable.dart';
import 'package:draw/src/models/mixins/voteable.dart';

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
class MoreComments extends RedditBase with RedditBaseInitializedMixin {
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
        super(reddit) {
    setData(this, data);
  }

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
    final submissionCast = _submission as Submission;
    final path = apiPath['submission'].replaceAll(
            _submissionRegExp, submissionCast.fullname.split('_')[1]) +
        '_/' +
        commentId;
    final response = await reddit.get(path, params: {
      'limit': submissionCast.data['commentLimit'],
      'sort': submissionCast.data['commentSort'],
    });

    final comments = response[1]['listing'];
    assert(comments.length == 1);
    return comments[0];
  }

  /// Expand [MoreComments] into the list of actual [Comments] it represents.
  Future<List<Comment>> comments({bool update: true}) async {
    if (_comments == null) {
      if (_submission is! Submission) {
        _submission = await _submission.populate();
      }
      if (_count == 0) {
        return await _continueComments(update);
      }
      // TODO(bkonyi): Fix comment sorting.
      assert(_children != null);
      final data = {
        'children': _children.join(','),
        'link_id': (_submission as Submission).fullname,
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

/// A fully initialized class which represents a single Reddit comment.
class Comment extends CommentRef
    with
        EditableMixin,
        GildableMixin,
        InboxToggleableMixin,
        InboxableMixin,
        RedditBaseInitializedMixin,
        ReplyableMixin,
        ReportableMixin,
        SaveableMixin,
        UserContentMixin,
        VoteableMixin {
  // CommentModeration get mod; // TODO(bkonyi): implement

  /// Has this [Comment] been approved.
  bool get approved => data['approved'];

  /// When this [Comment] was approved.
  ///
  /// Returns `null` if this [Comment] has not been approved.
  DateTime get approvedAtUtc => (data['approved_at_utc'] == null) ?
    null :
      new DateTime.fromMillisecondsSinceEpoch(data['approved_at_utc'].round() * 1000, isUtc: true);

  /// Which Redditor approved this [Comment].
  ///
  /// Returns `null` if this [Comment] has not been approved.
  RedditorRef get approvedBy => (data['approved_by'] == null) ?
    null : reddit.redditor(data['approved_by']);

  /// Is this [Comment] archived.
  bool get archived => data['archived'];

  // TODO(bkonyi): update this definition.
  // RedditorRef get author => reddit.redditor(data['author']);

  /// The author's flair text, if set.
  ///
  /// Returns `null` if the author does not have any flair text set.
  String get authorFlairText => data['author_flair_text'];

  /// When this [Comment] was removed.
  ///
  /// Returns `null` if the [Comment] has not been removed.
  DateTime get bannedAtUtc => (data['banned_at_utc'] == null) ?
    null :
      new DateTime.fromMillisecondsSinceEpoch(data['banned_at_utc'].round() * 1000, isUtc: true);

  /// Which Redditor removed this [Comment].
  ///
  /// Returns `null` if the [Comment] has not been removed.
  RedditorRef get bannedBy => (data['banned_by'] == null) ?
    null : reddit.redditor(data['banned_by']);

  /// Is this [Comment] eligible for Reddit Gold.
  bool get canGild => data['can_gild'];

  bool get canModPost => data['can_mod_post'];

  /// Is this [Comment] and its children collapsed.
  bool get collapsed => data['collapsed'];

  /// The reason for this [Comment] being collapsed.
  ///
  /// Returns `null` if the [Comment] isn't collapsed or there is no reason set.
  String get collapsedReason => data['collapsed_reason'];

  /// The time this [Comment] was created.
  DateTime get createdUtc => new DateTime.fromMillisecondsSinceEpoch(data['created_utc'] * 1000, isUtc: true);

  /// The depth of this [Comment] in the tree of comments.
  int get depth => data['depth'];

  /// The number of downvotes this [Comment] has received.
  int get downvotes => data['downs'];

  /// Has this [Comment] been edited.
  bool get edited => data['edited'];

  /// Has this [Comment] be given Reddit Gold.
  int get gilded => data['gilded'];

  /// Ignore reports for this [Comment].
  ///
  /// This is only visible to moderators on the [Subreddit] this [Comment] was
  /// posted on.
  bool get ignoreReports => data['ignore_reports'];

  /// Did the currently authenticated [User] post this [Comment].
  bool get isSubmitter => data['is_submitter'];

  /// Does the currently authenticated [User] like this [Comment].
  bool get likes => data['likes'];

  /// The id of the [Submission] link.
  ///
  /// Takes the form of `t3_7czz1q`.
  String get linkId => data['link_id'];

  /// The number of reports made regarding this [Comment].
  ///
  /// This is only visible to moderators on the [Subreddit] this [Comment] was
  /// posted on.
  int get numReports => data['num_reports'];

  /// The ID of the parent [Comment] or [Submission].
  String get parentId => data['parent_id'];

  String get permalink => data['permalink'];

  String get removalReason => data['removal_reason'];

  /// Has this [Comment] been removed.
  bool get removed => data['removed'];

  /// Has this [Comment] been saved.
  bool get saved => data['saved'];

  /// The score associated with this [Comment] (aka net-upvotes).
  int get score => data['score'];

  /// Is this score of this [Comment] hidden.
  bool get scoreHidden => data['score_hidden'];

  /// Is this [Comment] marked as spam.
  bool get spam => data['spam'];

  /// Has this [Comment] been stickied.
  bool get stickied => data['stickied'];

  /// The [Subreddit] this [Comment] was posted in.
  SubredditRef get subreddit => reddit.subreddit(data['subreddit']);

  /// The id of the [Subreddit] this [Comment] was posted in.
  String get subredditId => data['subreddit_id'];

  /// The type of the [Subreddit] this [Comment] was posted in.
  String get subredditType => data['subreddit_type'];

  /// The number of upvotes this [Comment] has received.
  int get upvotes => data['ups'];

  /// Returns true if the current [Comment] is a top-level comment. A [Comment]
  /// is a top-level comment if its parent is a [Submission].
  bool get isRoot {
    final parentIdType = parentId.split('_')[0];
    return (parentIdType == reddit.config.submissionKind);
  }

  /// Return the parent of the comment.
  ///
  /// The returned parent will be an instance of either [Comment] or
  /// [Submission].
  Future<UserContent> parent() async {
    if (_submission is! Submission) {
      _submission = await _submission.populate();
    }
    if (parentId == (_submission as Submission).fullname) {
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

  Comment.parse(Reddit reddit, Map data) : super.withID(reddit, data['id']) {
    setData(this, data);
  }

  /// The [Submission] which this comment belongs to.
  SubmissionRef get submission {
    if (_submission == null) {
      _submission = reddit.submission(id: _extractSubmissionId());
    }
    return _submission;
  }
}

/// A lazily initialized class which represents a single Reddit comment. Can be
/// promoted to a [Comment].
class CommentRef extends UserContent {
  SubmissionRef _submission;
  CommentForest _replies;

  static final RegExp _commentRegExp = new RegExp(r'{id}');

  CommentRef.withID(Reddit reddit, String id)
      : super.withPath(reddit, _infoPath(id));

  static String _infoPath(String id) =>
      apiPath['comment'].replaceAll(_commentRegExp, id);

  /// A forest of replies to the current comment.
  CommentForest get replies => _replies;
}
