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

/// A lazily initialized class which represents a Modmail conversation. Can be
/// promoted to a [ModmailConversation].
class ModmailConversationRef extends RedditBase {
  static final _kIdRegExp = RegExp(r'{id}');

  /// A unique ID for this conversation.
  final String? id;

  /// THe subject line of this conversation.
  ///
  /// May be null.
  final String? subject;
  final bool _markRead;

  @override
  String get infoPath =>
      apiPath['modmail_conversation'].replaceAll(_kIdRegExp, id);

  @override
  Map<String, String>? get infoParams => <String, String>{
        'markRead': _markRead.toString(),
      };

  /// Promotes this [ModmailConversationRef] into a populated
  /// [ModmailConversation].
  Future<ModmailConversation> populate() async => ModmailConversation(reddit,
      data: (await fetch()) as Map<dynamic, dynamic>?);

  ModmailConversationRef(Reddit reddit, this.id, {bool markRead = false})
      : _markRead = markRead,
        subject = null,
        super(reddit);

  ModmailConversationRef._(Reddit reddit, this._markRead)
      : id = null,
        subject = null,
        super(reddit);
  ModmailConversationRef._withSubject(Reddit reddit, this.id, this.subject)
      : _markRead = false,
        super(reddit);
}

/// A fully initialized class which represents a Modmail conversation.
class ModmailConversation extends ModmailConversationRef
    with RedditBaseInitializedMixin {
  static final _kIdRegExp = RegExp(r'{id}');
  static final _kConvKey = 'conversation';

  @override
  String get id => data![_kConvKey]['id'];

  /// An ordered list of [Redditor]s who have participated in the conversation.
  List<Redditor> get authors =>
      (data![_kConvKey]['authors'] as List).cast<Redditor>();

  /// Whether or not the current conversation highlighted.
  bool get isHighlighted => data![_kConvKey]['isHighlighted'];

  /// Whether or not this is a private moderator conversation.
  bool get isInternal => data![_kConvKey]['isInternal'];

  /// The date and time the conversation was last updated by a moderator.
  DateTime? get lastModUpdate =>
      GetterUtils.dateTimeOrNullFromString(data![_kConvKey]['lastModUpdate']);

  /// The date and time the conversation was last updated.
  DateTime get lastUpdated =>
      GetterUtils.dateTimeOrNullFromString(data![_kConvKey]['lastUpdated'])!;

  /// The date and time the conversation was last updated by a non-moderator
  /// user.
  DateTime? get lastUserUpdate =>
      GetterUtils.dateTimeOrNullFromString(data![_kConvKey]['lastUserUpdate']);

  /// The messages from this conversation.
  List<ModmailMessage> get messages => data!['messages'].cast<ModmailMessage>();

  /// A list of all moderator actions made on this conversation.
  List<ModmailAction> get modActions =>
      data!['modActions'].cast<ModmailAction>();

  /// The number of messages in this conversation.
  int get numMessages => data![_kConvKey]['numMessages'];

  // TODO(bkonyi): find better representation of this
  List<Map> get objectIds => (data![_kConvKey]['objIds'] as List).cast<Map>();

  /// The subreddit associated with this conversation.
  SubredditRef get owner => data![_kConvKey]['owner'];

  RedditorRef get participant => data![_kConvKey]['participant'];

  /// The subject line of the conversation.
  @override
  String? get subject => data![_kConvKey]['subject'];

  ModmailConversation(Reddit reddit,
      {String? id, bool markRead = false, Map? data})
      : super._(reddit, markRead) {
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
    final participant = conversation['participant'] as Map?;
    if ((participant != null) && participant.isNotEmpty) {
      conversation['participant'] = reddit.objector
          .objectify(snakeCaseMapKeys(participant as Map<String, dynamic>));
    }

    if (data.containsKey('user')) {
      _convertUserSummary(reddit, data['user']);
    }
    if (convertObjects) {
      final converted = _convertConversationObjects(reddit, data);
      data.addEntries(converted.entries);
    }

    return ModmailConversation(reddit, data: data);
  }

  String _buildConversationList(List<ModmailConversation>? otherConversations) {
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
    final rawRecentComments = data['recentComments'] as Map?;
    if (rawRecentComments != null) {
      rawRecentComments.forEach((k, v) {
        recentComments.add(Comment.parse(reddit, v));
      });
      data['recentComments'] = recentComments;
    }
    // Modmail Conversations
    final conversations = <ModmailConversationRef>[];
    final rawConversations = data['recentConvos'] as Map?;
    if (rawConversations != null) {
      rawConversations.forEach((k, v) {
        conversations.add(ModmailConversationRef._withSubject(
            reddit, data['id'], data['subject']));
      });
      data['recentConvos'] = recentComments;
    }

    // Submissions
    final submissions = <Submission>[];
    final rawSubmissions = data['recentPosts'] as Map?;
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
      'messages': <ModmailMessage?>[],
      'modActions': [],
    };
    for (final t in data['conversation']['objIds']) {
      final key = t['key'];
      final tData = data[key][t['id']];
      result[key]!.add(reddit.objector.objectify(tData));
    }
    return result;
  }

  /// Archive the conversation.
  Future<void> archive() async => _internalUpdate((await reddit.post(
      apiPath['modmail_archive'].replaceAll(_kIdRegExp, id),
      <String, String>{})) as Map<dynamic, dynamic>);

  /// Highlight the conversation.
  Future<void> highlight() async => _internalUpdate((await reddit.post(
      apiPath['modmail_highlight'].replaceAll(_kIdRegExp, id),
      <String, String>{})) as Map<dynamic, dynamic>);

  /// Mute the user (non-moderator) associated with the conversation.
  Future<void> mute() async => _internalUpdate((await reddit.post(
      apiPath['modmail_mute'].replaceAll(_kIdRegExp, id),
      <String, String>{})) as Map<dynamic, dynamic>);

  /// Mark the conversation as read.
  ///
  /// If `otherConversations` is provided, those conversations will also be
  /// marked as read.
  Future<void> read({List<ModmailConversation>? otherConversations}) async {
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
  Future<void> unarchive() async => _internalUpdate((await reddit.post(
      apiPath['modmail_unarchive'].replaceAll(_kIdRegExp, id),
      <String, String>{})) as Map<dynamic, dynamic>);

  /// Unhighlight the conversation.
  Future<void> unhighlight() async => _internalUpdate((await reddit.delete(
        apiPath['modmail_highlight'].replaceAll(_kIdRegExp, id),
      )) as Map<dynamic, dynamic>);

  /// Unmute the conversation.
  Future<void> unmute() async => _internalUpdate((await reddit.post(
      apiPath['modmail_unmute'].replaceAll(_kIdRegExp, id),
      <String, String>{})) as Map<dynamic, dynamic>);

  /// Mark the conversation as unread.
  ///
  /// If `otherConversations` is provided, those conversations will also be
  /// marked as unread.
  Future<void> unread({List? otherConversations}) async {
    final data = <String, String>{
      'conversationIds': _buildConversationList(
          otherConversations as List<ModmailConversation>?),
    };
    return await reddit.post(
        apiPath['modmail_unread'].replaceAll(_kIdRegExp, id), data);
  }
}

