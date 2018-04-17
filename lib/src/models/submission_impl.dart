// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/models/comment_forest.dart';
import 'package:draw/src/models/comment_impl.dart';
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
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/reddit.dart';

CommentRef getCommentByIdInternal(SubmissionRef s, String id) {
  if (s._commentsById.containsKey(id)) {
    return s._commentsById[id];
  }
  return null;
}

void insertCommentById(SubmissionRef s, /*Comment, MoreComments*/ c) {
  assert(!s._commentsById.containsKey(c.fullname));
  s._commentsById[c.fullname] = c;
}

/// A fully initialized representation of a standard Reddit submission.
class Submission extends SubmissionRef
    with
        UserContentMixin,
        RedditBaseInitializedMixin,
        UserContentMixin,
        EditableMixin,
        GildableMixin,
        InboxableMixin,
        InboxToggleableMixin,
        ReplyableMixin,
        ReportableMixin,
        SaveableMixin,
        VoteableMixin {
  /// The date and time that this [Submission] was approved.
  ///
  /// Returns `null` if the [Submission] has not been approved.
  DateTime get approvedAt => (data['approved_at_utc'] == null)
      ? null
      : new DateTime.fromMillisecondsSinceEpoch(
          data['approved_at_utc'].round() * 1000);

  /// Has this [Submission] been approved.
  bool get approved => data['approved'];

  /// A [RedditorRef] of the [Redditor] who approved this [Submission]
  ///
  /// Returns `null` if the [Submission] has not been approved.
  RedditorRef get approvedBy =>
      GetterUtils.redditorRefOrNull(reddit, data['approved_by']);

  /// Is this [Submission] archived.
  bool get archived => data['archived'];

  /// The author's flair text, if set.
  ///
  /// If the author does not have flair text set, this property is `null`.
  String get authorFlairText => data['author_flair_text'];

  /// The date and time that this [Submission] was banned.
  ///
  /// Returns `null` if the [Submission] has not been approved.
  DateTime get bannedAt => GetterUtils.dateTimeOrNull(data['banned_at_utc']);

  /// A [RedditorRef] of the [Redditor] who banned this [Submission].
  ///
  /// Returns `null` if the [Submission] has not been banned.
  RedditorRef get bannedBy =>
      GetterUtils.redditorRefOrNull(reddit, data['banned_by']);

  /// Is this [Submission] considered 'brand-safe' by Reddit.
  bool get brandSafe => data['brand_safe'];

  /// Can this [Submission] be awarded Reddit Gold.
  bool get canGild => data['can_gild'];

  /// Can this [Submission] be moderated by the currently authenticated [Redditor].
  bool get canModeratePost => data['can_mod_post'];

  /// Has this [Submission] been clicked.
  bool get clicked => data['clicked'];

  /// Returns the [CommentForest] representing the comments for this
  /// [Submission]. May be null (see [refreshComments]).
  CommentForest get comments => _comments;

  /// Repopulates the [CommentForest] with the most up-to-date comments.
  ///
  /// Note: some methods of generating [Submission] objects do not populate the
  /// `comments` property, resulting in it being set to `null`. This method can
  /// also be used to populate `comments`.
  Future<CommentForest> refreshComments() async {
    final response = await fetch();
    _comments = new CommentForest(this, response[1]['listing']);
    return _comments;
  }

  /// Is this [Submission] in contest mode.
  bool get contestMode => data['contest_mode'];

  /// The time this [Submission] was created.
  DateTime get createdUtc => GetterUtils.dateTimeOrNull(data['created_utc']);

  /// Is this [Submission] distinguished.
  ///
  /// For example, if a moderator creates a post and chooses to show that it was
  /// created by a moderator, this property will be set to 'moderator'. If this
  /// [Submission] is not distinguished, this property is `null`.
  String get distinguished => data['distinguished'];

  /// Returns the domain of this [Submission].
  ///
  /// For self-text [Submission]s, domains take the form of 'self.announcements'.
  /// For link [Submission]s, domains take the form of 'github.com'.
  String get domain => data['domain'];

  /// The number of downvotes for this [Submission].
  int get downvotes => data['downs'];

  /// Has this [Submission] been edited.
  bool get edited => (data['edited'] is double);

  // TODO(bkonyi): implement
  // SubmissionFlair get flair;

  /// The number of times this [Submission] was awarded Reddit Gold.
  int get gilded => data['gilded'];

  /// Is this [Submission] marked as hidden.
  bool get hidden => data['hidden'];

  /// Is the score of this [Submission] hidden.
  bool get hideScore => data['hide_score'];

  /// Ignore reports for this [Submission].
  bool get ignoreReports => data['ignore_reports'];

  /// Can this [Submission] be cross-posted.
  bool get isCrosspostable => data['is_crosspostable'];

  /// Is this [Submission] hosted on a Reddit media domain.
  bool get isRedditMediaDomain => data['is_reddit_media_domain'];

  /// Is this [Submission] a self-post.
  ///
  /// Self-posts are [Submission]s that consist solely of text.
  bool get isSelf => data['is_self'];

  /// Is this [Submission] a video.
  bool get isVideo => data['is_video'];

  /// Has the currently authenticated [User] voted on this [Submission].
  ///
  /// Returns `true` if the submission is upvoted, `false` if it is downvoted,
  /// and `null` otherwise.
  bool get likes => data['likes'];

  /// Has this [Submission] been locked.
  bool get locked => data['locked'];

  /// The number of [Comment]s made on this [Submission].
  int get numComments => data['num_comments'];

  /// The number of times this [Submission] has been cross-posted.
  int get numCrossposts => data['num_crossposts'];

  /// Is this [Submission] restricted to [Redditor]s 18+.
  bool get over18 => data['over_18'];

  /// Is this [Submission] pinned.
  bool get pinned => data['pinned'];

  /// Is this [Submission] in quarantine.
  bool get quarantine => data['quarantine'];

  /// The reason why this [Submission] was removed.
  ///
  /// Returns `null` if the [Submission] has not been removed.
  String get removalReason => data['removal_reason'];

  /// Has this [Submission] been removed.
  bool get removed => data['removed'];

  /// Is this [Submission] saved.
  bool get saved => data['saved'];

  /// The current score (net upvotes) for this [Submission].
  int get score => data['score'];

  /// The text body of a self-text post.
  ///
  /// Returns null if the [Submission] is not a self-text submission.
  String get selftext => data['selftext'];

  /// Is this [Submission] marked as spam.
  bool get spam => data['spam'];

  /// Does this [Submission] contain a spoiler.
  bool get spoiler => data['spoiler'];

  /// A [SubredditRef] of the [Subreddit] this [Submission] was made in.
  SubredditRef get subreddit => reddit.subreddit(data['subreddit']);

  /// The type of the [Subreddit] this [Submission] was made in.
  ///
  /// For example, if a [Subreddit] is restricted to approved submitters, this
  /// property will be 'restricted'.
  String get subredditType => data['subreddit_type'];

  /// Has this [Submission] been stickied.
  bool get stickied => data['stickied'];

  /// The title of the [Submission].
  String get title => data['title'];

  /// The Uri of the [Submission]'s thumbnail image.
  Uri get thumbnail => Uri.parse(data['thumbnail']);

  /// The ratio of upvotes to downvotes for this [Submission].
  double get upvoteRatio => data['upvote_ratio'];

  /// The number of upvotes this [Submission] has received.
  int get upvotes => data['ups'];

  /// The URL of the [Submission]'s link.
  Uri get url => (data['url'] == null) ? null : Uri.parse(data['url']);

  /// The number of views this [Submission] has.
  int get viewCount => data['view_count'];

  /// Has this [Submission] been visited by the current [User].
  bool get visited => data['visited'];

  Submission.parse(Reddit reddit, Map data)
      : super.withPath(reddit, SubmissionRef._infoPath(data['id'])) {
    setData(this, data);
  }

  /// Crosspost the submission to another [Subreddit].
  ///
  /// [subreddit] is the subreddit to crosspost the submission to, [title] is
  /// the title to be given to the new post (default is the original title), and
  /// if [sendReplies] is true (default), replies will be sent to the currently
  /// authenticated user's messages.
  ///
  /// Note: crosspost is fairly new on Reddit and is only available to
  /// certain users on select subreddits who opted in to the beta. This method
  /// does work, but is difficult to test correctly while the feature is in
  /// beta. As a result, it's probably best not to use this method until
  /// crossposting is out of beta on Reddit (still in beta as of 2017/10/27).
  Future<Submission> crosspost(Subreddit subreddit,
      {String title, bool sendReplies: true}) async {
    final data = {
      'sr': subreddit.displayName,
      'title': title ?? this.data['title'],
      'sendreplies': sendReplies.toString(),
      'kind': 'crosspost',
      'crosspost_fullname': fullname,
      'api_type': 'json',
    };
    return reddit.post(apiPath['submit'], data);
  }

  /// Unhide the submission.
  ///
  /// If provided, [otherSubmissions] is a list of other submissions to be
  /// unhidden.
  Future unhide({List<Submission> otherSubmissions}) async {
    for (final submissions in _chunk(otherSubmissions, 50)) {
      await reddit.post(apiPath['unhide'], {'id': submissions},
          discardResponse: true);
    }
  }

  /// Hide the submission.
  ///
  /// If provided, [otherSubmissions] is a list of other submissions to be
  /// hidden.
  Future hide({List<Submission> otherSubmissions}) async {
    for (final submissions in _chunk(otherSubmissions, 50)) {
      await reddit.post(apiPath['hide'], {'id': submissions},
          discardResponse: true);
    }
  }

  Iterable<String> _chunk(
      List<Submission> otherSubmissions, int chunkSize) sync* {
    final submissions = <String>[fullname];
    if (otherSubmissions != null) {
      otherSubmissions.forEach((Submission s) {
        submissions.add(s.fullname);
      });
    }
    for (var i = 0; i < submissions.length; i += chunkSize) {
      yield submissions
          .getRange(i, min(i + chunkSize, submissions.length))
          .join(',');
    }
  }
}

