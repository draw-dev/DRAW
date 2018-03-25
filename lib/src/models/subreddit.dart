// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/listing/mixins/gilded.dart';
import 'package:draw/src/listing/mixins/rising.dart';
import 'package:draw/src/listing/mixins/subreddit.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/message.dart';
import 'package:draw/src/models/mixins/messageable.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission.dart';
import 'package:draw/src/models/user_content.dart';

enum _SearchSyntax {
  cloudSearch,
  lucene,
  plain,
}

String _searchSyntaxToString(_SearchSyntax s) {
  switch (s) {
    case _SearchSyntax.cloudSearch:
      return 'cloudsearch';
    case _SearchSyntax.lucene:
      return 'lucene';
    case _SearchSyntax.plain:
      return 'plain';
    default:
      throw new DRAWInternalError('SearchSyntax $s is not supported');
  }
}

/// A lazily initialized class representing a particular Reddit community, also
/// known as a Subreddit. Can be promoted to a [Subreddit] object.
class SubredditRef extends RedditBase
    with
        BaseListingMixin,
        GildedListingMixin,
        MessageableMixin,
        RisingListingMixin,
        SubredditListingMixin {
  static final _subredditRegExp = new RegExp(r'{subreddit}');

  static String _generateInfoPath(String name) => apiPath['subreddit_about']
      .replaceAll(SubredditRef._subredditRegExp, name);

  /// Promotes this [SubredditRef] into a populated [Subreddit].
  Future<Subreddit> populate() async =>
      new Subreddit.parse(reddit, await fetch());

  String get displayName => _name;
  String _name;

  String get path => _path;
  String _path;
  SubredditRelationship _banned;
  ContributorRelationship _contributor;

  SubredditFilters _filters;
  // SubredditFlair _flair; TODO(bkonyi): implement
  SubredditModeration _mod;
  // ModeratorRelationship _moderator; TODO(bkonyi): implement
  // Modmail _modmail; TODO(bkonyi): implement
  SubredditRelationship _muted;

  SubredditQuarantine _quarantine;
  SubredditStream _stream;

  // SubredditStyleSheet _stylesheet; TODO(bkonyi): implement
  // SubredditWiki _wiki; TODO(bkonyi): implement

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
      _filters = new SubredditFilters._(this);
    }
    return _filters;
  }

/*
  SubredditFlair get flair {
    if (_flair == null) {
      _flair = new SubredditFlair(this);
    }
    return _flair;
  }
  */
  SubredditModeration get mod {
    if (_mod == null) {
      _mod = new SubredditModeration._(this);
    }
    return _mod;
  }
