// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/models/comment_impl.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';

class ModmailConversation extends RedditBase with RedditBaseInitializedMixin {
  static final _kIdRegExp = RegExp(r'{id}');
  static final _kConvKey = 'conversation';
  final bool _markRead;

  @override
  String get id => data[_kConvKey]['id'];

  String get infoPath =>
      apiPath['modmail_conversation'].replaceAll(_kIdRegExp, id);

  Map<String, String> get infoParams => <String, String>{
        'markRead': _markRead.toString(),
      };

  /// An ordered list of [Redditor]s who have participated in the conversation.
  List<Redditor> get authors =>
      (data[_kConvKey]['authors'] as List).cast<Redditor>();

  /// Whether or not the current conversation highlighted.
  bool get isHighlighted => data[_kConvKey]['isHighlighted'];

  /// Whether or not this is a private moderator conversation.
  bool get isInternal => data[_kConvKey]['isInternal'];

  /// The date and time the conversation was last updated by a moderator.
  DateTime get lastModUpdate =>
      GetterUtils.dateTimeOrNullFromString(data[_kConvKey]['lastModUpdate']);

  /// The date and time the conversation was last updated.
  DateTime get lastUpdated =>
      GetterUtils.dateTimeOrNullFromString(data[_kConvKey]['lastUpdated']);

  /// The date and time the conversation was last updated by a non-moderator
  /// user.
  DateTime get lastUserUpdate =>
      GetterUtils.dateTimeOrNullFromString(data[_kConvKey]['lastUserUpdate']);

  /// The number of messages in this conversation.
  int get numMessages => data[_kConvKey]['numMessages'];

  // TODO(bkonyi): find better representation of this
  List<Map> get objectIds => (data[_kConvKey]['objIds'] as List).cast<Map>();

  /// The subreddit associated with this conversation.
  SubredditRef get owner => data[_kConvKey]['owner'];

  RedditorRef get participant => data[_kConvKey]['participant'];

  /// The subject line of the conversation.
  String get subject => data[_kConvKey]['subject'];

  ModmailConversation(Reddit reddit,
      {String id, bool markRead = false, Map data})
      : _markRead = markRead,
        super(reddit) {
    if ((id == null) && (data == null)) {
      throw DRAWArgumentError("Either 'id' or 'data' must be provided");
    }
    data ??= {
      _kConvKey: {},
    };
    if (id != null) {
      data[_kConvKey]['id'] = id;
    } else if ((id == null) &&
        (!data.containsKey(_kConvKey) || !data[_kConvKey].containsKey('id'))) {
      throw DRAWArgumentError(
          "Either 'id' must be provided or 'data[\"conversation\"]' must contain key 'id'");
    }
    setData(this, data);
  }

  factory ModmailConversation.parse(Reddit reddit, Map<String, dynamic> data,
      {bool convertObjects = true}) {
    final conversation = data['conversation'];
    conversation['authors'] = (conversation['authors'] as List)
        .map((a) => reddit.objector.objectify(snakeCaseMapKeys(a)))
        .toList();
    conversation['owner'] =
        reddit.subreddit(conversation['owner']['displayName']);
    final participant = conversation['participant'] as Map;
    if ((participant != null) && participant.isNotEmpty) {
      conversation['participant'] =
          reddit.objector.objectify(snakeCaseMapKeys(participant));
    }

    if (data.containsKey('user')) {
      _convertUserSummary(reddit, data);
    }
    if (convertObjects) {
      final converted = _convertConversationObjects(reddit, data);
      data.addEntries(converted.entries);
    }

    return ModmailConversation(reddit, data: data);
  }

  String _buildConversationList(List<ModmailConversation> otherConversations) {
    final conversations = <ModmailConversation>[this];
    if (otherConversations != null) {
      conversations.addAll(otherConversations);
    }
    return conversations.map((c) => c.id).join(',');
  }

  void _internalUpdate(Map newData) {
    newData[_kConvKey] = newData['conversations'];
    newData.remove('conversations');
    newData[_kConvKey]['id'] = id;
    setData(this, newData);
  }

  static void _convertUserSummary(Reddit reddit, Map<String, dynamic> data) {
    // Recent Comments
    final recentComments = <Comment>[];
    final rawRecentComments = data['recentComments'] as Map;
    if (rawRecentComments != null) {
      rawRecentComments.forEach((k, v) {
        recentComments.add(Comment.parse(reddit, v));
      });
      data['recentComments'] = recentComments;
    }
    // Modmail Conversations
    final conversations = <ModmailConversation>[];
    final rawConversations = data['recentConvos'] as Map;
    if (rawConversations != null) {
      rawConversations.forEach((k, v) {
        conversations.add(ModmailConversation.parse(reddit, v));
      });
      data['recentConvos'] = recentComments;
    }

    // Submissions
    final submissions = <Submission>[];
    final rawSubmissions = data['recentPosts'] as Map;
    if (rawSubmissions != null) {
      rawSubmissions.forEach((k, v) {
        submissions.add(Submission.parse(reddit, v));
      });
      data['recentPosts'] = submissions;
    }
  }