/// A lazily initialized representation of a standard Reddit submission. Can be
/// promoted to a [Submission].
class SubmissionRef extends UserContent {
  static final RegExp _submissionRegExp = new RegExp(r'{id}');
  CommentForest _comments;
  String _id;
  final Map _commentsById = new Map();

  SubmissionRef.withPath(Reddit reddit, String path)
      : _id = idFromUrl(path),
        super.withPath(reddit, _infoPath(idFromUrl(path)));

  SubmissionRef.withID(Reddit reddit, String id)
      : _id = id,
        super.withPath(reddit, _infoPath(id));

  static String _infoPath(String id) =>
      apiPath['submission'].replaceAll(_submissionRegExp, id);

  // TODO(bkonyi): implement
  // SubmissionModeration get mod;

  /// The shortened link for the [Submission].
  Uri get shortlink => Uri.parse(reddit.config.shortUrl + _id);

  // TODO(bkonyi): allow for paths without trailing '/'.
  /// Retrieve a submission ID from a given URL.
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
      throw new DRAWArgumentError('idFromUrl expects either a String or Uri as'
          ' input');
    }
    var submissionId = '';
    final parts = uri.path.split('/');
    final commentsIndex = parts.indexOf('comments');
    if (commentsIndex == -1) {
      submissionId = parts[parts.length - 2];
    } else {
      submissionId = parts[commentsIndex + 1];
    }
    return submissionId;
  }

  // TODO(bkonyi): implement
  // Stream duplicates() => throw new DRAWUnimplementedError();

  /// Promotes this [SubmissionRef] into a populated [Submission].
  Future<Submission> populate() async {
    final response = await fetch();
    final submission = response[0]['listing'][0];
    submission._comments =
        new CommentForest(submission, response[1]['listing']);
    return submission;
  }
}

