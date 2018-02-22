// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/listing/mixins/gilded.dart';
import 'package:draw/src/listing/mixins/redditor.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/mixins/messageable.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/submission.dart';

/// A class representing a particular Reddit user, also known as a Redditor.
class Redditor extends RedditBase
    with
        BaseListingMixin,
        GildedListingMixin,
        MessageableMixin,
        RedditorListingMixin {
  static final _subredditRegExp = new RegExp(r'{subreddit}');
  static final _userRegExp = new RegExp(r'{user}');

  /// The amount of comment karma earned by the Redditor.
  Future<int> get commentKarma async => await property('commentKarma');

  /// The time the Redditor's account was created.
  Future<int> get created async => await property('created');

  /// The Redditor's display name (e.g., spez or XtremeCheese).
  String get displayName => _name;
  String _name;

  /// The amount of Reddit Gold a Redditor currently has.
  Future<int> get goldCreddits async => await property('goldCreddits');

  /// Whether the current Redditor is a Reddit employee.
  Future<bool> get isEmployee async => await property('isEmployee');

  /// The suspension status of the current Redditor.
  Future<bool> get isSuspended async => await property('isSuspended');

  /// The amount of link karma earned by the Redditor.
  Future<int> get linkKarma async => await property('linkKarma');

  /// The Reddit path suffix for this Redditor (e.g., 'user/spez/')
  String get path => _path;
  String _path;

  /// Whether the Redditor has chosen to filter profanity.
  Future<bool> get preferNoProfanity async => await property('prefNoProfanity');

  Redditor.parse(Reddit reddit, Map data) : super.loadData(reddit, data) {
    if (!data.containsKey('name') &&
        !(data.containsKey('kind') &&
            data['kind'] == Reddit.defaultRedditorKind)) {
      throw new DRAWArgumentError("input argument 'data' is not a valid"
          " representation of a Redditor");
    }
    _name = data['name'];
    _path = apiPath['user'].replaceAll(_userRegExp, _name);
  }

  Redditor.name(Reddit reddit, String name)
      : _name = name,
        _path = apiPath['user'].replaceAll(_userRegExp, name),
        super.withPath(reddit, Redditor._generateInfoPath(name));

  static String _generateInfoPath(String name) =>
      apiPath['user_about'].replaceAll(_userRegExp, name);

  /// Adds the [Redditor] as a friend. [note] is an optional string that is
  /// associated with the friend entry. Providing [note] requires Reddit Gold.
  Future friend({String note = ''}) async =>
      reddit.put(apiPath['friend_v1'].replaceAll(_userRegExp, _name),
          body: JSON.encode({'note': note}));

  // TODO(bkonyi): Do we want to return a new Redditor object or just populate
  // the fields in this object?
  Future<Redditor> friendInfo() async =>
      reddit.get(apiPath['friend_v1'].replaceAll(_userRegExp, _name));

  /// Returns the object's fullname.
  ///
  /// A fullname is an object's kind mapping (i.e., t3), followed by an
  /// underscore and the object's ID (i.e., t1_c5s96e0).
  Future<String> get fullname async => await property('fullname');

  /// Gives Reddit Gold to the [Redditor]. [months] is the number of months of
  /// Reddit Gold to be given to the [Redditor].
  Future gild({int months = 1}) async {
    final body = {
      'months': months.toString(),
    };
    await reddit.post(
        apiPath['gild_user'].replaceAll(_userRegExp, _name), body);
  }

  /// Returns a [List] of the [Redditor]'s public [Multireddit]'s.
  Future<List<Multireddit>> multireddits() async =>
      reddit.get(apiPath['multi_user'].replaceAll(_userRegExp, _name));

  // TODO(bkonyi): Add code samples.
  /// Provides a [RedditorStream] for the current [Redditor].
  ///
  /// [RedditorStream] can be used to retrieve new comments and submissions made
  /// by a [Redditor] indefinitely.
  RedditorStream get stream => new RedditorStream(this);

  /// Unblock the [Redditor].
  Future unblock() async {
    final currentUser = await reddit.user.me();
    final data = {
      'container': 't2_' + await currentUser.property('id'),
      'name': displayName,
      'type': 'enemy',
    };
    await reddit.post(
        apiPath['unfriend'].replaceAll(_subredditRegExp, 'all'), data,
        discardResponse: true);
  }

  /// Unfriend the [Redditor].
  Future unfriend() async =>
      reddit.delete(apiPath['friend_v1'].replaceAll(_userRegExp, _name));
}

/// Provides [Comment] and [Submission] streams for a particular [Redditor].
class RedditorStream extends RedditBase {
  final Redditor redditor;

  RedditorStream(this.redditor) : super(redditor.reddit);

  /// Returns a [Stream<Comment>] which listens for new comments as they become
  /// available.
  ///
  /// Comments are streamed oldest first, and up to 100 historical comments will
  /// be returned initially. [pauseAfter] determines how many comments will be
  /// listened for before returning `null`, allowing for an opportunity to
  /// perform specific actions. If [pauseAfter] is not provided, `null` will not
  /// be received.
  Stream<Comment> comments({int pauseAfter}) =>
      streamGenerator(redditor.comments.newest, pauseAfter: pauseAfter);

  /// Returns a [Stream<Submissions>] which listens for new submissions as they
  /// become available.
  ///
  /// Submissions are streamed oldest first, and up to 100 historical
  /// submissions will be returned initially. [pauseAfter] determines how many
  /// submissions will be listened for before returning `null`, allowing for an
  /// opportunity to perform specific actions. If [pauseAfter] is not provided,
  /// `null` will not be received.
  Stream<Submission> submissions({int pauseAfter}) =>
      streamGenerator(redditor.submissions.newest, pauseAfter: pauseAfter);
}