/*
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
*/

  SubredditRelationship get muted {
    if (_muted == null) {
      _muted = new SubredditRelationship(this, 'muted');
    }
    return _muted;
  }

  SubredditQuarantine get quarantine {
    if (_quarantine == null) {
      _quarantine = new SubredditQuarantine._(this);
    }
    return _quarantine;
  }

  /*
  SubredditStream get stream {
    if (_stream == null) {
      _stream = new SubredditStream(this);
    }
    return _stream;
  }

// TODO(bkonyi): implement

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
*/

  SubredditRef(Reddit reddit) : super(reddit);

  SubredditRef.name(Reddit reddit, String name)
      : _name = name,
        super.withPath(reddit, _generateInfoPath(name)) {
    _path =
        apiPath['subreddit'].replaceAll(SubredditRef._subredditRegExp, _name);
  }

  bool operator ==(other) {
    return (_name == other._name);
  }

  /// Returns a random submission from the [Subreddit].
  Future<SubmissionRef> random() async {
    try {
      await reddit.get(apiPath['subreddit_random']
          .replaceAll(SubredditRef._subredditRegExp, _name));
    } on DRAWRedirectResponse catch (e) {
      // We expect this request to redirect to our random submission.
      return new SubmissionRef.withPath(reddit, e.path);
    }
    return null; // Shut the analyzer up.
  }

  /// Return the rules for the subreddit.
  Future<List<Rule>> rules() async => reddit
      .get(apiPath['rules'].replaceAll(SubredditRef._subredditRegExp, _name));

  /// Returns a [Stream] of [UserContent] that match [query].
  ///
  /// [query] is the query string to be searched for. [sort] can be one of:
  /// relevance, hot, top, new, comments. [syntax] can be one of: 'cloudsearch',
  /// 'lucene', 'plain'. [timeFilter] can be one of: all, day, hour, month,
  /// week, year.
  Stream<UserContent> search(String query,
      {Sort sort: Sort.relevance,
      _SearchSyntax syntax: _SearchSyntax.lucene,
      TimeFilter timeFilter: TimeFilter.all,
      Map params}) {
    final timeStr = timeFilterToString(timeFilter);
    final isNotAll = !(_name.toLowerCase() == 'all');
    final data = (params != null) ? new Map.from(params) : new Map();
    data['q'] = query;
    data['restrict_sr'] = isNotAll.toString();
    data['sort'] = sortToString(sort);
    data['syntax'] = _searchSyntaxToString(syntax);
    data['t'] = timeStr;
    return ListingGenerator.createBasicGenerator(reddit,
        apiPath['search'].replaceAll(SubredditRef._subredditRegExp, _name),
        params: data);
  }

  /// Return a [SubmissionRef] that has been stickied on the subreddit.
  ///
  /// [number] is used to specify which stickied [Submission] to return, where 1
  /// corresponds to the top sticky, 2 the second, etc.
  Future<SubmissionRef> sticky({int number = 1}) async {
    try {
      await reddit.get(
          apiPath['about_sticky']
              .replaceAll(SubredditRef._subredditRegExp, _name),
          params: {'num': number.toString()});
    } on DRAWRedirectResponse catch (e) {
      return new SubmissionRef.withPath(reddit, e.path);
    }
    return null; // Shut the analyzer up.
  }

  /// Yield [Submission]s created between [start] and [end].
  ///
  /// [start] and [end] indicate the earliest and latest creation times
  /// of submissions to be yielded. [extraQuery] is used to further filter
  /// results.
  Stream<Submission> submissions(
      {DateTime start, DateTime end, String extraQuery}) async* {
    // Calculate the correct time range with respect to PST time.
    const utcOffset = 60 * 60 * 8; // Offset for PST from UTC.
    final currentTime =
        (new DateTime.now().millisecondsSinceEpoch / 1000).round() + utcOffset;
    final startSec = max(
        (start != null)
            ? ((start.millisecondsSinceEpoch / 1000).round() + utcOffset)
            : 0,
        0);
    var endSec = min(
        ((end != null)
            ? (end.millisecondsSinceEpoch / 1000).round() + utcOffset
            : currentTime),
        currentTime);

    var foundNewSubmission = true;
    var lastIds = new Set();
    final params = {};
    while (foundNewSubmission) {
      var query = 'timestamp:$startSec..$endSec';
      if (extraQuery != null) {
        query = '(and $query $extraQuery)';
      }
      final currentIds = new Set();
      foundNewSubmission = false;
      await for (var submission in search(query,
          params: params,
          sort: Sort.newest,
          syntax: _SearchSyntax.cloudSearch)) {
        assert(submission is Submission);
        final submissionCast = submission as Submission;
        final id = submissionCast.id;
        currentIds.add(id);
        endSec = min(endSec, submissionCast.data['created'].round());
        if (!lastIds.contains(id)) {
          foundNewSubmission = true;
        }
        yield submission;
        params['after'] = submissionCast.fullname;
      }
      lastIds = currentIds;
    }
  }

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
    if ((selftext == null && url == null) ||
        (selftext != null && url != null)) {
      throw new DRAWArgumentError('One of either selftext or url must be '
          'provided');
    }

    final data = {
      'api_type': 'json',
      'sr': displayName,
      'resubmit': resubmit.toString(),
      'sendreplies': sendReplies.toString(),
      'title': title,
    };

    if (flairId != null) {
      data['flair_id'] = flairId;
    }

    if (flairText != null) {
      data['flair_text'] = flairText;
    }

    if (selftext != null) {
      data['kind'] = 'self';
      data['text'] = selftext;
    } else {
      data['kind'] = 'link';
      data['url'] = url;
    }
    return reddit.post(apiPath['submit'], data);
  }

  /// Subscribes to the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// subscribed to.
  Future subscribe({List<Subreddit> otherSubreddits}) {
    final data = {
      'action': 'sub',
      'skip_initial_defaults': 'true',
      'sr_name': _subredditList(this, otherSubreddits),
    };
    reddit.post(apiPath['subscribe'], data, discardResponse: true);
    return null; // Shut the analyzer up.
  }

  /// Returns a dictionary of the [Subreddit]'s traffic statistics.
  ///
  /// Raises an error when the traffic statistics aren't available to the
  /// authenticated user (i.e., not a moderator of the subreddit).
  Future<Map> traffic() async => reddit.get(apiPath['about_traffic']
      .replaceAll(SubredditRef._subredditRegExp, _name));

  /// Unsubscribes from the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// unsubscribed from.
  Future unsubscribe({List<Subreddit> otherSubreddits}) async {
    final data = {
      'action': 'unsub',
      'sr_name': _subredditList(this, otherSubreddits),
    };
    await reddit.post(apiPath['subscribe'], data, discardResponse: true);
  }

  static String _subredditList(SubredditRef subreddit,
      [List<SubredditRef> others]) {
    if (others != null) {
      final srs = <String>[];
      srs.add(subreddit.displayName);
      others.forEach((s) {
        srs.add(s.displayName);
      });
      return srs.join(',');
    }
    return subreddit.displayName;
  }
}

