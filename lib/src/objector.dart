// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:draw/src/base.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/modmail.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/models/comment_impl.dart';
import 'package:draw/src/models/comment_forest.dart';
import 'package:draw/src/models/flair.dart';
import 'package:draw/src/models/message.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/subreddit_moderation.dart';

//final //logger = Logger('Objector');

/// Converts responses from the Reddit API into instances of [RedditBase].
class Objector extends RedditBase {
  Objector(Reddit reddit) : super(reddit);

  // Used in test cases to trigger a DRAWAuthenticationError
  static const _testThrowKind = 'DRAW_TEST_THROW_AUTH_ERROR';

  static String _removeIDPrefix(String id) {
    return id.split('_')[1];
  }

  dynamic _objectifyDictionary(Map data) {
    //logger.log(Level.INFO, '_objectifyDictionary');
    if (data.containsKey('name')) {
      // Redditor type.
      //logger.log(Level.FINE, 'parsing Redditor');
      return Redditor.parse(reddit, data);
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultCommentKind)) {
      final commentData = data['data'];
      final comment = Comment.parse(reddit, commentData);
      ////logger.log(Level.INFO, 'parsing Comment(id: ${comment.id})');
      ////logger.log(Level.INFO, 'Comment Data: ${DRAWLoggingUtils.jsonify(data)}');
      if (commentData.containsKey('replies') &&
          (commentData['replies'] is Map) &&
          commentData['replies'].containsKey('kind') &&
          (commentData['replies']['kind'] == 'Listing') &&
          commentData['replies'].containsKey('data') &&
          (commentData['replies']['data'] is Map) &&
          commentData['replies']['data'].containsKey('children')) {
        //logger.log(Level.FINE, 'and parsing CommentForest for ${comment.id}');
        final replies =
            _objectifyList(commentData['replies']['data']['children']);
        //logger.log(Level.INFO, 'Done objectifying list of comments for CommentForest for ${comment.id}');
        final submission = SubmissionRef.withID(
            reddit, _removeIDPrefix(commentData['link_id']));
        //logger.log(Level.INFO, 'Parent submission for Comment(id: ${comment.id}): ${_removeIDPrefix(commentData["link_id"])}');
        final commentForest = CommentForest(submission, replies);
        setRepliesInternal(comment, commentForest);
      }
      return comment;
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultSubmissionKind)) {
      return Submission.parse(reddit, data['data']);
    } else if (data.containsKey('kind') &&
        (data['kind'] == Reddit.defaultSubredditKind)) {
      return Subreddit.parse(reddit, data);
    } else if (data.containsKey('kind') &&
        data['kind'] == Reddit.defaultMessageKind) {
      return Message.parse(reddit, data['data']);
    } else if (data.containsKey('kind') && (data['kind'] == 'LabeledMulti')) {
      assert(
          data.containsKey('data'),
          'field "data" is expected in a response'
          'of type "LabeledMulti"');
      return Multireddit.parse(reddit, data);
    } else if (data.containsKey('kind') && (data['kind'] == 'modaction')) {
      return buildModeratorAction(reddit, data['data']);
    } else if (data.containsKey('sr') &&
        data.containsKey('comment_karma') &&
        data.containsKey('link_karma')) {
      final subreddit = Subreddit.parse(reddit, data['sr']);
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
        rules.add(Rule.parse(rawRule));
      }
      return rules;
    } else if (data.containsKey('kind') && (data['kind'] == _testThrowKind)) {
      throw DRAWAuthenticationError('This is an error that should only be '
          'seen in tests. Please file an issue if you see this while not running'
          ' tests.');
    } else if (data.containsKey('users')) {
      final flairListRaw = data['users'].cast<Map<String, dynamic>>();
      final flairList = <Flair>[];
      for (final flair in flairListRaw) {
        flairList.add(Flair.parse(reddit, flair.cast<String, String>()));
      }
      return flairList;
    } else if (data.containsKey('status') &&
        data.containsKey('errors') &&
        data.containsKey('ok') &&
        data.containsKey('warnings')) {
      // Flair update response.
      return data;
    } else if (data.containsKey('current') && data.containsKey('choices')) {
      // Flair template listing.
      return data;
    } else if (data.containsKey('conversations')) {
      // Modmail conversations.
      return data;
    } else if (data.containsKey('conversation')) {
      // Single modmail conversation.
      return ModmailConversation.parse(reddit, data).data;
    } else if (data.containsKey('body') &&
        data.containsKey('author') &&
        data.containsKey('isInternal')) {
      return ModmailMessage.parse(reddit, data);
    } else if (data.containsKey('date') && data.containsKey('actionTypeId')) {
      return ModmailAction.parse(reddit, data);
    } else if (data.containsKey('timestamp') &&
        data.containsKey('reason') &&
        data.containsKey('page') &&
        data.containsKey('id')) {
      return data;
    } else {
      throw DRAWInternalError('Cannot objectify unsupported'
          ' response:\n$data');
    }
  }

  List _objectifyList(List listing) {
    //logger.log(Level.FINE, 'objectifying list(len: ${listing.length})');
    final objectifiedListing = List(listing.length);
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
    //logger.log(Level.FINE, 'objectifying');
    if (data == null) {
      return null;
    }
    if (data is List) {
      return _objectifyList(data);
    } else if (data is! Map) {
      throw DRAWInternalError('data must be of type List or Map, got '
          '${data.runtimeType}');
    } else if (data.containsKey('kind')) {
      final kind = data['kind'];
      if (kind == 'Listing') {
        //logger.log(Level.FINE, 'parsing Listing');
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
        //logger.log(Level.FINE, 'parsing UserList');
        final listing = data['data']['children'];
        return _objectifyList(listing);
      } else if (kind == 'KarmaList') {
        //logger.log(Level.FINE, 'parsing KarmaList');
        final listing = _objectifyList(data['data']);
        final karmaMap = Map<Subreddit, Map<String, int>>();
        listing.forEach((map) {
          karmaMap.addAll(map);
        });
        return karmaMap;
      } else if (kind == 't2') {
        // Account information about a redditor who isn't the currently
        // authenticated user.
        //logger.log(Level.INFO, 'account information for non-current user');
        return data['data'];
      } else if (kind == 'more') {
        //logger.log(Level.INFO, 'parsing MoreComments');
        //logger.log(Level.INFO, 'Data: ${DRAWLoggingUtils.jsonify(data["data"])}');
        return MoreComments.parse(reddit, data['data']);
      } else {
        //logger.log(Level.INFO, 't2 but not more comments or Redditor');
        return _objectifyDictionary(data);
      }
    } else if (data.containsKey('json')) {
      if (data['json'].containsKey('data')) {
        // Response from Subreddit.submit.
        //logger.log(Level.FINE, 'Subreddit.submit response');
        if (data['json']['data'].containsKey('url')) {
          return Submission.parse(reddit, data['json']['data']);
        } else if (data['json']['data'].containsKey('things')) {
          return _objectifyList(data['json']['data']['things']);
        } else {
          throw DRAWInternalError('Invalid json response: $data');
        }
      } else if (data['json'].containsKey('errors')) {
        const kSubredditNoExist = 'SUBREDDIT_NOEXIST';
        const kUserDoesntExist = 'USER_DOESNT_EXIST';

        final errors = data['json']['errors'];
        //logger.log(Level.SEVERE, 'Error response: $errors');
        if (errors is List && errors.isNotEmpty) {
          final error = errors[0][0];
          final field = errors[0].last;
          switch (error) {
            case kSubredditNoExist:
              throw DRAWInvalidSubredditException(field);
            case kUserDoesntExist:
              throw DRAWInvalidRedditorException(field);
            default:
              // TODO(bkonyi): make an actual exception for this.
              throw DRAWUnimplementedError('Error response: $errors');
          }
        }
        return null;
      } else {
        throw DRAWInternalError('Invalid json response: $data');
      }
    }
    return _objectifyDictionary(data);
  }
}
