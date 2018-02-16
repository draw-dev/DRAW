// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import '../api_paths.dart';
import '../base_impl.dart';
import '../exceptions.dart';
import '../reddit.dart';
import 'comment_impl.dart';
import 'comment_forest.dart';
import 'subreddit.dart';
import 'user_content.dart';

Comment getCommentByIdInternal(Submission s, String id) {
  if (s._commentsById.containsKey(id)) {
    return s._commentsById[id];
  }
  return null;
}

void insertCommentById(Submission s, /*Comment, MoreComments*/ c) {
  assert(!s._commentsById.containsKey(c.fullname));
  s._commentsById[c.fullname] = c;
}

/// A representation of a standard Reddit submission.
class Submission extends UserContent {
  static final RegExp _submissionRegExp = new RegExp(r'{id}');
  CommentForest _comments;
  String _id;
  final Map _commentsById = new Map();

  Submission.parse(Reddit reddit, Map data)
      : _id = data['id'],
        super.loadDataWithPath(reddit, data, _infoPath(data['id']));

  Submission.withPath(Reddit reddit, String path)
      : _id = idFromUrl(path),
        super.withPath(reddit, _infoPath(idFromUrl(path)));

  Submission.withID(Reddit reddit, String id)
      : _id = id,
        super.withPath(reddit, _infoPath(id));

  static String _infoPath(String id) =>
      apiPath['submission'].replaceAll(_submissionRegExp, id);

  /// Returns the [CommentForest] representing the comments for this
  /// [Submission].
  Future<CommentForest> get comments async {
    if (_comments == null) {
      final response = await refresh();
      _comments = new CommentForest(this, response[1]);
    }
    return _comments;
  }

  // TODO(bkonyi): implement
  // SubmissionFlair get flair;

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
      'title': title ?? await property('title'),
      'sendreplies': sendReplies.toString(),
      'kind': 'crosspost',
      'crosspost_fullname': await fullname,
      'api_type': 'json',
    };
    return reddit.post(apiPath['submit'], data);
  }

  // TODO(bkonyi): implement
  // Stream duplicates() => throw new DRAWUnimplementedError();

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

  Iterable<String> _chunk(
      List<Submission> otherSubmissions, int chunkSize) sync* {
    final submissions = <String>[fullnameSync(this)];
    if (otherSubmissions != null) {
      otherSubmissions.forEach((Submission s) {
        submissions.add(fullnameSync(s));
      });
    }
    for (var i = 0; i < submissions.length; i += chunkSize) {
      yield submissions
          .getRange(i, min(i + chunkSize, submissions.length))
          .join(',');
    }
  }
}
