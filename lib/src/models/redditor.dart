// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/listing/mixins/gilded.dart';
import 'package:draw/src/listing/mixins/redditor.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/mixins/messageable.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/submission.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/trophy.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';

/// A fully initialized class representing a particular Reddit user, also
/// known as a Redditor.
class Redditor extends RedditorRef with RedditBaseInitializedMixin {
  /// The amount of comment karma earned by the Redditor.
  int get commentKarma => data['comment_karma'];

  /// The time the Redditor's account was created.
  DateTime get createdUtc => GetterUtils.dateTimeOrNull(data['created_utc']);

  /// The amount of Reddit Gold creddits a Redditor currently has.
  int get goldCreddits => data['gold_creddits'];

  /// The UTC date and time that the Redditor's Reddit Gold subscription ends.
  ///
  /// Returns `null` if the Redditor does not have Reddit Gold.
  DateTime get goldExpiration =>
      GetterUtils.dateTimeOrNull(data['gold_expiration']);

  /// Redditor has Reddit Gold.
  bool get hasGold => data['is_gold'];

  /// Redditor has Mod Mail.
  bool get hasModMail => data['has_mod_mail'];

  /// Redditor has a verified email address.
  bool get hasVerifiedEmail => data['has_verified_email'];

  /// Redditor has opted into the Reddit beta.
  bool get inBeta => data['in_beta'];

  /// Number of [Message]s in the Redditor's [Inbox].
  int get inboxCount => data['inbox_count'];

  /// Redditor is a Reddit employee.
  bool get isEmployee => data['is_employee'];

  /// Redditor is a Moderator.
  bool get isModerator => data['is_mod'];

  /// The suspension status of the current Redditor.
  bool get isSuspended => data['is_suspended'];

  /// The amount of link karma earned by the Redditor.
  int get linkKarma => data['link_karma'];

  /// The list of moderator permissions for the user.
  ///
  /// Only populated for moderator related calls for a [Subreddit].
  List<ModeratorPermission> get moderatorPermissions =>
      stringsToModeratorPermissions(data['mod_permissions'].cast<String>());

  /// Redditor has new Mod Mail.
  bool get newModMailExists => data['new_modmail_exists'];

  /// The note associated with a friend.
  ///
  /// Only populated for responses from friend related called.
  String get note => data['note'];

  /// Redditor can see 18+ content.
  bool get over18 => data['over_18'];

  /// Whether the Redditor has chosen to filter profanity.
  bool get preferNoProfanity => data['pref_no_profanity'];

  /// The date and time when the Redditor's suspension ends.
  DateTime get suspensionExpirationUtc =>
      GetterUtils.dateTimeOrNull(data['suspension_expiration_utc']);

  Redditor.parse(Reddit reddit, Map data) : super(reddit) {
    if (!data.containsKey('name') &&
        !(data.containsKey('kind') &&
            data['kind'] == Reddit.defaultRedditorKind)) {
      throw DRAWArgumentError("input argument 'data' is not a valid"
          " representation of a Redditor");
    }
    setData(this, data);
    _name = data['name'];
    _path = apiPath['user'].replaceAll(RedditorRef._userRegExp, _name);
  }
}

