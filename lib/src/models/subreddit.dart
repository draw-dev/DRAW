// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/image_file_reader.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/listing/mixins/gilded.dart';
import 'package:draw/src/listing/mixins/rising.dart';
import 'package:draw/src/listing/mixins/subreddit.dart';
import 'package:draw/src/getter_utils.dart';
import 'package:draw/src/modmail.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';
import 'package:draw/src/models/comment.dart';
import 'package:draw/src/models/flair.dart';
import 'package:draw/src/models/mixins/messageable.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/submission.dart';
import 'package:draw/src/models/subreddit_moderation.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/models/wikipage.dart';

enum SearchSyntax {
  cloudSearch,
  lucene,
  plain,
}

String searchSyntaxToString(SearchSyntax s) {
  switch (s) {
    case SearchSyntax.cloudSearch:
      return 'cloudsearch';
    case SearchSyntax.lucene:
      return 'lucene';
    case SearchSyntax.plain:
      return 'plain';
    default:
      throw DRAWInternalError('SearchSyntax $s is not supported');
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
  static final _subredditRegExp = RegExp(r'{subreddit}');

  static String _generateInfoPath(String name) => apiPath['subreddit_about']
      .replaceAll(SubredditRef._subredditRegExp, name);

  Future _throwOnInvalidSubreddit(Function f,
      [bool allowRedirects = true]) async {
    try {
      return await f();
      // ignore: unused_catch_clause
    } on DRAWNotFoundException catch (e) {
      throw DRAWInvalidSubredditException(displayName);
      // ignore: unused_catch_clause
    } on DRAWRedirectResponse catch (e) {
      if (allowRedirects) {
        rethrow;
      }
      throw DRAWInvalidSubredditException(displayName);
    }
  }

  /// Promotes this [SubredditRef] into a populated [Subreddit].
  Future<Subreddit> populate() async => await fetch();

  @override
  Future<dynamic> fetch() async => await _throwOnInvalidSubreddit(
      () async => await reddit.get(infoPath,
          params: infoParams, followRedirects: false),
      false);

  String get displayName => _name;
  String _name;

  String get path => _path;
  String _path;
  SubredditRelationship _banned;
  ContributorRelationship _contributor;

  SubredditFilters _filters;
  SubredditFlair _flair;
  SubredditModeration _mod;
  ModeratorRelationship _moderator;
  Modmail _modmail;
  SubredditRelationship _muted;

  SubredditQuarantine _quarantine;
  SubredditStream _stream;

  SubredditStyleSheet _stylesheet;
  SubredditWiki _wiki;

  int get hashCode => _name.hashCode;

  SubredditRelationship get banned {
    _banned ??= SubredditRelationship(this, 'banned');
    return _banned;
  }

  ContributorRelationship get contributor {
    _contributor ??= ContributorRelationship(this, 'contributor');
    return _contributor;
  }

  SubredditFilters get filters {
    _filters ??= SubredditFilters._(this);
    return _filters;
  }

  SubredditFlair get flair {
    if (_flair == null) {
      _flair = SubredditFlair(this);
    }
    return _flair;
  }

  SubredditModeration get mod {
    _mod ??= SubredditModeration(this);
    return _mod;
  }

  ModeratorRelationship get moderator {
    _moderator ??= ModeratorRelationship(this, 'moderator');
    return _moderator;
  }

  Modmail get modmail {
    if (_modmail == null) {
      _modmail = Modmail._(this);
    }
    return _modmail;
  }

  SubredditRelationship get muted {
    _muted ??= SubredditRelationship(this, 'muted');
    return _muted;
  }

  SubredditQuarantine get quarantine {
    _quarantine ??= SubredditQuarantine._(this);
    return _quarantine;
  }

  SubredditStream get stream {
    _stream ??= SubredditStream(this);
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
      _wiki = SubredditWiki(this);
    }
    return _wiki;
  }

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
      await _throwOnInvalidSubreddit(() async => await reddit.get(
          apiPath['subreddit_random']
              .replaceAll(SubredditRef._subredditRegExp, _name)));
    } on DRAWRedirectResponse catch (e) {
      // We expect this request to redirect to our random submission.
      return SubmissionRef.withPath(reddit, e.path);
    }
    return null; // Shut the analyzer up.
  }

  /// Return the rules for the subreddit.
  Future<List<Rule>> rules() async => (await _throwOnInvalidSubreddit(
          () async => await reddit.get(apiPath['rules']
              .replaceAll(SubredditRef._subredditRegExp, _name))))
      .cast<Rule>();

  /// Returns a [Stream] of [UserContent] that match [query].
  ///
  /// [query] is the query string to be searched for. [sort] can be one of:
  /// relevance, hot, top, new, comments. [syntax] can be one of: 'cloudsearch',
  /// 'lucene', 'plain'. [timeFilter] can be one of: all, day, hour, month,
  /// week, year.
  Stream<UserContent> search(String query,
      {Sort sort = Sort.relevance,
      SearchSyntax syntax = SearchSyntax.lucene,
      TimeFilter timeFilter = TimeFilter.all,
      Map<String, String> params}) {
    final timeStr = timeFilterToString(timeFilter);
    final isNotAll = !(_name.toLowerCase() == 'all');
    final data = (params != null)
        ? Map<String, String>.from(params)
        : <String, String>{};
    data['q'] = query;
    data['restrict_sr'] = isNotAll.toString();
    data['sort'] = sortToString(sort);
    data['syntax'] = searchSyntaxToString(syntax);
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
      await _throwOnInvalidSubreddit(() async => await reddit.get(
          apiPath['about_sticky']
              .replaceAll(SubredditRef._subredditRegExp, _name),
          params: {'num': number.toString()}));
    } on DRAWRedirectResponse catch (e) {
      return SubmissionRef.withPath(reddit, e.path);
    }
    return null; // Shut the analyzer up.
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
      bool resubmit = true,
      bool sendReplies = true,
      bool nsfw = false,
      bool spoiler = false}) async {
    if ((selftext == null && url == null) ||
        (selftext != null && url != null)) {
      throw DRAWArgumentError('One of either selftext or url must be '
          'provided');
    }

    final data = {
      'api_type': 'json',
      'sr': displayName,
      'resubmit': resubmit.toString(),
      'sendreplies': sendReplies.toString(),
      'title': title,
      'nsfw': nsfw.toString(),
      'spoiler': spoiler.toString(),
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
    return await _throwOnInvalidSubreddit(
        () async => await reddit.post(apiPath['submit'], data)) as Submission;
  }

  /// Subscribes to the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// subscribed to.
  Future<void> subscribe({List<SubredditRef> otherSubreddits}) async {
    final data = {
      'action': 'sub',
      'skip_initial_defaults': 'true',
      'sr_name': _subredditList(this, otherSubreddits),
    };
    await _throwOnInvalidSubreddit(() async =>
        await reddit.post(apiPath['subscribe'], data, discardResponse: true));
  }

  /// Returns a dictionary of the [Subreddit]'s traffic statistics.
  ///
  /// Raises an error when the traffic statistics aren't available to the
  /// authenticated user (i.e., not a moderator of the subreddit).
  Future<Map> traffic() async => await _throwOnInvalidSubreddit(() async =>
      await reddit.get(apiPath['about_traffic']
          .replaceAll(SubredditRef._subredditRegExp, _name))) as Map;

  /// Unsubscribes from the subreddit.
  ///
  /// When [otherSubreddits] is provided, the provided subreddits will also be
  /// unsubscribed from.
  Future<void> unsubscribe({List<SubredditRef> otherSubreddits}) async {
    final data = {
      'action': 'unsub',
      'sr_name': _subredditList(this, otherSubreddits),
    };
    await _throwOnInvalidSubreddit(() async =>
        await reddit.post(apiPath['subscribe'], data, discardResponse: true));
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
  /// The URL for the [Subreddit]'s header image, if it exists.
  Uri get headerImage => GetterUtils.uriOrNull(data['header_img']);

  /// The URL for the [Subreddit]'s icon, if it exists.
  Uri get iconImage => GetterUtils.uriOrNull(data['icon_img']);

  /// Whether the currently authenticated Redditor is banned from the [Subreddit].
  bool get isBanned => data['user_is_banned'];

  /// Whether the currently authenticated Redditor is an approved submitter for
  /// the [Subreddit].
  bool get isContributor => data['user_is_contributor'];

  /// The URL for the [Subreddit]'s mobile header image, if it exists.
  Uri get mobileHeaderImage => GetterUtils.uriOrNull(data['banner_img']);

  /// Is the [Subreddit] restricted to users 18+.
  bool get over18 => data['over18'];

  /// The title of the [Subreddit].
  ///
  /// For example, the title of /r/drawapitesting is 'DRAW API Testing'.
  String get title => data['title'];

  Subreddit._(Reddit reddit) : super(reddit);

  @override
  Future<dynamic> refresh() async {
    final refreshed = await populate();
    setData(this, refreshed.data);
    return this;
  }

  Subreddit._fromSubreddit(Subreddit subreddit) : super(subreddit.reddit) {
    setData(this, subreddit.data);
    _name = subreddit._name;
    _path =
        apiPath['subreddit'].replaceAll(SubredditRef._subredditRegExp, _name);
  }

  Subreddit.parse(Reddit reddit, Map data)
      // TODO(bkonyi): fix info path not being set properly for Subreddit.
      : super.name(reddit, data['data']['display_name']) {
    if (!data['data'].containsKey('name')) {
      // TODO(bkonyi) throw invalid object exception.
      throw DRAWUnimplementedError();
    }
    setData(this, data['data']);
    _name = data['data']['display_name'];
    _path =
        apiPath['subreddit'].replaceAll(SubredditRef._subredditRegExp, _name);
  }
}

/// Provides functions to interact with the special [Subreddit]'s filters.
class SubredditFilters {
  static final RegExp _userRegExp = RegExp(r'{user}');
  static final RegExp _specialRegExp = RegExp(r'{special}');
  final SubredditRef _subreddit;

  SubredditFilters._(this._subreddit) {
    if ((_subreddit.displayName != 'all') &&
        (_subreddit.displayName != 'mod')) {
      throw DRAWArgumentError(
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
  Future<void> add(/* String, Subreddit */ subreddit) async {
    var filteredSubreddit = '';
    if (subreddit is String) {
      filteredSubreddit = subreddit;
    } else if (subreddit is SubredditRef) {
      filteredSubreddit = subreddit.displayName;
    } else {
      throw DRAWArgumentError(
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
  Future<void> remove(/* String, Subreddit */ subreddit) async {
    var filteredSubreddit = '';
    if (subreddit is String) {
      filteredSubreddit = subreddit;
    } else if (subreddit is SubredditRef) {
      filteredSubreddit = subreddit.displayName;
    } else {
      throw DRAWArgumentError(
          "Field 'subreddit' must be either a 'String' or 'SubredditRef'");
    }

    final user = await _subreddit.reddit.user.me();
    final path = apiPath['subreddit_filter']
        .replaceAll(SubredditRef._subredditRegExp, filteredSubreddit)
        .replaceAll(_userRegExp, user.displayName)
        .replaceAll(_specialRegExp, _subreddit.displayName);
    await _subreddit.reddit.delete(path);
  }
}

/// Provides a set of functions to interact with a [Subreddit]'s flair.
class SubredditFlair {
  static final RegExp _kSubredditRegExp = RegExp(r'{subreddit}');
  final SubredditRef _subreddit;
  SubredditRedditorFlairTemplates _templates;
  SubredditLinkFlairTemplates _linkTemplates;

  SubredditFlair(this._subreddit);

  SubredditRedditorFlairTemplates get templates {
    _templates ??= SubredditRedditorFlairTemplates._(_subreddit);
    return _templates;
  }

  SubredditLinkFlairTemplates get linkTemplates {
    _linkTemplates ??= SubredditLinkFlairTemplates._(_subreddit);
    return _linkTemplates;
  }

  Stream<Flair> call(
      {/* Redditor, String */ redditor, Map<String, String> params}) {
    final data = (params != null) ? Map.from(params) : null;
    if (redditor != null) {
      data['user'] = _redditorNameHelper(redditor);
    }
    return ListingGenerator.createBasicGenerator(
        _subreddit.reddit,
        apiPath['flairlist']
            .replaceAll(_kSubredditRegExp, _subreddit.displayName),
        params: data);
  }

  /// Update the [Subreddit]'s flair configuration.
  ///
  /// `position` specifies where flair is displayed relative to the
  /// name of the Redditor. `FlairPosition.disabled` will hide flair.
  ///
  /// `selfAssign` specifies whether or not a Redditor can set their own flair.
  ///
  /// `linkPosition' specifies where flair is displayed relative to a
  /// submission link. `FlairPosition.disabled` will hide flair for links.
  ///
  /// 'linkSelfAssign' specifies whether or not a Redditor can set flair on
  /// their links.
  Future<void> configure(
      {FlairPosition position = FlairPosition.right,
      bool selfAssign = false,
      FlairPosition linkPosition = FlairPosition.left,
      bool linkSelfAssign = false}) {
    final disabledPosition = (position == FlairPosition.disabled);
    final disabledLinkPosition = (linkPosition == FlairPosition.disabled);
    final data = <String, String>{
      'api_type': 'json',
      'flair_enabled': disabledPosition.toString(),
      'flair_position': flairPositionToString(position),
      'flair_self_assign_enabled': selfAssign.toString(),
      'link_flair_position':
          disabledLinkPosition ? '' : flairPositionToString(linkPosition),
      'link_flair_self_assign_enabled': linkSelfAssign.toString(),
    };
    return _subreddit.reddit.post(
        apiPath['flairtemplate']
            .replaceAll(_kSubredditRegExp, _subreddit.displayName),
        data);
  }

  /// Deletes flair for a Redditor.
  ///
  /// `redditor` can be either a [String] representing the Redditor's name or
  /// an instance of [Redditor].
  Future<void> delete(/* Redditor, String */ redditor) {
    final redditorName = _redditorNameHelper(redditor);
    return _subreddit.reddit.post(
        apiPath['deleteflair']
            .replaceAll(_kSubredditRegExp, _subreddit.displayName),
        <String, String>{'api_type': 'json', 'name': redditorName});
  }

  /// Deletes all Redditor flair in the [Subreddit].
  ///
  /// Returns [Future<List<Map>>] containing the success or failure of each
  /// delete.
  Future<List<Map>> deleteAll() async {
    final updates = <Flair>[];
    await for (final f in call()) {
      updates.add(Flair(f.user));
    }
    return update(updates);
  }

  /// Sets the flair for a [Redditor].
  ///
  /// `redditor` can be either a [String] representing the Redditor's name or
  /// an instance of [Redditor]. Must not be null.
  ///
  /// `text` is the flair text to associate with the Redditor.
  ///
  /// `cssClass` is the CSS class to apply to the flair.
  Future<void> setFlair(/* Redditor, String */ redditor,
      {String text = '', String cssClass = ''}) {
    final redditorName = _redditorNameHelper(redditor);
    final data = <String, String>{
      'api_type': 'json',
      'css_class': cssClass,
      'name': redditorName,
      'text': text,
    };
    return _subreddit.reddit.post(
        apiPath['flair'].replaceAll(_kSubredditRegExp, _subreddit.displayName),
        data);
  }

  /// Set or clear the flair of multiple Redditors at once.
  ///
  /// `flairList` can be one of:
  ///     * [List<String>] of Redditor names
  ///     * [List<RedditorRef>]
  ///     * [List<Flair>]
  ///
  /// `text` is the flair text to use when `flair_text` is missing or
  /// `flairList` is not a list of mappings.
  ///
  /// `cssClass` is the CSS class to use when `flair_css_class` is missing or
  /// `flairList` is not a list of mappings.
  ///
  /// Returns [Future<List<Map<String, String>>>] containing the success or
  /// failure of each update.
  Future<List<Map<String, dynamic>>> update(
      /* List<String>,
         List<RedditorRef>,
         List<Flair> */
      flairList,
      {String text = '',
      String cssClass = ''}) async {
    if ((flairList is! List<String>) &&
            (flairList is! List<RedditorRef>) &&
            (flairList is! List<Flair>) ||
        (flairList == null)) {
      throw DRAWArgumentError('flairList must be one of List<String>,'
          ' List<Redditor>, or List<Map<String,String>>.');
    }
    var lines = <String>[];
    for (final f in flairList) {
      if (f is String) {
        lines.add('"$f","$text","$cssClass"');
      } else if (f is RedditorRef) {
        lines.add('"${f.displayName}","$text","$cssClass"');
      } else if (f is Flair) {
        final name = f.user.displayName;
        final tmpText = f.flairText ?? text;
        final tmpCssClass = f.flairCssClass ?? cssClass;
        if (name == null) {
          continue;
        }
        lines.add('"$name","$tmpText","$tmpCssClass"');
      } else {
        throw DRAWInternalError('Invalid flair format');
      }
    }
    final response = <Map<String, dynamic>>[];
    final url = apiPath['flaircsv']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    while (lines.isNotEmpty) {
      final batch = lines.sublist(0, min(100, lines.length));
      final data = <String, String>{
        'flair_csv': batch.join('\n'),
      };
      final List<Map<String, dynamic>> maps =
          (await _subreddit.reddit.post(url, data))
              .cast<Map<String, dynamic>>();
      response.addAll(maps);
      if (lines.length < 100) {
        break;
      }
      lines = lines.sublist(min(lines.length - 1, 100));
    }
    return response;
  }
}

/// Provides functions to interact with a [Subreddit]'s flair templates.
class SubredditFlairTemplates {
  static final RegExp _kSubredditRegExp = RegExp(r'{subreddit}');
  final SubredditRef _subreddit;
  SubredditFlairTemplates._(this._subreddit);

  static String _flairType(bool isLink) => isLink ? 'LINK_FLAIR' : 'USER_FLAIR';

  Future<void> _add(
      String text, String cssClass, bool textEditable, bool isLink) async {
    final url = apiPath['flairtemplate']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    final data = <String, String>{
      'api_type': 'json',
      'css_class': cssClass,
      'flair_type': _flairType(isLink),
      'text': text,
      'text_editable': textEditable.toString(),
    };
    await _subreddit.reddit.post(url, data);
  }

  Future<void> _clear(bool isLink) async {
    final url = apiPath['flairtemplateclear']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    await _subreddit.reddit.post(url,
        <String, String>{'api_type': 'json', 'flair_type': _flairType(isLink)});
  }

  Future<void> delete(String templateId) async {
    final url = apiPath['flairtemplatedelete']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    await _subreddit.reddit.post(url,
        <String, String>{'api_type': 'json', 'flair_template_id': templateId});
  }

  Future<void> update(String templateId, String text,
      {String cssClass = '', bool textEditable = false}) async {
    final url = apiPath['flairtemplate']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    final data = <String, String>{
      'api_type': 'json',
      'css_class': cssClass,
      'flair_template_id': templateId,
      'text': text,
      'text_editable': textEditable.toString(),
    };
    await _subreddit.reddit.post(url, data);
  }
}

/// Provides functions to interact with [Redditor] flair templates.
class SubredditRedditorFlairTemplates extends SubredditFlairTemplates {
  SubredditRedditorFlairTemplates._(SubredditRef subreddit)
      : super._(subreddit);

  /// A [Stream] of the subreddit's Redditor flair templates.
  Stream<FlairTemplate> call() async* {
    final url = apiPath['flairselector'].replaceAll(
        SubredditFlairTemplates._kSubredditRegExp, _subreddit.displayName);
    final data = <String, String>{};
    final result = (await _subreddit.reddit.post(url, data))['choices'];
    for (final r in result) {
      yield FlairTemplate.parse(r.cast<String, dynamic>());
    }
  }

  /// Add a Redditor flair template to the subreddit.
  ///
  /// `text` is the template's text, `cssClass` is the template's CSS class,
  /// and `textEditable` specifies if flair text can be edited for each editor.
  Future<void> add(String text,
          {String cssClass = '', bool textEditable = false}) async =>
      _add(text, cssClass, textEditable, false);

  /// Remove all Redditor flair templates from the subreddit.
  Future<void> clear() async => _clear(false);
}

/// Provides functions to interact with link flair templates.
class SubredditLinkFlairTemplates extends SubredditFlairTemplates {
  SubredditLinkFlairTemplates._(SubredditRef subreddit) : super._(subreddit);

  /// A [Stream] of the subreddit's link flair templates.
  Stream<FlairTemplate> call() async* {
    final url = apiPath['link_flair'].replaceAll(
        SubredditFlairTemplates._kSubredditRegExp, _subreddit.displayName);
    final result = (await _subreddit.reddit.get(url, objectify: false));
    for (final r in result) {
      r['flair_template_id'] = r['id'];
      yield FlairTemplate.parse(r.cast<String, dynamic>());
    }
  }

  /// Add a link flair template to the subreddit.
  ///
  /// `text` is the template's text, `cssClass` is the template's CSS class,
  /// and `textEditable` specifies if flair text can be edited for each editor.
  Future<void> add(String text,
          {String cssClass = '', bool textEditable = false}) async =>
      _add(text, cssClass, textEditable, true);

  /// Remove all link flair templates from the subreddit.
  Future<void> clear() async => _clear(true);
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
  Future<void> optIn() async {
    final data = {'sr_name': _subreddit.displayName};
    await _subreddit.reddit
        .post(apiPath['quarantine_opt_in'], data, discardResponse: true);
  }

  /// Opt-out the current [User] to seeing the quarantined [Subreddit].
  ///
  /// When trying to request content from a quarantined subreddit, a
  /// `DRAWAuthenticationError` is thrown if the current [User] has not opted in
  /// to see content from that subreddit.
  Future<void> optOut() async {
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

  Stream<Redditor> call(
      {/* String, Redditor */ redditor, Map<String, String> params}) {
    final data = (params != null) ? Map.from(params) : <String, String>{};
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
  Future<void> add(/* String, Redditor */ redditor,
      {Map<String, String> params}) async {
    final data = {
      'name': _redditorNameHelper(redditor),
      'type': relationship,
    };
    if (params != null) {
      data.addAll(params);
    }
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
  Future<void> remove(/* String, Redditor */ redditor,
      {Map<String, String> params}) async {
    final data = {
      'name': _redditorNameHelper(redditor),
      'type': relationship,
    };
    if (params != null) {
      data.addAll(params);
    }
    await _subreddit.reddit.post(
        apiPath['unfriend']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }
}

String _redditorNameHelper(/* String, RedditorRef */ redditor) {
  if (redditor is RedditorRef) {
    return redditor.displayName;
  } else if (redditor is! String) {
    throw DRAWArgumentError('Parameter redditor must be either a'
        'String or Redditor');
  }
  return redditor;
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
    return <String, List<SubredditTraffic>>{
      'hour': _generateTrafficList(response['hour']),
      'day': _generateTrafficList(response['day'], isDay: true),
      'month': _generateTrafficList(response['month']),
    };
  }

  static List<SubredditTraffic> _generateTrafficList(List values,
      {bool isDay = false}) {
    final traffic = <SubredditTraffic>[];
    for (final entry in values) {
      traffic.add(SubredditTraffic(entry.cast<int>()));
    }
    return traffic;
  }

  SubredditTraffic(List<int> rawTraffic, {bool isDay = false})
      : pageviews = rawTraffic[2],
        periodStart =
            DateTime.fromMillisecondsSinceEpoch(rawTraffic[0] * 1000).toUtc(),
        subscriptions = (isDay ? rawTraffic[3] : 0),
        uniques = rawTraffic[1];

  String toString() {
    return '${periodStart.toUtc()} => unique visits: $uniques, page views: $pageviews'
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
  Future<void> leave() async {
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

enum ModeratorPermission {
  all,
  access,
  config,
  flair,
  mail,
  posts,
  wiki,
}

/// Provides methods to interact with a [Subreddit]'s moderators.
class ModeratorRelationship extends SubredditRelationship {
  ModeratorRelationship(SubredditRef subreddit, String relationship)
      : super(subreddit, relationship);

  final _validPermissions =
      ['access', 'config', 'flair', 'mail', 'posts', 'wiki'].toSet();

  Map<String, String> _handlePermissions(
          List<ModeratorPermission> permissions) =>
      <String, String>{
        'permissions': permissionsString(
            moderatorPermissionsToStrings(permissions), _validPermissions),
      };

  /// Returns a [Stream] of [Redditor]s who are moderators.
  ///
  /// When `redditor` is provided, the resulting stream will contain at most
  /// one [Redditor]. This is useful to confirm if a relationship exists, or to
  /// fetch the metadata associated with a particular relationship.
  Stream<Redditor> call(
          {/* String, RedditorRef */ redditor, Map<String, String> params}) =>
      super.call(redditor: redditor, params: params);

  /// Add or invite `redditor` to be a moderator of the subreddit.
  ///
  /// If `permissions` is not provided, the `+all` permission will be used.
  /// Otherwise, `permissions` should specify the subset of permissions
  /// to grant. If the empty list is provided, no permissions are granted
  /// (default).
  ///
  /// An invite will be sent unless the user making this call is an admin.
  Future<void> add(/* RedditorRef, String */ redditor,
      {List<ModeratorPermission> permissions = const <ModeratorPermission>[],
      Map<String, String> params}) async {
    final data = _handlePermissions(permissions);
    if (params != null) {
      data.addAll(params);
    }
    await super.add(
      redditor,
      params: data,
    );
  }

  /// Invite `redditor` to be a moderator of this subreddit.
  ///   /// `redditor` is either a [RedditorRef] or username.
  /// If `permissions` is not provided, the `+all` permission will be used.
  /// Otherwise, `permissions` should specify the subset of permissions
  /// to grant. If the empty list is provided, no permissions are granted
  /// (default).
  Future<void> invite(/* RedditorRef, String */ redditor,
      {List<ModeratorPermission> permissions =
          const <ModeratorPermission>[]}) async {
    final data = <String, String>{
      'name': _redditorNameHelper(redditor),
      'type': 'moderator_invite',
      'api_type': 'json',
    };
    data.addAll(_handlePermissions(permissions));
    return await _subreddit.reddit.post(
        apiPath['friend']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        data);
  }

  /// Remove the currently authenticated user as moderator.
  Future<void> leave() async {
    String fullname;
    if (_subreddit is Subreddit) {
      fullname = (_subreddit as Subreddit).fullname;
    } else {
      fullname = (await _subreddit.populate()).fullname;
    }
    await _subreddit.reddit.post(
        apiPath['leavemoderator'], <String, String>{'id': fullname},
        discardResponse: true);
  }

  /// Remove the moderator invite for `redditor`.
  ///
  /// `redditor` is either a [RedditorRef] or username of the user whose invite
  /// is to be removed.
  Future<void> removeInvite(/* RedditorRef, String */ redditor) async {
    final data = <String, String>{
      'name': _redditorNameHelper(redditor),
      'type': 'moderator_invite',
      'api_type': 'json',
    };
    return await _subreddit.reddit.post(
        apiPath['unfriend']
            .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  /// Updated the moderator permissions for `redditor`.
  ///
  /// `redditor` is either a [RedditorRef] or username.
  /// If `permissions` is not provided, the `+all` permission will be used.
  /// Otherwise, `permissions` should specify the subset of permissions
  /// to grant. If the empty list is provided, no permissions are granted
  /// (default).
  Future<void> update(/* RedditorRef, String */ redditor,
      {List<ModeratorPermission> permissions =
          const <ModeratorPermission>[]}) async {
    final request = apiPath['setpermissions']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    final data = <String, String>{
      'name': _redditorNameHelper(redditor),
      'type': 'moderator',
    };
    data.addAll(_handlePermissions(permissions));
    return await _subreddit.reddit.post(request, data);
  }

  /// Update the moderator invite for `redditor`.
  ///
  /// `redditor` is either a [RedditorRef] or username.
  /// If `permissions` is not provided, the `+all` permission will be used.
  /// Otherwise, `permissions` should specify the subset of permissions
  /// to grant. If the empty list is provided, no permissions are granted
  /// (default).
  Future<void> updateInvite(/* RedditorRef, String */ redditor,
      {List<ModeratorPermission> permissions =
          const <ModeratorPermission>[]}) async {
    final request = apiPath['setpermissions']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    final data = <String, String>{
      'name': _redditorNameHelper(redditor),
      'type': 'moderator_invite',
      'api_type': 'json',
    };
    data.addAll(_handlePermissions(permissions));
    return await _subreddit.reddit.post(request, data);
  }
}

enum ModmailState {
  all,
  archived,
  highlighted,
  inprogress,
  mod,
  newmail,
  notifications,
}

String modmailStateToString(ModmailState s) {
  switch (s) {
    case ModmailState.all:
      return 'all';
    case ModmailState.archived:
      return 'archived';
    case ModmailState.highlighted:
      return 'highlighted';
    case ModmailState.inprogress:
      return 'inprogress';
    case ModmailState.mod:
      return 'mod';
    case ModmailState.newmail:
      return 'new';
    case ModmailState.notifications:
      return 'notifications';
    default:
      throw DRAWInternalError('$s is not a valid ModmailSort value.');
  }
}

enum ModmailSort {
  mod,
  recent,
  unread,
  user,
}

String modmailSortToString(ModmailSort s) {
  switch (s) {
    case ModmailSort.mod:
      return 'mod';
    case ModmailSort.recent:
      return 'recent';
    case ModmailSort.unread:
      return 'unread';
    case ModmailSort.user:
      return 'user';
    default:
      throw DRAWInternalError('$s is not a valid ModmailSort value.');
  }
}

/// Provides modmail functions for a [Subreddit].
class Modmail {
  final SubredditRef _subreddit;
  Modmail._(this._subreddit);

  String _buildSubredditList(List<SubredditRef> otherSubreddits) {
    final subreddits = <SubredditRef>[_subreddit];
    if (otherSubreddits != null) {
      subreddits.addAll(otherSubreddits);
    }
    return subreddits.map((c) => c.displayName).join(',');
  }

  ModmailConversationRef call(String id, {bool markRead = false}) =>
      ModmailConversationRef(_subreddit.reddit, id, markRead: markRead);

  /// Mark the conversations for provided subreddits as read.
  ///
  /// `otherSubreddits`: if provided, all messages in the listed subreddits
  /// will also be marked as read.
  ///
  /// `state`: can be one of all, archived, highlighted, inprogress,
  /// mod, new, notifications, (default: all). "all" does not include
  /// internal or archived conversations.
  ///
  /// Returns a [List] of [ModmailConversation] instances which were marked as
  /// read.
  Future<List<ModmailConversationRef>> bulkRead(
      {List<SubredditRef> otherSubreddits,
      ModmailState state = ModmailState.all}) async {
    final params = {
      'entity': _buildSubredditList(otherSubreddits),
      'state': modmailStateToString(state),
    };
    final response = await _subreddit.reddit
        .post(apiPath['modmail_bulk_read'], params, objectify: false);
    final ids = response['conversation_ids'] as List;
    return ids.map<ModmailConversationRef>((id) => this(id)).toList();
  }

  /// A [Stream] of [ModmailConversation] instances for the specified
  /// subreddits.
  ///
  /// `after`: A base36 modmail conversation id. When provided, the limiting
  /// begins after this conversation.
  /// `limit`: The maximum number of conversations to fetch. If not provided,
  /// the server-side default is 25 at the time of writing.
  /// `otherSubreddits`: A list of other subreddits for which conversations
  /// should be fetched.
  /// `sort`: Determines the order that the conversations will be sorted.
  /// `state`:
  Stream<ModmailConversation> conversations(
      {String after,
      int limit,
      List<SubredditRef> otherSubreddits,
      ModmailSort sort = ModmailSort.recent,
      ModmailState state = ModmailState.all}) async* {
    final params = <String, String>{};
    if (_subreddit.displayName != 'all') {
      params['entity'] = _buildSubredditList(otherSubreddits);
    }

    if (after != null) {
      params['after'] = after;
    }

    if (limit != null) {
      params['limit'] = limit.toString();
    }

    if (sort != null) {
      params['sort'] = modmailSortToString(sort);
    }

    if (state != null) {
      params['state'] = modmailStateToString(state);
    }

    final Map<String, dynamic> response = await _subreddit.reddit
        .get(apiPath['modmail_conversations'], params: params);
    final ids = (response['conversationIds'] as List).cast<String>();
    for (final id in ids) {
      final data = {
        'conversation': response['conversations'][id],
        'messages': response['messages']
      };
      yield ModmailConversation.parse(_subreddit.reddit, data,
          convertObjects: true);
    }
  }

  /// Create a new conversation.
  ///
  /// `subject`: The message subject.
  /// `body`: The markdown formatted body of the message.
  /// `recipient`: The recipient of the conversation. Can be either a [String] or
  /// a [RedditorRef].
  /// `authorHidden`: When true, the author is hidden from non-moderators. This
  /// is the same as replying as a subreddit.
  ///
  /// Returns a [ModmailConversation] for the newly created conversation.
  Future<ModmailConversation> create(
      String subject, String body, /* String, RedditorRef */ recipient,
      {authorHidden = false}) async {
    final data = <String, String>{
      'body': body,
      'isAuthorHidden': authorHidden.toString(),
      'srName': _subreddit.displayName,
      'subject': subject,
      'to': _redditorNameHelper(recipient),
    };
    return ModmailConversation.parse(
        _subreddit.reddit,
        await _subreddit.reddit
            .post(apiPath['modmail_conversations'], data, objectify: false));
  }

  /// A [Stream] of subreddits which use the new modmail that the authenticated
  /// user moderates.
  Stream<SubredditRef> subreddits() async* {
    final response = await _subreddit.reddit
        .get(apiPath['modmail_subreddits'], objectify: false);
    final subreddits =
        (response['subreddits'] as Map).values.cast<Map<String, dynamic>>();
    final objectified = subreddits.map<Subreddit>((s) =>
        Subreddit.parse(_subreddit.reddit, {'data': snakeCaseMapKeys(s)}));
    for (final s in objectified) {
      yield s;
    }
  }

  /// Return number of unread conversations by conversation state.
  ///
  /// Note: at time of writing, only the following states are populated:
  ///   * archived
  ///   * highlighted
  ///   * inprogress
  ///   * mod
  ///   * newMail
  ///   * notifications
  ///
  /// Returns an instance of [ModmailUnreadStatistics].
  Future<ModmailUnreadStatistics> unreadCount() async {
    final response = await _subreddit.reddit
        .get(apiPath['modmail_unread_count'], objectify: false);
    return ModmailUnreadStatistics._(response.cast<String, int>());
  }
}

/// A representation of the number of unread Modmail conversations by state.
class ModmailUnreadStatistics {
  final Map<String, int> _data;
  ModmailUnreadStatistics._(this._data);

  int get archived => _data['archived'];

  int get highlighted => _data['highlighted'];

  int get inProgress => _data['inprogress'];

  int get mod => _data['mod'];

  int get newMail => _data['new'];

  int get notifications => _data['notifications'];

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(_data);
}

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
  final SubredditRef _subreddit;

  SubredditStream(this._subreddit);

  /// Yields new [Comment]s as they become available.
  ///
  /// [Comment]s are yielded oldest first. Up to 100 historical comments will
  /// initially be returned. If [limit] is provided, the stream will close
  /// after [limit] iterations. If [pauseAfter] is provided, null will be
  /// returned after [pauseAfter] requests without new items.
  Stream<Comment> comments({int limit, int pauseAfter}) =>
      streamGenerator<Comment>(_subreddit.comments,
          itemLimit: limit, pauseAfter: pauseAfter);

  /// Yields new [Submission]s as they become available.
  ///
  /// [Submission]s are yielded oldest first. Up to 100 historical submissions
  /// will initially be returned. If [limit] is provided, the stream will close
  /// after [limit] iterations. If [pauseAfter] is provided, null will be
  /// returned after [pauseAfter] requests without new items.
  Stream<Submission> submissions({int limit, int pauseAfter}) =>
      streamGenerator<Submission>(_subreddit.newest,
          itemLimit: limit, pauseAfter: pauseAfter);
}

/// Represents stylesheet information for a [Subreddit].
class StyleSheet {
  /// The CSS for the [Subreddit].
  final String stylesheet;

  /// A list of images associated with the [Subreddit].
  final List<StyleSheetImage> images;

  StyleSheet(this.stylesheet, [this.images = const []]);

  @override
  String toString() => stylesheet;
}

/// A representation of an image associated with a [Subreddit]'s [StyleSheet].
class StyleSheetImage {
  /// The URL for the image.
  final Uri url;

  /// The CSS link for the image.
  final String link;

  /// The original name of the image.
  final String name;

  StyleSheetImage(this.url, this.link, this.name);

  @override
  String toString() => name;
}

enum ImageFormat {
  jpeg,
  png,
}

/// Provides a set of stylesheet functions to a [Subreddit].
class SubredditStyleSheet {
  // static const String _kJpegHeader = '\xff\xd8\xff';
  static const String _kUploadType = 'upload_type';
  final SubredditRef _subreddit;
  SubredditStyleSheet(this._subreddit);

  /// Return the stylesheet for the [Subreddit].
  Future<StyleSheet> call() async {
    final uri = apiPath['about_stylesheet']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    return await _subreddit.reddit.get(uri);
  }

  Future<Uri> _uploadImage(Uri imagePath, Uint8List imageBytes,
      ImageFormat format, Map<String, dynamic> data) async {
    const kImgType = 'img_type';
    if ((imagePath == null) && (imageBytes == null)) {
      throw DRAWArgumentError(
          'Only one of imagePath or imageBytes can be provided.');
    }

    if (imageBytes == null) {
      final imageInfo = await loadImage(imagePath);
      // ignore: parameter_assignments
      format = imageInfo['imageType'];
      // ignore: parameter_assignments
      imageBytes = imageInfo['imageBytes'];
    }
    data[kImgType] = (format == ImageFormat.png) ? 'png' : 'jpeg';
    data['api_type'] = 'json';
    final uri = apiPath['upload_image']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    final response = await _subreddit.reddit
        .post(uri, data, files: {'file': imageBytes}, objectify: false) as Map;
    const kImgSrc = 'img_src';
    const kErrors = 'errors';
    const kErrorsValues = 'errors_values';
    if (response[kImgSrc].isNotEmpty) {
      return Uri.parse(response[kImgSrc]);
    } else {
      throw DRAWImageUploadException(
          response[kErrors].first, response[kErrorsValues].first);
    }
  }

  /// Remove the current header image for the [Subreddit].
  Future<void> deleteHeader() async {
    final uri = apiPath['delete_sr_header']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    await _subreddit.reddit.post(uri, {
      'api_type': 'json',
    });
  }

  /// Remove the named image from the [Subreddit].
  Future<void> deleteImage(String name) async {
    const kImgName = 'img_name';
    final uri = apiPath['delete_sr_image']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    await _subreddit.reddit
        .post(uri, <String, String>{'api_type': 'json', kImgName: name});
  }

  /// Remove the current mobile header image for the [Subreddit].
  Future<void> deleteMobileHeader() async {
    final uri = apiPath['delete_sr_banner']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    await _subreddit.reddit.post(uri, {
      'api_type': 'json',
    });
  }

  /// Remove the current mobile icon for the [Subreddit].
  Future<void> deleteMobileIcon() async {
    final uri = apiPath['delete_sr_icon']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    await _subreddit.reddit.post(uri, {
      'api_type': 'json',
    });
  }

  /// Update the stylesheet for the [Subreddit].
  ///
  /// `stylesheet` is the CSS for the new stylesheet.
  Future<void> update(String stylesheet, {String reason}) async {
    final uri = apiPath['subreddit_stylesheet']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);

    final data = <String, String>{
      'api_type': 'json',
      'op': 'save',
      'reason': reason,
      'stylesheet_contents': stylesheet,
    };

    return await _subreddit.reddit.post(uri, data);
  }

  /// Upload an image to the [Subreddit].
  ///
  /// `name` is the name to be used for the image. If an image already exists
  /// with this name, it will be replaced.
  ///
  /// `imagePath` is the path to a JPEG or PNG image. This path must be local
  /// and accessible from disk. Will result in an [UnsupportedError] if provided
  /// in a web application.
  ///
  /// `bytes` is a list of bytes representing an image.
  ///
  /// `format` is the format of the image defined by `bytes`.
  ///
  /// On success, the [Uri] for the uploaded image is returned. On failure,
  /// [DRAWImageUploadException] is thrown.
  Future<Uri> upload(String name,
          {Uri imagePath, Uint8List bytes, ImageFormat format}) async =>
      await _uploadImage(imagePath, bytes, format, <String, String>{
        'name': name,
        _kUploadType: 'img',
      });

  /// Upload an image to be used as the header image for the [Subreddit].
  ///
  /// `imagePath` is the path to a JPEG or PNG image. This path must be local
  /// and accessible from disk. Will result in an [UnsupportedError] if provided
  /// in a web application.
  ///
  /// `bytes` is a list of bytes representing an image.
  ///
  /// `format` is the format of the image defined by `bytes`.
  ///
  /// On success, the [Uri] for the uploaded image is returned. On failure,
  /// [DRAWImageUploadException] is thrown.
  Future<Uri> uploadHeader(
          {Uri imagePath, Uint8List bytes, ImageFormat format}) async =>
      await _uploadImage(imagePath, bytes, format, <String, String>{
        _kUploadType: 'header',
      });

  /// Upload an image to be used as the mobile header image for the [Subreddit].
  ///
  /// `imagePath` is the path to a JPEG or PNG image. This path must be local
  /// and accessible from disk. Will result in an [UnsupportedError] if provided
  /// in a web application.
  ///
  /// `bytes` is a list of bytes representing an image.
  ///
  /// `format` is the format of the image defined by `bytes`.
  ///
  /// On success, the [Uri] for the uploaded image is returned. On failure,
  /// [DRAWImageUploadException] is thrown.
  Future<Uri> uploadMobileHeader(
          {Uri imagePath, Uint8List bytes, ImageFormat format}) async =>
      await _uploadImage(imagePath, bytes, format, <String, String>{
        _kUploadType: 'banner',
      });

  /// Upload an image to be used as the mobile icon image for the [Subreddit].
  ///
  /// `imagePath` is the path to a JPEG or PNG image. This path must be local
  /// and accessible from disk. Will result in an [UnsupportedError] if provided
  /// in a web application.
  ///
  /// `bytes` is a list of bytes representing an image.
  ///
  /// `format` is the format of the image defined by `bytes`.
  ///
  /// On success, the [Uri] for the uploaded image is returned. On failure,
  /// [DRAWImageUploadException] is thrown.
  Future<Uri> uploadMobileIcon(
          {Uri imagePath, Uint8List bytes, ImageFormat format}) async =>
      await _uploadImage(imagePath, bytes, format, <String, String>{
        _kUploadType: 'icon',
      });
}

/// Provides a set of wiki functions to a [Subreddit].
class SubredditWiki {
  final SubredditRef _subreddit;
  final SubredditRelationship banned;
  final SubredditRelationship contributor;
  SubredditWiki(this._subreddit)
      : banned = SubredditRelationship(_subreddit, 'wikibanned'),
        contributor = SubredditRelationship(_subreddit, 'wikicontributor');

  /// Creates a [WikiPageRef] for the wiki page named `page`.
  WikiPageRef operator [](String page) =>
      WikiPageRef(_subreddit.reddit, _subreddit, page.toLowerCase());

  /// Creates a new [WikiPage].
  ///
  /// `name` is the name of the page. All spaces are replaced with '_' and the
  /// name is converted to lowercase.
  ///
  /// `content` is the initial content of the page.
  ///
  /// `reason` is the optional message explaining why the page was created.
  Future<WikiPage> create(String name, String content, {String reason}) async {
    final newName = name.replaceAll(' ', '_').toLowerCase();
    final newPage = WikiPageRef(_subreddit.reddit, _subreddit, newName);
    await newPage.edit(content, reason: reason);
    return await newPage.populate();
  }

  /// A [Stream] of [WikiEdit] objects, which represent revisions made to this
  /// wiki.
  Stream<WikiEdit> revisions() {
    final url = apiPath['wiki_revisions']
        .replaceAll(SubredditRef._subredditRegExp, _subreddit.displayName);
    return revisionGenerator(_subreddit, url);
  }
}