/// A class that represents a message from a [ModmailConversation].
class ModmailMessage {
  final Reddit reddit;
  final Map<String, dynamic>? data;
  ModmailMessage.parse(this.reddit, this.data);

  /// The [Redditor] who composed this message.
  Redditor get author =>
      Redditor.parse(reddit, snakeCaseMapKeys(data!['author']));

  /// The HTML body of the message.
  String get body => data!['body'];

  /// The body of the message in Markdown format.
  String get bodyMarkdown => data!['bodyMarkdown'];

  /// The date and time the message was sent.
  DateTime get date => GetterUtils.dateTimeOrNullFromString(data!['date'])!;

  /// A unique ID associated with this message.
  String get id => data!['id'];

  /// True if the account that authored this message has been deleted.
  bool get isDeleted => data!['author']['isDeleted'];

  /// True if the message was sent on behalf of a subreddit.
  bool get isHidden => data!['author']['isHidden'];

  /// True if the message is only visible to moderators.
  bool get isInternal => data!['isInternal'];

  /// True if this message was written by the author of the thread.
  bool get isOriginalPoster => data!['author']['isOp'];

  /// True if the author of this message has participated in the conversation.
  bool get isParticipant => data!['author']['isParticipant'];

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(data);
}

ModmailActionType _modmailActionTypeFromInt(int i) {
  switch (i) {
    case 0:
      return ModmailActionType.highlight;
    case 1:
      return ModmailActionType.unhighlight;
    case 2:
      return ModmailActionType.archive;
    case 3:
      return ModmailActionType.unarchive;
    case 4:
      return ModmailActionType.reportedToAdmins;
    case 5:
      return ModmailActionType.mute;
    case 6:
      return ModmailActionType.unmute;
    default:
      return ModmailActionType.unknown;
  }
}

/// All possible actions that can be made in a [ModmailConversation].
enum ModmailActionType {
  highlight,
  unhighlight,
  archive,
  unarchive,
  reportedToAdmins,
  mute,
  unmute,
  unknown
}

/// A class that represents an action taken by a moderator in a
/// [ModmailConversation].
class ModmailAction {
  final Reddit reddit;
  final Map<String, dynamic> data;
  ModmailAction.parse(this.reddit, this.data);

  /// The type of moderator action taken.
  ModmailActionType get actionType =>
      _modmailActionTypeFromInt(data['actionTypeId']);

  /// The [Redditor] who applied the moderator action.
  Redditor get author =>
      Redditor.parse(reddit, snakeCaseMapKeys(data['author']));

  /// The date the action was made.
  DateTime get date => GetterUtils.dateTimeOrNullFromString(data['date'])!;

  /// A unique ID associated with this action.
  String get id => data['id'];

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(data);
}