class SubmissionModeration extends Object with UserContentModerationMixin {
  static final RegExp _subModRegExp = new RegExp(r'{subreddit}');

  Submission get content => _content;
  final Submission _content;

  SubmissionModeration._(this._content);

  /// Enables contest mode for the [Comment]s in this [Submission].
  ///
  /// If `state` is true (default), contest mode is enabled for this
  /// [Submission].
  ///
  /// Contest mode have the following effects:
  ///     * The comment thread will default to being sorted randomly.
  ///     * Replies to top-level comments will be hidden behind
  ///       "[show replies]" buttons.
  ///     * Scores will be hidden from non-moderators.
  ///     * Scores accessed through the API (mobile apps, bots) will be
  ///       obscured to "1" for non-moderators.
  Future contestMode({bool state = true}) async => await _content.reddit.post(
      apiPath['contest_mode'],
      {
        'id': _content.fullname,
        'state': state.toString(),
      },
      discardResponse: true);

  /// Sets the flair for the [Submission].
  ///
  /// `text` is the flair text to be associated with the [Submission].
  /// `cssClass` is the CSS class to associate with the flair HTML.
  ///
  /// This method can only be used by an authenticated user who has moderation
  /// rights for this [Submission].
  Future flair({String text = '', String cssClass = ''}) async {
    final data = {
      'css_class': cssClass,
      'link': _content.fullname,
      'text': text,
    };
    var subreddit = _content.subreddit;
    if (subreddit is! Subreddit) {
      subreddit = await subreddit.populate();
    }
    final url = apiPath['flair']
        .replaceAll(_subModRegExp, (subreddit as Subreddit).fullname);
    await _content.reddit.post(url, data, discardResponse: true);
  }

  /// Locks the [Submission] to new [Comment]s.
  Future lock() async => await _content.reddit.post(
      apiPath['lock'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);

  /// Marks the [Submission] as not safe for work.
  ///
  /// Both the [Submission] author and users with moderation rights for this
  /// submission can set this flag.
  Future nsfw() async => await _content.reddit.post(
      apiPath['marknsfw'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);

  /// Marks the [Submission] as safe for work.
  ///
  /// Both the [Submission] author and users with moderation rights for this
  /// submission can set this flag.
  Future sfw() async => await _content.reddit.post(
      apiPath['unmarknsfw'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);

  Future spoiler() async => await _content.reddit.post(
      apiPath['spoiler'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);

  Future sticky({bool state = true, bool bottom = true}) async {
    final Map<String, dynamic> data = {
      'id': _content.fullname,
      'state': state.toString(),
    };
    if (!bottom) {
      data['num'] = 1;
    }
    return await _content.reddit.post(apiPath['sticky_submission'], data);
  }

  // TODO(bkonyi): make sort enum
  Future suggestedSort() async {}

  Future unlock() async => await _content.reddit.post(
      apiPath['unlock'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);

  Future unspoiler() async => await _content.reddit.post(
      apiPath['unspoiler'],
      {
        'id': _content.fullname,
      },
      discardResponse: true);
}
