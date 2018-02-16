// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'base.dart';
import 'exceptions.dart';
import 'reddit.dart';
import 'models/comment_impl.dart';
import 'models/comment_forest.dart';
import 'models/message.dart';
import 'models/multireddit.dart';
import 'models/redditor.dart';
import 'models/submission_impl.dart';
import 'models/subreddit.dart';

/// Converts responses from the Reddit API into instances of [RedditBase].
class Objector extends RedditBase {
  Objector(Reddit reddit) : super(reddit);

  static String _removeIDPrefix(String id) {
    return id.split('_')[1];
  }

  dynamic _objectifyDictionary(Map data) {
    if (data.containsKey('name')) {
      // Redditor type.
      return new Redditor.parse(reddit, data);
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultCommentKind)) {
      final commentData = data['data'];
      final comment = new Comment.parse(reddit, commentData);
      if (commentData.containsKey('replies') &&
          (commentData['replies'] is Map) &&
          commentData['replies'].containsKey('kind') &&
          (commentData['replies']['kind'] == 'Listing') &&
          commentData['replies'].containsKey('data') &&
          (commentData['replies']['data'] is Map) &&
          commentData['replies']['data'].containsKey('children')) {
        final replies =
            _objectifyList(commentData['replies']['data']['children']);
        final submission = new Submission.withID(
            reddit, _removeIDPrefix(commentData['link_id']));
        final commentForest = new CommentForest(submission, replies);
        setRepliesInternal(comment, commentForest);
      }
      return comment;
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultSubmissionKind)) {
      return new Submission.parse(reddit, data['data']);
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultSubredditKind)) {
      return new Subreddit.parse(reddit, data);
    } else if (data.containsKey('kind') &&
        data['kind'] == Reddit.defaultMessageKind) {
      return new Message.parse(reddit, data['data']);
    } else if (data.containsKey('kind') && (data['kind'] == 'LabeledMulti')) {
      assert(
          data.containsKey('data'),
          'field "data" is expected in a response'
          'of type "LabeledMulti"');
      return new Multireddit.parse(reddit, data);
    } else if (data.containsKey('sr') &&
        data.containsKey('comment_karma') &&
        data.containsKey('link_karma')) {
      final subreddit = new Subreddit.parse(reddit, data['sr']);
      final value = {
        'commentKarma': data['comment_karma'],
        'linkKarma': data['link_karma'],
      };
      return {subreddit: value};
    } else if ((data.length == 3) &&
        data.containsKey('day') &&
        data.containsKey('hour') &&
        data.containsKey('month')) {
      return SubredditTraffic.parseTrafficResponse(data);
    } else if (data.containsKey('rules')) {
      final rules = <Rule>[];
      for (final rawRule in data['rules']) {
        rules.add(new Rule.parse(rawRule));
      }
      return rules;
    } else {
      throw new DRAWInternalError('Cannot objectify unsupported'
          ' response:\n$data');
    }
  }

  List _objectifyList(List listing) {
    final objectifiedListing = new List(listing.length);
    for (var i = 0; i < listing.length; ++i) {
      objectifiedListing[i] = objectify(listing[i]);
    }
    return objectifiedListing;
  }

  /// Converts a response from the Reddit API into an instance of [RedditBase]
  /// or a container of [RedditBase] objects.
  ///
  /// [data] should be one of [List] or [Map], and the return type is one of
  /// [RedditBase], [List<RedditBase>], or [Map<RedditBase>] depending on the
  /// response type.
  dynamic objectify(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is List) {
      return _objectifyList(data);
    } else if (data is! Map) {
      throw new DRAWInternalError('data must be of type List or Map, got '
          '${data.runtimeType}');
    } else if (data.containsKey('kind')) {
      final kind = data['kind'];
      if (kind == 'Listing') {
        final listing = data['data']['children'];
        final before = data['data']['before'];
        final after = data['data']['after'];
        final objectifiedListing = _objectifyList(listing);
        final result = {
          'listing': objectifiedListing,
          'before': before,
          'after': after
        };
        return result;
      } else if (kind == 'UserList') {
        final listing = data['data']['children'];
        return _objectifyList(listing);
      } else if (kind == 'KarmaList') {
        final listing = _objectifyList(data['data']);
        final karmaMap = new Map<Subreddit, Map<String, int>>();
        listing.forEach((map) {
          karmaMap.addAll(map);
        });
        return karmaMap;
      } else if (kind == 't2') {
        // Account information about a redditor who isn't the currently
        // authenticated user.
        return data['data'];
      } else if (kind == 'more') {
        return new MoreComments.parse(reddit, data['data']);
      } else {
        return _objectifyDictionary(data);
      }
    } else if (data.containsKey('json') && data['json'].containsKey('data')) {
      // Response from Subreddit.submit.
      if (data['json']['data'].containsKey('url')) {
        return new Submission.parse(reddit, data['json']['data']);
      } else if (data['json']['data'].containsKey('things')) {
        return _objectifyList(data['json']['data']['things']);
      } else {
        throw new DRAWInternalError('Invalid json response: $data');
      }
    }
    return _objectifyDictionary(data);
  }
}
