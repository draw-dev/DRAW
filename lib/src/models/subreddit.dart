// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../api_paths.dart';
import '../base.dart';
import '../exceptions.dart';
import '../listing/listing_generator.dart';
import '../listing/mixins/base.dart';
import '../listing/mixins/gilded.dart';
import '../listing/mixins/rising.dart';
import '../listing/mixins/subreddit.dart';
import '../reddit.dart';
import '../util.dart';
import 'comment.dart';
import 'redditor.dart';
import 'submission.dart';
import 'user_content.dart';
import 'mixins/messageable.dart';

/// A class representing a particular Reddit community, also known as a
/// Subreddit.
class Subreddit extends RedditBase
    with
        BaseListingMixin,
        GildedListingMixin,
        MessageableMixin,
        RisingListingMixin,
        SubredditListingMixin {
  SubredditRelationship _banned;
  ContributorRelationship _contributor;
  SubredditFilters _filters;
  SubredditFlair _flair;
  SubredditModeration _mod;
  ModeratorRelationship _moderator;
  Modmail _modmail;
  SubredditRelationship _muted;
  SubredditQuarantine _quaran;
  SubredditStream _stream;
  SubredditStyleSheet _stylesheet;
  SubredditWiki _wiki;

  String _name;
  String _path;
  static final _subredditRegExp = new RegExp(r'{subreddit}');

  String get displayName => _name;
  String get path => _path;
  int get hashCode => _name.hashCode;

  SubredditRelationship get banned {
    if (_banned == null) {
      _banned = new SubredditRelationship(this, 'banned');
    }
    return _banned;
  }

  ContributorRelationship get contributor {
    if (_contributor == null) {
      _contributor = new ContributorRelationship(this, 'contributor');
    }
    return _contributor;
  }

  SubredditFilters get filters {
    if (_filters == null) {
      _filters = new SubredditFilters(this);
    }
    return _filters;
  }

  SubredditFlair get flair {
    if (_flair == null) {
      _flair = new SubredditFlair(this);
    }
    return _flair;
  }

  SubredditModeration get mod {
    if (_mod == null) {
      _mod = new SubredditModeration(this);
    }
    return _mod;
  }

  ModeratorRelationship get moderator {
    if (_moderator == null) {
      _moderator = new ModeratorRelationship(this, 'moderator');
    }
    return _moderator;
  }

  Modmail get modmail {
    if (_modmail == null) {
      _modmail = new Modmail(this);
    }
    return _modmail;
  }

  SubredditRelationship get muted {
    if (_muted == null) {
      _muted = new SubredditRelationship(this, 'muted');
    }
    return _muted;
  }

  SubredditQuarantine get quaran {
    if (_quaran == null) {
      _quaran = new SubredditQuarantine(this);
    }
    return _quaran;
  }

  SubredditStream get stream {
    if (_stream == null) {
      _stream = new SubredditStream(this);
    }
    return _stream;
  }

  SubredditStyleSheet get stylesheet {
    if (_stylesheet == null) {
      _stylesheet = new SubredditStyleSheet(this);
    }
    return _stylesheet;
  }

  SubredditWiki get wiki {
    if (_wiki == null) {
      _wiki = new SubredditWiki(this);
    }
    return _wiki;
  }

  Subreddit.name(Reddit reddit, String name)
      : _name = name,
        _path = apiPath['subreddit'].replaceAll(_subredditRegExp, name),
        super.withPath(reddit, Subreddit._generateInfoPath(name));

  Subreddit.parse(Reddit reddit, Map data)
      : super.loadData(reddit, data['data']) {
    if (!data['data'].containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception.
      throw new DRAWUnimplementedError();
    }
    _name = data['data']['name'];
    _path = apiPath['subreddit'].replaceAll(_subredditRegExp, _name);
  }

  bool operator ==(other) {
    return (_name == other._name);
  }

  /// Returns a random submission from the [Subreddit].
  Future<Submission> random() async {
    throw new DRAWUnimplementedError();
  }

  /// Return the rules for the subreddit.
  Future<String> rules() async =>
      reddit.get(apiPath['rules'].replaceAll(_subredditRegExp, _name));

  // TODO(bkonyi): implement.
  // TODO(bkonyi): use enums for some of these?
  /// Returns a [Stream] of [UserContent] that match [query].
  ///
  /// [query] is the query string to be searched for. [sort] can be one of:
  /// relevance, hot, top, new, comments. [syntax] can be one of: 'cloudsearch',
  /// 'lucene', 'plain'. [timeFilter] can be one of: all, day, hour, month,
  /// week, year.
  Stream<UserContent> search(String query,
      {String sort: 'relevance',
      String syntax: 'lucene',
      String timeFilter = 'all',
      Map params}) {
    throw new DRAWUnimplementedError();
  }

  // TODO(bkonyi): implement.
  /// Return a [Submission] that has been stickied on the subreddit.
  ///
  /// [number] is used to specify which stickied [Submission] to return, where 1
  /// corresponds to the top sticky, 2 the second, etc.
  Future<Submission> sticky({int number = 1}) {
    throw new DRAWUnimplementedError();
  }

  // TODO(bkonyi): implement.
  /// Yield [Submission]s created between [start] and [end].
  ///
  /// [start] and [end] indicate the earliest and latest creation times
  /// of submissions to be yielded. [extraQuery] is used to further filter
  /// results.
  Stream<Submission> submissions(
      {DateTime start, DateTime end, String extraQuery}) async* {
    throw new DRAWUnimplementedError();
  }

  // TODO(bkonyi): implement.
  /// Creates a [Submission] on the [Subreddit].
  ///
  /// [title] is the title of the submission. [selftext] is markdown formatted
  /// content for a 'text' submission. Using '' will make a title-only
  /// submission. [url] is the URL for a 'link' submission. [flairId] is the
  /// flair template to select. If the template's 'flair_text_editable' value
  /// is true, providing [flairText] will set the custom text. When [resubmit]
  /// is set to false, an error will occur if the URL has already been
  /// submitted. When [sendReplies] is true, messages will be sent to the
  /// submission creator when comments are made on the submission.
  ///
  /// Returns a [Submission] for the newly created submission.
  Future<Submission> submit(String title,
      {String selftext,
      String url,
      String flairId,
      String flairText,
      bool resubmit: true,
      bool sendReplies: true}) async {
    throw new DRAWUnimplementedError();
  }

  // TODO(bkonyi): implement.
  /// Subscribes to the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// subscribed to.
  Future subscribe({List<Subreddit> otherSubreddits}) {
    throw new DRAWUnimplementedError();
  }

  /// Returns a dictionary of the [Subreddit]'s traffic statistics.
  ///
  /// Raises an error when the traffic statistics aren't available to the
  /// authenticated user (i.e., not a moderator of the subreddit).
  Future<Map> traffic() async =>
      reddit.get(apiPath['about_traffic'].replaceAll(_subredditRegExp, _name));

  // TODO(bkonyi): implement.
  /// Unsubscribes from the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// unsubscribed from.
  Future unsubscribe({List<Subreddit> otherSubreddits}) async {
    throw new DRAWUnimplementedError();
  }

  static String _generateInfoPath(String name) =>
      apiPath['subreddit_about'].replaceAll(_subredditRegExp, name);
}

