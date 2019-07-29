// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/models/comment_forest.dart';
import 'package:draw/src/models/mixins/editable.dart';
import 'package:draw/src/models/mixins/gildable.dart';
import 'package:draw/src/models/mixins/inboxable.dart';
import 'package:draw/src/models/mixins/inboxtoggleable.dart';
import 'package:draw/src/models/mixins/replyable.dart';
import 'package:draw/src/models/mixins/reportable.dart';
import 'package:draw/src/models/mixins/saveable.dart';
import 'package:draw/src/models/mixins/user_content_mixin.dart';
import 'package:draw/src/models/mixins/user_content_moderation.dart';
import 'package:draw/src/models/mixins/voteable.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/reddit.dart';
import 'package:quiver/core.dart' show hash2;
// Required for `hash2`

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
  static final RegExp _submissionRegExp = RegExp(r'{id}');
  List _comments;
  final List<String> _children;
  final int _count;
  final String _parentId;
  SubmissionRef _submission;

  List get children => _children;

  /// The number of comments this instance of [MoreComments] expands into.
  ///
  /// If `count` is 0, this instance represents a `continue this thread` link.
  int get count => _count;

  int get hashCode => hash2(_count.hashCode, _children.hashCode);

  /// True if this instance of [MoreComments] is the equivalent of the
  /// 'continue this thread' link in www.reddit.com comments.
  ///
  /// When this is true, `count` will be equal to 0.
  bool get isContinueThisThread => (_count == 0);

  /// True if this instance of [MoreComments] is the equivalent of the
  /// 'load more comments' link in www.reddit.com comments.
  ///
  /// When this is true, `count` should be non-zero.
  bool get isLoadMoreComments => !isContinueThisThread;

  /// The ID of the parent [Comment] or [Submission].
  String get parentId => _parentId;

  SubmissionRef get submission => _submission;

  MoreComments.parse(Reddit reddit, Map data)
      : _children = data['children'].cast<String>(),
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
    final buffer = StringBuffer();
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

  Future<List<dynamic>> _continueComments(bool update) async {
    assert(_children.isEmpty);
    final parent = await _loadComment(_parentId.split('_')[1]);
    _comments = parent.replies?.comments;
    if (update && (_comments != null)) {
      _comments.forEach((c) => setSubmissionInternal(c, submission));
    }
    return _comments;
  }

  Future<Comment> _loadComment(String commentId) async {
    if (_submission is! Submission) {
      _submission = await _submission.populate();
    }
    final Submission initializedSubmission = _submission;
    final path = apiPath['submission'].replaceAll(
            _submissionRegExp, initializedSubmission.fullname.split('_')[1]) +
        '_/' +
        commentId;
    final response = await reddit.get(path, params: {
      'limit': initializedSubmission.data['commentLimit'],
      'sort': initializedSubmission.data['commentSort'],
    });

    final comments = response[1]['listing'];
    assert(comments.length == 1);
    return comments[0];
  }

  /// Expand [MoreComments] into the list of actual [Comments] it represents.
  ///
  /// Can contain additional [MoreComments] objects.
  Future<List<dynamic>> comments({bool update = true}) async {
    if (_comments == null) {
      assert(_submission is Submission);
      final Submission initializedSubmission = _submission;
      if (_count == 0) {
        return await _continueComments(update);
      }
      assert(_children != null);
      final data = {
        'children': _children.join(','),
        'link_id': initializedSubmission.fullname,
        'sort': commentSortTypeToString(initializedSubmission.commentSort),
        'api_type': 'json',
      };
      _comments = await reddit.post(apiPath['morechildren'], data);

      if (update) {
        _comments.forEach((c) {
          c._submission = _submission;
        });
      }
    }
    return _fillCommentsForests(_comments);
  }

  List<dynamic> _fillCommentsForests(List<dynamic> fullList) {
    if (fullList.length > 1) {
      final first = fullList.first;
      currentIndex = 0;
      return _fillCommentsForestsRecursively(fullList, first.depth);
    } else {
      /*
        For the cases
        - fullList = [MoreComments]
        - fullList = [Comment]
       */
      return fullList;
    }
  }

  int currentIndex;
  List<dynamic> _fillCommentsForestsRecursively(
      List<dynamic> fullList, int currentDepth) {
    final List<dynamic> commentsAtCurrentLevel = [fullList[currentIndex]];
    currentIndex++;
    while (currentIndex < fullList.length) {
      final currentComment = fullList[currentIndex];

      if (currentComment is Comment) {
        if (currentComment.depth == currentDepth) {
          commentsAtCurrentLevel.add(currentComment);
          currentIndex++;
        } else if (currentComment.depth < currentDepth) {
          // Should be handled by previous layer, dont increment currentIndex
          break;
        } else {
          // A new layer of children, lets add them to their parent,
          // which is the last Comment added to the commentsAtCurrentLevelList
          final parent = commentsAtCurrentLevel.last;
          // Should be handled by next layer, dont increment currentIndex
          final replies =
              _fillCommentsForestsRecursively(fullList, currentDepth + 1);
          parent._replies = CommentForest(submission, replies);
        }
      } else {
        // More Comments don't have a level, but assume it is on the same level and break
        commentsAtCurrentLevel.add(currentComment);
        currentIndex++;
        break;
      }
    }

    return commentsAtCurrentLevel;
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
        UserContentInitialized,
        VoteableMixin {
  // CommentModeration get mod; // TODO(bkonyi): implement

  /// Has this [Comment] been approved.
  bool get approved => data['approved'];

  /// When this [Comment] was approved.
  ///
  /// Returns `null` if this [Comment] has not been approved.
  DateTime get approvedAtUtc =>
      GetterUtils.dateTimeOrNull(data['approved_at_utc']);

  /// Which Redditor approved this [Comment].
  ///
  /// Returns `null` if this [Comment] has not been approved.
  RedditorRef get approvedBy =>
      GetterUtils.redditorRefOrNull(reddit, data['approved_by']);

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
  DateTime get bannedAtUtc => GetterUtils.dateTimeOrNull(data['banned_at_utc']);

  /// Which Redditor removed this [Comment].
  ///
  /// Returns `null` if the [Comment] has not been removed.
  RedditorRef get bannedBy =>
      GetterUtils.redditorRefOrNull(reddit, data['banned_by']);

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
  DateTime get createdUtc => GetterUtils.dateTimeOrNull(data['created_utc']);

  /// The depth of this [Comment] in the tree of comments.
  int get depth => data['depth'];

  /// The number of downvotes this [Comment] has received.
  int get downvotes => data['downs'];

  /// Has this [Comment] been edited.
  // `edited` is `false` iff the comment hasn't been edited.
  // `else edited` is a timestamp.
  bool get edited => (data['edited'] is double);

  /// Ignore reports for this [Comment].
  ///
  /// This is only visible to moderators on the [Subreddit] this [Comment] was
  /// posted on.
  bool get ignoreReports => data['ignore_reports'];

  /// Did the currently authenticated [User] post this [Comment].
  bool get isSubmitter => data['is_submitter'];

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
    final Submission initializedSubmission = _submission;
    if (parentId == initializedSubmission.fullname) {
      return submission;
    }

    // Check if the comment already exists.
    CommentRef parent = getCommentByIdInternal(_submission, parentId);
    if (parent == null) {
      parent = CommentRef.withID(reddit, parentId.split('_')[1]);
      parent._submission = _submission;
    }
    return parent;
  }

  String _extractSubmissionId() {
    var id = data['context'];
    if (id != null) {
      final split = id.split('/');
      print(split);
      throw DRAWUnimplementedError();
    }
    id = data['link_id'];
    if (id != null) {
      return id.split('_')[1];
    }
    throw DRAWInternalError('Cannot extract submission ID from a'
        ' lazy-comment');
  }

  Comment.parse(Reddit reddit, Map data) : super.withID(reddit, data['id']) {
    setData(this, data);
  }

  @override
  Future<void> refresh() async {
    if ((_submission == null) || (_submission is SubmissionRef)) {
      _submission = await submission.populate();
    }
    final path = submission.infoPath + '_/' + _id;
    final params = {
      'context': '100',
    };
    // TODO(bkonyi): clean-up this so it's objectified in a nicer way?
    final commentList = (await reddit.get(path, params: params))[1]['listing'];
    final queue = Queue.from(commentList);
    var comment;
    while (queue.isNotEmpty && ((comment == null) || (comment._id != _id))) {
      comment = queue.removeFirst();
      if ((comment is CommentRef) && (comment.replies != null)) {
        queue.addAll(comment.replies.toList());
      }
    }
    if ((comment == null) || comment._id != _id) {
      throw DRAWClientError('Could not find comment with id $_id');
    }

    // Update the backing state of this comment object.
    setData(this, comment.data);

    _replies = comment.replies;

    // Ensure all the sub-comments are pointing to the same submission as this.
    setSubmissionInternal(this, submission);
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
  CommentForest _replies;
  SubmissionRef __submission;
  final String _id;

  SubmissionRef get _submission => __submission;

  set _submission(SubmissionRef s) {
    __submission = s;
    if (_replies != null) {
      setSubmission(_replies, s);
    }
  }

  static final RegExp _commentRegExp = RegExp(r'{id}');

  CommentRef.withID(Reddit reddit, this._id)
      : super.withPath(reddit, _infoPath(_id));

  CommentRef.withPath(Reddit reddit, url)
      : _id = idFromUrl(url),
        super.withPath(reddit, _infoPath(idFromUrl(url)));

  static String _infoPath(String id) =>
      apiPath['comment'].replaceAll(_commentRegExp, id);

  // TODO(bkonyi): allow for paths without trailing '/'.
  /// Retrieve a comment ID from a given URL.
  ///
  /// Note: when [url] is a [String], it must end with a trailing '/'. This is a
  /// bug and will be fixed eventually.
  static String idFromUrl(/*String, Uri*/ url) {
    Uri uri;
    if (url is String) {
      uri = Uri.parse(url);
    } else if (url is Uri) {
      uri = url;
    } else {
      throw DRAWArgumentError('idFromUrl expects either a String or Uri as'
          ' input');
    }
    final parts = uri.path.split('/');
    final commentsIndex = parts.indexOf('comments');
    // Check formatting of the URL.
    if (commentsIndex != parts.length - 5) {
      throw DRAWArgumentError("'$url' is not a valid comment url.");
    }
    return parts[parts.length - 2];
  }

  /// Promotes this [CommentRef] into a populated [Comment].
  Future<Comment> populate() async {
    final params = {
      'id': reddit.config.commentKind + '_' + _id,
    };
    // Gets some general info about the comment.
    final result = await reddit.get(apiPath['info'], params: params);
    final List listing = result['listing'];
    if (listing.isEmpty) {
      throw DRAWInvalidCommentException(_id);
    }
    final comment = listing[0];

    // The returned comment isn't fully populated, so refresh it here to
    // grab replies, etc.
    await comment.refresh();
    return comment;
  }

  /// A forest of replies to the current comment.
  CommentForest get replies => _replies;
}

/// Provides a set of moderation functions for a [Comment].
class CommentModeration extends Object with UserContentModerationMixin {
  Comment get content => _content;
  final Comment _content;

  CommentModeration._(this._content);
}