/// A lazily initialized class representing a particular Reddit user, also
/// known as a Redditor. Can be promoted to a [Redditor].
class RedditorRef extends RedditBase
    with
        BaseListingMixin,
        GildedListingMixin,
        MessageableMixin,
        RedditorListingMixin {
  static final _subredditRegExp = RegExp(r'{subreddit}');
  static final _userRegExp = RegExp(r'{user}');
  static final _usernameRegExp = RegExp(r'{username}');

  /// The Redditor's display name (e.g., spez or XtremeCheese).
  String get displayName => _name;
  String _name;

  /// The Reddit path suffix for this Redditor (e.g., 'user/spez/')
  String get path => _path;
  String _path;

  RedditorRef(Reddit reddit) : super(reddit);

  RedditorRef.name(Reddit reddit, String name)
      : _name = name,
        _path = apiPath['user'].replaceAll(_userRegExp, name),
        super.withPath(reddit, RedditorRef._generateInfoPath(name));

  static String _generateInfoPath(String name) =>
      apiPath['user_about'].replaceAll(_userRegExp, name);

  Future _throwOnInvalidRedditor(Function f) async {
    try {
      return await f();
    } on DRAWNotFoundException catch (_) {
      throw DRAWInvalidRedditorException(displayName);
    }
  }

  /// Adds the [Redditor] as a friend. [note] is an optional string that is
  /// associated with the friend entry. Providing [note] requires Reddit Gold.
  Future<void> friend({String note = ''}) async =>
      _throwOnInvalidRedditor(() async => await reddit.put(
          apiPath['friend_v1'].replaceAll(_userRegExp, _name),
          body: {'note': note}));

  /// Returns a [Redditor] object with friend information populated.
  ///
  /// Friend fields include those such as [note]. Other fields may not be
  /// completely initialized.
  Future<Redditor> friendInfo() async =>
      await _throwOnInvalidRedditor(() async => await reddit
          .get(apiPath['friend_v1'].replaceAll(_userRegExp, _name)));

  /// Gives Reddit Gold to the [Redditor]. [months] is the number of months of
  /// Reddit Gold to be given to the [Redditor].
  ///
  /// Throws a [DRAWGildingError] if the [Redditor] has insufficient gold
  /// creddits.
  Future<void> gild({int months = 1}) async {
    final body = {
      'username': _name,
      'months': months.toString(),
    };
    final path = Uri.https(Reddit.defaultOAuthApiEndpoint,
        apiPath['gild_user'].replaceAll(_usernameRegExp, _name));
    final result = await _throwOnInvalidRedditor(
        () async => await reddit.auth.post(path, body));
    if (result is Map) {
      throw DRAWGildingException(result.cast<String, String>());
    }
  }

  /// Returns a [List] of the [Redditor]'s public [Multireddit]'s.
  Future<List<Multireddit>> multireddits() async =>
      (await _throwOnInvalidRedditor(() async => await reddit
              .get(apiPath['multireddit_user'].replaceAll(_userRegExp, _name))))
          .cast<Multireddit>();

  /// Promotes this [RedditorRef] into a populated [Redditor].
  Future<Redditor> populate() async => (await _throwOnInvalidRedditor(
      () async => Redditor.parse(reddit, await fetch()))) as Redditor;

  // TODO(bkonyi): Add code samples.
  /// Provides a [RedditorStream] for the current [Redditor].
  ///
  /// [RedditorStream] can be used to retrieve new comments and submissions made
  /// by a [Redditor] indefinitely.
  RedditorStream get stream => RedditorStream(this);

  /// Unblock the [Redditor].
  Future<void> unblock() async {
    final currentUser = await reddit.user.me();
    final data = {
      'container': 't2_' + currentUser.data['id'],
      'name': displayName,
      'type': 'enemy',
    };
    await _throwOnInvalidRedditor(() async => await reddit.post(
        apiPath['unfriend'].replaceAll(RedditorRef._subredditRegExp, 'all'),
        data,
        discardResponse: true));
  }

  /// Unfriend the [Redditor].
  Future<void> unfriend() async => await _throwOnInvalidRedditor(() async =>
      await reddit.delete(apiPath['friend_v1'].replaceAll(_userRegExp, _name)));

  /// Returns a list of [Trophy] that this [Redditor] has
  Future<List<Trophy>> trophies() async {
    final response = await reddit.get(
        apiPath['trophies'].replaceAll(RedditorRef._usernameRegExp, _name));
    return List.castFrom<dynamic, Trophy>(response);
  }
}

/// Provides [Comment] and [Submission] streams for a particular [Redditor].
class RedditorStream extends RedditBase {
  final RedditorRef redditor;

  RedditorStream(this.redditor) : super(redditor.reddit);

  /// Returns a [Stream<Comment>] which listens for new comments as they become
  /// available.
  ///
  /// Comments are streamed oldest first, and up to 100 historical comments will
  /// be returned initially. If [limit] is provided, the stream will close after
  /// after [limit] iterations. If [pauseAfter] is provided, null will be
  /// returned after [pauseAfter] requests without new items.
  Stream<Comment> comments({int limit, int pauseAfter}) =>
      streamGenerator(redditor.comments.newest,
          itemLimit: limit, pauseAfter: pauseAfter);

  /// Returns a [Stream<Submissions>] which listens for new submissions as they
  /// become available.
  ///
  /// Submissions are streamed oldest first, and up to 100 historical
  /// submissions will be returned initially. If [limit] is provided,
  /// the stream will close after after [limit] iterations. If [pauseAfter] is
  /// provided, null will be returned after [pauseAfter] requests without new
  /// items.
  Stream<Submission> submissions({int limit, int pauseAfter}) =>
      streamGenerator(redditor.submissions.newest,
          itemLimit: limit, pauseAfter: pauseAfter);
}