/// A class representing a particular Reddit community, also known as a
/// Subreddit.
class Subreddit extends SubredditRef with RedditBaseInitializedMixin {
  /// Whether the currently authenticated Redditor is banned from the [Subreddit].
  bool get isBanned => data['user_is_banned'];

  /// Whether the currently authenticated Redditor is an approved submitter for
  /// the [Subreddit].
  bool get isContributor => data['user_is_contributor'];

  /// The title of the [Subreddit].
  ///
  /// For example, the title of /r/drawapitesting is 'DRAW API Testing'.
  String get title => data['title'];

  Subreddit._(Reddit reddit) : super(reddit);

  Subreddit.parse(Reddit reddit, Map data) : super(reddit) {
    if (!data['data'].containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception.
      throw new DRAWUnimplementedError();
    }
    setData(this, data['data']);
    _name = data['data']['display_name'];
    _path =
        apiPath['subreddit'].replaceAll(SubredditRef._subredditRegExp, _name);
  }
}

/// Provides functions to interact with the special [Subreddit]'s filters.
class SubredditFilters {
  static final RegExp _userRegExp = new RegExp(r'{user}');
  static final RegExp _specialRegExp = new RegExp(r'{special}');
  final SubredditRef _subreddit;

  SubredditFilters._(this._subreddit) {
    if ((_subreddit.displayName != 'all') &&
        (_subreddit.displayName != 'mod')) {
      throw new DRAWArgumentError(
          'Only special Subreddits can be filtered (r/all or r/mod)');
    }
  }

  /// Returns a stream of all filtered subreddits.
  Stream<SubredditRef> call() async* {
    final user = await _subreddit.reddit.user.me();
    final path = apiPath['subreddit_filter_list']
        .replaceAll(_specialRegExp, _subreddit.displayName)
        .replaceAll(_userRegExp, user.displayName);
    final Multireddit response = await _subreddit.reddit.get(path);
    final filteredSubs = response.data['subreddits'];
    for (final sub in filteredSubs) {
      yield _subreddit.reddit.subreddit(sub['name']);
    }
  }

  /// Adds `subreddit` to the list of filtered subreddits.
  ///
  /// Filtered subreddits will no longer be included when requesting listings
  /// from `/r/all`. `subreddit` can be either an instance of [String] or
  /// [SubredditRef].
  Future add(/* String, Subreddit */ subreddit) async {
    var filteredSubreddit = '';
    if (subreddit is String) {
      filteredSubreddit = subreddit;
    } else if (subreddit is SubredditRef) {
      filteredSubreddit = subreddit.displayName;
    } else {
      throw new DRAWArgumentError(
          "Field 'subreddit' must be either a 'String' or 'SubredditRef'");
    }

    final user = await _subreddit.reddit.user.me();
    final path = apiPath['subreddit_filter']
        .replaceAll(SubredditRef._subredditRegExp, filteredSubreddit)
        .replaceAll(_userRegExp, user.displayName)
        .replaceAll(_specialRegExp, _subreddit.displayName);
    await _subreddit.reddit
        .put(path, body: {'model': '{"name" : "$filteredSubreddit"}'});
  }