// TODO(bkonyi): implement.
/// Provides functions to interact with the special [Subreddit]'s filters.
class SubredditFilters {
  final Subreddit _subreddit;
  SubredditFilters(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement.
/// Provides a set of functions to interact with a [Subreddit]'s flair.
class SubredditFlair {
  final Subreddit _subreddit;
  SubredditFlair(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement.
/// Provides functions to interact with a [Subreddit]'s flair templates.
class SubredditFlairTemplates {
  final Subreddit _subreddit;
  SubredditFlairTemplates(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement.
/// Provides functions to interact with [Redditor] flair templates.
class SubredditRedditorFlairTemplates extends SubredditFlairTemplates {
  SubredditRedditorFlairTemplates(Subreddit subreddit) : super(subreddit);
}

// TODO(bkonyi): implement.
/// Provides functions to interact with link flair templates.
class SubredditLinkFlairTemplates extends SubredditFlairTemplates {
  SubredditLinkFlairTemplates(Subreddit subreddit) : super(subreddit);
}

// TODO(bkonyi): implement.
/// Provides a set of moderation functions to a [Subreddit].
class SubredditModeration {
  final Subreddit _subreddit;
  SubredditModeration(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement.
/// Provides subreddit quarantine related methods.
class SubredditQuarantine {
  final Subreddit _subreddit;
  SubredditQuarantine(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

/// Represents a relationship between a [Redditor] and a [Subreddit].
class SubredditRelationship {
  static final _subredditRegExp = new RegExp(r'{subreddit}');
  final Subreddit _subreddit;
  final String relationship;

  SubredditRelationship(this._subreddit, this.relationship);

  Stream<Redditor> call({/* String, Redditor */ redditor, Map params}) {
    final data = new Map.from(params);
    data['user'] = _redditorNameHelper(redditor);
    return ListingGenerator.createBasicGenerator(
        _subreddit.reddit,
        apiPath['list_${relationship}']
            .replaceAll(_subredditRegExp, _subreddit.displayName),
        params: data);
  }

  // TODO(bkonyi): add field for 'other settings'.
  Future add(/* String, Redditor */ redditor) async {
    final data = {
      'name': _redditorNameHelper(redditor),
      'type': relationship,
    };
    await _subreddit.reddit.post(
        apiPath['friend'].replaceAll(_subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  Future remove(/* String, Redditor */ redditor) async {
    final data = {
      'name': _redditorNameHelper(redditor),
      'type': relationship,
    };
    await _subreddit.reddit.post(
        apiPath['unfriend']
            .replaceAll(_subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  String _redditorNameHelper(/* String, Redditor */ redditor) {
    if (redditor is Redditor) {
      return redditor.displayName;
    } else if (redditor is! String) {
      // TODO(bkonyi): create DRAWArgumentError.
      throw new DRAWUnimplementedError('Parameter redditor must be either a'
          'String or Redditor');
    }
    return redditor;
  }
}

/// Provides methods to interact with a [Subreddit]'s contributors.
///
/// Contributors are also known as approved submitters.
class ContributorRelationship extends SubredditRelationship {
  ContributorRelationship(Subreddit subreddit, String relationship)
      : super(subreddit, relationship);

  Future leave() async {
    final data = {
      'id': await _subreddit.property('fullname'),
    };
    await _subreddit.reddit
        .post(apiPath['leavecontributor'], data, discardResponse: true);
  }
}

// TODO(bkonyi): implement.
/// Provides methods to interact with a [Subreddit]'s moderators.
class ModeratorRelationship extends SubredditRelationship {
  ModeratorRelationship(Subreddit subreddit, String relationship)
      : super(subreddit, relationship) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement.
/// Provides modmail functions for a [Subreddit].
class Modmail {
  Subreddit _subreddit;
  Modmail(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

/// Provides [Comment] and [Submission] streams for the subreddit.
class SubredditStream {
  final Subreddit _subreddit;

  SubredditStream(this._subreddit);

  /// Yields new [Comment]s as they become available.
  ///
  /// [Comment]s are yielded oldest first. Up to 100 historical comments will
  /// initially be returned. If [pauseAfter] is provided, the stream will return
  /// null after [pauseAfter] iterations.
  Stream<Comment> comments({int pauseAfter}) =>
      streamGenerator(_subreddit.comments, pauseAfter: pauseAfter);

  /// Yields new [Submission]s as they become available.
  ///
  /// [Submission]s are yielded oldest first. Up to 100 historical submissions
  /// will initially be returned. If [pauseAfter] is provided, the stream will
  /// return null after [pauseAfter] iterations.
  Stream<Submission> submissions({int pauseAfter}) =>
      streamGenerator(_subreddit.submissions, pauseAfter: pauseAfter);
}

// TODO(bkonyi): implement
/// Provides a set of stylesheet functions to a [Subreddit].
class SubredditStyleSheet {
  final Subreddit _subreddit;
  SubredditStyleSheet(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}

// TODO(bkonyi): implement
/// Provides a set of wiki functions to a [Subreddit].
class SubredditWiki {
  final Subreddit _subreddit;
  SubredditWiki(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}