  static Map<String, List<dynamic>> _convertConversationObjects(
      Reddit reddit, Map<String, dynamic> data) {
    final result = {
      'messages': <ModmailMessage>[],
      'modActions': [],
    };
    for (final t in data['conversation']['objIds']) {
      final key = t['key'];
      final tData = data[key][t['id']];
      (result[key] as List).add(reddit.objector.objectify(tData));
    }
    return result;
  }

  /// Archive the conversation.
  Future<void> archive() async => _internalUpdate(await reddit.post(
      apiPath['modmail_archive'].replaceAll(_kIdRegExp, id),
      <String, String>{}));

  /// Highlight the conversation.
  Future<void> highlight() async => _internalUpdate(await reddit.post(
      apiPath['modmail_highlight'].replaceAll(_kIdRegExp, id),
      <String, String>{}));

  /// Mute the user (non-moderator) associated with the conversation.
  Future<void> mute() async => _internalUpdate(await reddit.post(
      apiPath['modmail_mute'].replaceAll(_kIdRegExp, id), <String, String>{}));

  /// Mark the conversation as read.
  ///
  /// If `otherConversations` is provided, those conversations will also be
  /// marked as read.
  Future<void> read({List<ModmailConversation> otherConversations}) async {
    final data = <String, String>{
      'conversationIds': _buildConversationList(otherConversations),
    };
    await reddit.post(apiPath['modmail_read'].replaceAll(_kIdRegExp, id), data);
  }

  /// Reply to the conversation.
  ///
  /// `body`: the markdown formatted content of the reply.
  /// `authorHidden`: when true, the author is hidden from non-moderators. This
  /// is the same as replying as a subreddit.
  /// `internal`: when true, the reply will be an internal moderator note on
  /// the conversation that is not visible to non-moderators.
  ///
  /// Returns a [ModmailMessage] for the new message.
  Future<ModmailMessage> reply(String body,
      {bool authorHidden = false, bool internal = false}) async {
    final data = <String, String>{
      'body': body,
      'isAuthorHidden': authorHidden.toString(),
      'isInternal': internal.toString(),
    };
    final response = await reddit.post(
        apiPath['modmail_conversation'].replaceAll(_kIdRegExp, id), data,
        objectify: false);
    final msgId = ((response['conversation']['objIds'] as List).last)['id'];
    final message = response['messages'][msgId];
    return ModmailMessage.parse(reddit, message);
  }

  /// Unarchive the conversation.
  Future<void> unarchive() async => _internalUpdate(await reddit.post(
      apiPath['modmail_unarchive'].replaceAll(_kIdRegExp, id),
      <String, String>{}));

  /// Unhighlight the conversation.
  Future<void> unhighlight() async => _internalUpdate(await reddit.delete(
        apiPath['modmail_highlight'].replaceAll(_kIdRegExp, id),
      ));

  /// Unmute the conversation.
  Future<void> unmute() async => _internalUpdate(await reddit.post(
      apiPath['modmail_unmute'].replaceAll(_kIdRegExp, id),
      <String, String>{}));

  /// Mark the conversation as unread.
  ///
  /// If `otherConversations` is provided, those conversations will also be
  /// marked as unread.
  Future<void> unread({List otherConversations}) async {
    final data = <String, String>{
      'conversationIds': _buildConversationList(otherConversations),
    };
    return await reddit.post(
        apiPath['modmail_unread'].replaceAll(_kIdRegExp, id), data);
  }
}

class ModmailMessage {
  final Reddit reddit;
  final Map<String, dynamic> data;
  ModmailMessage.parse(this.reddit, this.data);

  Redditor get author =>
      Redditor.parse(reddit, snakeCaseMapKeys(data['author']));

  String get body => data['body'];

  String get bodyMarkdown => data['bodyMarkdown'];

  DateTime get date => GetterUtils.dateTimeOrNullFromString(data['date']);

  String get id => data['id'];

  bool get isDeleted => data['author']['isDeleted'];

  bool get isHidden => data['author']['isHidden'];

  bool get isInternal => data['isInternal'];

  bool get isOriginalPoster => data['author']['isOp'];

  bool get isParticipant => data['author']['isParticipant'];

  String toString() => JsonEncoder.withIndent('  ').convert(data);
}

class ModmailAction {
  final Reddit reddit;
  final Map<String, dynamic> data;
  ModmailAction.parse(this.reddit, this.data);

  int get actionTypeId => data['actionTypeId'];

  Redditor get author =>
      Redditor.parse(reddit, snakeCaseMapKeys(data['author']));

  DateTime get date => GetterUtils.dateTimeOrNullFromString(data['date']);

  String get id => data['id'];

  String toString() => JsonEncoder.withIndent('  ').convert(data);
}