  /// Removes `subreddit` to the list of filtered subreddits.
  ///
  /// Filtered subreddits will no longer be included when requesting listings
  /// from `/r/all`. `subreddit` can be either an instance of [String] or
  /// [SubredditRef].
  Future remove(/* String, Subreddit */ subreddit) async {
    var filteredSubreddit = '';
    if (subreddit is String)
      filteredSubreddit = subreddit;
    else if (subreddit is SubredditRef)
      filteredSubreddit = subreddit.displayName;
    else
      throw new DRAWArgumentError(
          "Field 'subreddit' must be either a 'String' or 'SubredditRef'");

    final user = await _subreddit.reddit.user.me();
    final path = apiPath['subreddit_filter']
        .replaceAll(SubredditRef._subredditRegExp, filteredSubreddit)
        .replaceAll(_userRegExp, user.displayName)
        .replaceAll(_specialRegExp, _subreddit.displayName);
    await _subreddit.reddit.delete(path);
  }
}

// TODO(bkonyi): implement.
// Provides a set of functions to interact with a [Subreddit]'s flair.
/*class SubredditFlair {
  final Subreddit _subreddit;
  SubredditFlair(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}*/

// TODO(bkonyi): implement.
// Provides functions to interact with a [Subreddit]'s flair templates.
/*class SubredditFlairTemplates {
  final Subreddit _subreddit;
  SubredditFlairTemplates(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}*/

// TODO(bkonyi): implement.
// Provides functions to interact with [Redditor] flair templates.
/*class SubredditRedditorFlairTemplates extends SubredditFlairTemplates {
  SubredditRedditorFlairTemplates(Subreddit subreddit) : super(subreddit);
}*/

// TODO(bkonyi): implement.
// Provides functions to interact with link flair templates.
/*class SubredditLinkFlairTemplates extends SubredditFlairTemplates {
  SubredditLinkFlairTemplates(Subreddit subreddit) : super(subreddit);
}*/

enum SubredditType {
  publicSubreddit,
  privateSubreddit,
}

class SubredditSettings {
  final Map _data;
  final SubredditRef subreddit;

  SubredditSettings.copy(SubredditSettings original)
      : _data = new Map.from(original._data),
        subreddit = original.subreddit;

  SubredditSettings._(this.subreddit, this._data);

  bool get defaultSet => _data['default_set'];
  void set defaultSet(bool x) => _data['default_set'] = x;

  bool get allowImages => _data['allow_images'];
  void set allowImages(bool x) => _data['allow_images'] = x;

  bool get allowFreeformReports => _data['free_form_reports'];
  void set allowFreeformReports(bool x) => _data['free_form_reports'] = x;

  bool get showMedia => _data['show_media'];
  void set showMedia(bool x) => _data['show_media'] = x;

  int get wikiEditAge => _data['wiki_edit_age'];
  void set wikiEditAge(int x) => _data['wiki_edit_age'] = x;

  String get submitText => _data['submit_text'];
  void set submitText(String x) => _data['submit_text'] = x;

  // TODO(bkonyi): figure out what this is.
  // get spamLinks => _data['spam_links'];

  String get title => _data['title'];
  void set title(String x) => _data['title'] = x;

  bool get collapseDeletedComments => _data['collapse_deleted_comments'];
  void set collapseDeletedComments(bool x) =>
      _data['collapse_deleted_comments'] = x;

  // TODO(bkonyi): figure out what this is.
  // get wikimode => _data['wikimode'];

  bool get publicTraffic => _data['public_traffic'];
  void set publicTraffic(bool x) => _data['public_traffic'] = x;

  bool get over18 => _data['over_18'];
  void set over18(bool x) => _data['over_18'] = x;

  bool get allowVideos => _data['allow_videos'];
  void set allowVideos(bool x) => _data['allow_videos'] = x;

  bool get spoilersEnabled => _data['spoilers_enabled'];
  void set spoilersEnabled(bool x) => _data['spoilers_enabled'] = x;

  // TODO(bkonyi): figure out what this is.
  // get suggestedCommentSort => _data['suggested_comment_sort'];

  String get description => _data['description'];
  void set description(String x) => _data['description'] = x;

  String get submitLinkLabel => _data['submit_link_label'];
  void set submitLinkLabel(String x) => _data['submit_link_label'] = x;

  bool get allowPostCrossposts => _data['allow_post_crossposts'];
  void set allowPostCrossposts(bool x) => _data['allow_post_crossposts'] = x;

  // TODO(bkonyi): figure out what this is.
  // get spamComments => _data['spam_comments'];

  // TODO(bkonyi): figure out what this is.
  // get spamSelfposts => _data['spam_selfposts'];

  String get submitTextLabel => _data['submit_text_label'];
  void set submitTextLabel(String x) => _data['submit_text_label'] = x;

  // TODO(bkonyi): we might want to use a color class for this.
  // get keyColor => _data['key_color];

  String get language => _data['language'];
  void set language(String x) => _data['language'] = x;

  int get wikiEditKarma => _data['wiki_edit_karma'];
  void set wikiEditKarma(int x) => _data['wiki_edit_karma'] = x;

  bool get hideAds => _data['hide_ads'];
  void set hideAds(bool x) => _data['hide_ads'] = x;

  String get headerHoverText => _data['header_hover_text'];
  void set headerHoverText(String x) => _data['header_hover_text'] = x;

  bool get allowDiscovery => _data['allow_discovery'];
  void set allowDiscovery(bool x) => _data['allow_discovery'] = x;

  String get publicDescription => _data['public_description'];
  void set publicDescription(String x) => _data['public_description'];

  bool get showMediaPreview => _data['show_media_preview'];
  void set showMediaPreview(bool x) => _data['show_media_preview'] = x;

  int get commentScoreHideMins => _data['comment_score_hide_mins'];
  void set commentScoreHideMins(int x) => _data['comment_score_hide_mins'] = x;

  // TODO(bkonyi): check that there's only two types.
  SubredditType get subredditType {
    if (_data['subreddit_type'] == 'public') {
      return SubredditType.publicSubreddit;
    } else {
      return SubredditType.privateSubreddit;
    }
  }

  void set subredditType(SubredditType type) {
    if (type == SubredditType.publicSubreddit) {
      _data['subreddit_type'] = 'public';
    } else {
      _data['subreddit_type'] = 'private';
    }
  }

  bool get excludeBannedModQueue => _data['exclude_banned_modqueue'];
  void set excludeBannedModQueue(bool x) =>
      _data['exclude_banned_modqueue'] = x;

  // TODO(bkonyi): figure out what this is for.
  // get contentOptions => _data['content_options'];

  String toString() => _data.toString();
}

enum SubredditModerationContentTypeFilter {
  commentsOnly,
  submissionsOnly,
}

// TODO(bkonyi): add accessor methods.
/// Represents an action taken by a moderator.
class ModeratorAction {
  final Map data;
  ModeratorAction(this.data);

  String toString() => data.toString();
}

// TODO(bkonyi): implement.
/// Provides a set of moderation functions to a [Subreddit].
class SubredditModeration {
  static final _subredditRegExp = new RegExp(r'{subreddit}');
  final SubredditRef _subreddit;
  SubredditModeration._(this._subreddit);

  Map _buildOnlyMap(SubredditModerationContentTypeFilter only) {
    final params = {};
    if (only != null) {
      var _only;
      if (only == SubredditModerationContentTypeFilter.submissionsOnly) {
        _only = 'links';
      } else {
        _only = 'comments';
      }
      params['only'] = _only;
    }
    return params;
  }

  Stream _subredditModerationListingGeneratorHelper(
          String api, SubredditModerationContentTypeFilter only, {int limit}) =>
      ListingGenerator.generator(_subreddit.reddit, _formatApiPath(api),
          params: _buildOnlyMap(only), limit: limit);

  String _formatApiPath(String api) =>
      apiPath[api].replaceAll(_subredditRegExp, _subreddit.displayName);

  Future<void> acceptInvite() async {
    final url = apiPath['accept_mod_invite']
        .replaceAll(_subredditRegExp, _subreddit.displayName);
    return _subreddit.reddit.post(url, {});
  }

  Stream<UserContent> edited(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_edited', only,
          limit: limit);

  Stream<Message> inbox({int limit}) =>
      _subredditModerationListingGeneratorHelper('moderator_messages', null,
          limit: limit);

  // TODO(bkonyi): add action type filters.
  Stream<ModeratorAction> log(
      {/* RedditorRef, List<RedditorRef>, String */ mod, int limit}) {
    final params = {};
    if (mod != null) {
      const kMods = 'mod';
      if (mod is RedditorRef) {
        params[kMods] = mod.displayName;
      } else if (mod is List<RedditorRef>) {
        params[kMods] = mod.map((r) => r.displayName).join(',');
      } else if (mod is String) {
        params[kMods] = mod;
      } else {
        throw DRAWArgumentError("Argument type 'mod' must be of 'RedditorRef',"
            " `List<RedditorRef>`, or `String`; got ${mod.runtimeType}.");
      }
    }
    return ListingGenerator.generator(
        _subreddit.reddit, _formatApiPath('about_log'),
        limit: limit, params: params);
  }

  Stream<UserContent> modQueue(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_modqueue', only,
          limit: limit);

  Stream<UserContent> reports(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_reports', only,
          limit: limit);

  Future<SubredditSettings> settings() async {
    final data = (await _subreddit.reddit
        .get(_formatApiPath('subreddit_settings'), objectify: false))['data'];
    return new SubredditSettings._(_subreddit, data);
  }

  Stream<UserContent> spam(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_spam', only,
          limit: limit);

  Stream<UserContent> unmoderated({int limit}) =>
      _subredditModerationListingGeneratorHelper('about_unmoderated', null,
          limit: limit);

  Stream<Message> unread({int limit}) =>
      _subredditModerationListingGeneratorHelper('moderator_unread', null,
          limit: limit);

  Future update(SubredditSettings updated) async {
    if (updated == null) {
      throw new DRAWArgumentError("Field 'updated' cannot be null.");
    }
    final data = new Map.from(updated._data);
    final remap = {
      'allow_top': 'default_set',
      'lang': 'language',
      'link_type': 'content_options'
    };

    // Remap keys to what Reddit expects (this is dumb on their part).
    remap.forEach((k, v) {
      print('$k:$v');
      if (data[v] != null) {
        data[k] = data[v];
        data.remove(v);
      }
    });

    data.forEach((k, v) {
      if (v == null) {
        data[k] = 'null';
      } else {
        data[k] = v.toString();
      }
    });

    return _subreddit.reddit.post(apiPath['site_admin'], data);
  }
}

/// Provides subreddit quarantine related methods.
///
/// When trying to request content from a quarantined subreddit, a
/// `DRAWAuthenticationError` is thrown if the current [User] has not opted in
/// to see content from that subreddit.
class SubredditQuarantine {
  final SubredditRef _subreddit;
  SubredditQuarantine._(this._subreddit);

  /// Opt-in the current [User] to seeing the quarantined [Subreddit].
  Future optIn() async {
    final data = {'sr_name': _subreddit.displayName};
    await _subreddit.reddit
        .post(apiPath['quarantine_opt_in'], data, discardResponse: true);
  }

  /// Opt-out the current [User] to seeing the quarantined [Subreddit].
  ///
  /// When trying to request content from a quarantined subreddit, a
  /// `DRAWAuthenticationError` is thrown if the current [User] has not opted in
  /// to see content from that subreddit.
  Future optOut() async {
    final data = {'sr_name': _subreddit.displayName};
    await _subreddit.reddit
        .post(apiPath['quarantine_opt_out'], data, discardResponse: true);
  }
}

/// Represents a relationship between a [Redditor] and a [Subreddit].
class SubredditRelationship {
  SubredditRef _subreddit;
  final String relationship;

  SubredditRelationship(this._subreddit, this.relationship);

  Stream<Redditor> call({/* String, Redditor */ redditor, Map params}) {
    final data = (params != null) ? new Map.from(params) : null;
    if (redditor != null) {
      data['user'] = _redditorNameHelper(redditor);
    }
    return ListingGenerator.createBasicGenerator(
        _subreddit.reddit,
        apiPath['list_${relationship}']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        params: data);
  }

  // TODO(bkonyi): add field for 'other settings'.
  /// Add a [Redditor] to this relationship.
  ///
  /// `redditor` can be either an instance of [Redditor] or the name of a
  /// Redditor.
  Future add(/* String, Redditor */ redditor) async {
    final data = {
      'name': await _redditorNameHelper(redditor),
      'type': relationship,
    };
    await _subreddit.reddit.post(
        apiPath['friend']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  /// Remove a [Redditor] from this relationship.
  ///
  /// `redditor` can be either an instance of [Redditor] or the name of a
  /// Redditor.
  Future remove(/* String, Redditor */ redditor) async {
    final data = {
      'name': await _redditorNameHelper(redditor),
      'type': relationship,
    };
    await _subreddit.reddit.post(
        apiPath['unfriend']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  Future<String> _redditorNameHelper(/* String, Redditor */ redditor) async {
    if (redditor is Redditor) {
      return redditor.displayName;
    } else if (redditor is! String) {
      throw new DRAWArgumentError('Parameter redditor must be either a'
          'String or Redditor');
    }
    return redditor;
  }
}

/// Contains [Subreddit] traffic information for a specific time slice.
/// [uniques] is the number of unique visitors during the period, [pageviews] is
/// the total number of page views during the period, and [subscriptions] is the
/// total number of new subscriptions during the period. [subscriptions] is only
/// non-zero for time slices the length of one day. All time slices are
/// in UTC time and can be found in [periodStart], with valid slices being
/// either one hour, one day, or one month.
class SubredditTraffic {
  final DateTime periodStart;
  final int pageviews;
  final int subscriptions;
  final int uniques;

  /// Build a map of [List<SubredditTraffic>] given raw traffic response from
  /// the Reddit API.
  ///
  /// This is used by the [Objector] to parse the traffic response, and may be
  /// made internal at some point.
  static Map<String, List<SubredditTraffic>> parseTrafficResponse(
      Map response) {
    return {
      'hour': _generateTrafficList(response['hour']),
      'day': _generateTrafficList(response['day'], isDay: true),
      'month': _generateTrafficList(response['month']),
    };
  }

  static List<SubredditTraffic> _generateTrafficList(List<List<int>> values,
      {bool isDay = false}) {
    final traffic = <SubredditTraffic>[];
    for (final entry in values) {
      traffic.add(new SubredditTraffic(entry));
    }
    return traffic;
  }

  SubredditTraffic(List<int> rawTraffic, {bool isDay = false})
      : pageviews = rawTraffic[2],
        periodStart =
            new DateTime.fromMillisecondsSinceEpoch(rawTraffic[0] * 1000)
                .toUtc(),
        subscriptions = (isDay ? rawTraffic[3] : 0),
        uniques = rawTraffic[1];

  String toString() {
    return '${periodStart
        .toUtc()} => unique visits: $uniques, page views: $pageviews'
        ' subscriptions: $subscriptions';
  }
}

/// Provides methods to interact with a [Subreddit]'s contributors.
///
/// Contributors are also known as approved submitters.
class ContributorRelationship extends SubredditRelationship {
  ContributorRelationship(SubredditRef subreddit, String relationship)
      : super(subreddit, relationship);

  /// Have the current [User] remove themself from the contributors list.
  Future leave() async {
    if (_subreddit is! Subreddit) {
      _subreddit = await _subreddit.populate();
    }
    final data = {
      'id': (_subreddit as Subreddit).fullname,
    };
    await _subreddit.reddit
        .post(apiPath['leavecontributor'], data, discardResponse: true);
  }
}

// TODO(bkonyi): implement.
// Provides methods to interact with a [Subreddit]'s moderators.
/*class ModeratorRelationship extends SubredditRelationship {
  ModeratorRelationship(Subreddit subreddit, String relationship)
      : super(subreddit, relationship) {
    throw new DRAWUnimplementedError();
  }
}*/

// TODO(bkonyi): implement.
// Provides modmail functions for a [Subreddit].
/*class Modmail {
  Subreddit _subreddit;
  Modmail(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}*/

/// A wrapper class for a [Rule] of a [Subreddit].
class Rule {
  bool get isLink => _isLink;

  String get description => _description;

  String get shortName => _shortName;

  String get violationReason => _violationReason;

  double get createdUtc => _createdUtc;

  int get priority => _priority;

  bool _isLink;
  String _description;
  String _shortName;
  String _violationReason;
  double _createdUtc;
  int _priority;

  Rule.parse(Map data) {
    _isLink = (data['kind'] == 'link');
    _description = data['description'];
    _shortName = data['short_name'];
    _violationReason = data['violation_reason'];
    _createdUtc = data['created_utc'];
    _priority = data['priority'];
  }

  String toString() => '$_shortName: $_violationReason';
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
// Provides a set of stylesheet functions to a [Subreddit].
/*class SubredditStyleSheet {
  final Subreddit _subreddit;
  SubredditStyleSheet(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}*/

// TODO(bkonyi): implement
// Provides a set of wiki functions to a [Subreddit].
/*class SubredditWiki {
  final Subreddit _subreddit;
  SubredditWiki(this._subreddit) {
    throw new DRAWUnimplementedError();
  }
}*/
