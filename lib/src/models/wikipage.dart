// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/base_impl.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/getter_utils.dart';

Stream<WikiEdit> revisionGenerator(SubredditRef s, String url) =>
    WikiPageRef._revisionGenerator(s, url);

/// A lazily initialized object which represents a subreddit's wiki page. Can
/// be promoted to a populated [WikiPage].
class WikiPageRef extends RedditBase {
  static final RegExp _kSubredditRegExp = RegExp(r'{subreddit}');
  static final RegExp _kPageRegExp = RegExp(r'{page}');

  /// The name of the wiki page.
  final String name;

  final String _revision;
  final SubredditRef _subreddit;
  WikiPageModeration _mod;

  String get infoPath => apiPath['wiki_page']
      .replaceAll(_kSubredditRegExp, _subreddit.displayName)
      .replaceAll(_kPageRegExp, name);

  factory WikiPageRef(Reddit reddit, SubredditRef subreddit, String name,
          {String revision}) =>
      WikiPageRef._(reddit, subreddit, name, revision);

  WikiPageRef._(
      Reddit reddit, SubredditRef subreddit, String name, String revision)
      : _subreddit = subreddit,
        _revision = revision,
        name = name,
        super(reddit);

  @override
  bool operator ==(Object a) =>
      ((a is WikiPageRef) && (name.toLowerCase() == a.name.toLowerCase()));

  @override
  int get hashCode => name.toLowerCase().hashCode;

  /// A helper object which allows for performing moderator actions on
  /// this wiki page.
  WikiPageModeration get mod {
    _mod ??= WikiPageModeration._(this);
    return _mod;
  }

  /// Promote this [WikiPageRef] into a populated [WikiPage].
  Future<WikiPage> populate() async => await fetch();

  @override
  Future<WikiPage> fetch() async {
    final params = <String, String>{
      'api_type': 'json',
    };
    if (name != null) {
      params['page'] = name;
    }
    if (_revision != null) {
      params['v'] = _revision;
    }
    final result = (await reddit.get(infoPath,
        params: params,
        objectify: false,
        followRedirects: true))['data'] as Map;
    if (result.containsKey('revision_by')) {
      result['revision_by'] =
          Redditor.parse(reddit, result['revision_by']['data']);
    }
    return WikiPage._(reddit, _subreddit, name, _revision, result);
  }

  static Stream<WikiEdit> _revisionGenerator(
      SubredditRef subreddit, String url) async* {
    await for (final Map<String, dynamic> revision
        in ListingGenerator.createBasicGenerator(subreddit.reddit, url)) {
      if (revision.containsKey('author')) {
        revision['author'] =
            Redditor.parse(subreddit.reddit, revision['author']['data']);
      }
      revision['page'] = WikiPageRef(
          subreddit.reddit, subreddit, revision['page'],
          revision: revision['id']);
      yield WikiEdit._(revision);
    }
  }

  /// Edits the content of the current page.
  ///
  /// `content` is a markdown formatted [String] which will become the new
  /// content of the page.
  ///
  /// `reason` is an optional parameter used to describe why the edit was made.
  Future<void> edit(String content, {String reason}) async {
    final data = <String, String>{
      'content': content,
      'page': name,
    };
    if (reason != null) {
      data['reason'] = reason;
    }
    return reddit.post(
        apiPath['wiki_edit']
            .replaceAll(_kSubredditRegExp, _subreddit.displayName),
        data,
        discardResponse: true);
  }

  /// Create a [WikiPageRef] which represents the current wiki page at the
  /// provided revision.
  WikiPageRef revision(String revision) =>
      WikiPageRef(reddit, _subreddit, name, revision: revision);

  /// A [Stream] of [WikiEdit] objects, which represent revisions made to this
  /// wiki page.
  Stream<WikiEdit> revisions() {
    final url = apiPath['wiki_page_revisions']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName)
        .replaceAll(_kPageRegExp, name);
    return _revisionGenerator(_subreddit, url);
  }
}

/// A representation of a subreddit's wiki page.
class WikiPage extends WikiPageRef with RedditBaseInitializedMixin {
  WikiPage._(Reddit reddit, SubredditRef subreddit, String name,
      String revision, Map<String, dynamic> data)
      : super._(reddit, subreddit, name, revision) {
    setData(this, data);
  }

  /// The content of the page, in HTML format.
  String get contentHtml => data['content_html'];

  /// The content of the page, in Markdown format.
  String get contentMarkdown => data['content_md'];

  /// Whether this page may be revised.
  bool get mayRevise => data['may_revise'];

  /// The date and time the revision was made.
  DateTime get revisionDate =>
      GetterUtils.dateTimeOrNull(data['revision_date']);

  /// The [Redditor] who made the revision.
  Redditor get revisionBy => data['revision_by'];

  @override
  Future<WikiPage> refresh() async {
    final result = await fetch();
    setData(this, result.data);
    return this;
  }
}

/// A representation of edits made to a [WikiPage].
class WikiEdit {
  final Map<String, dynamic> data;

  /// The [Redditor] who performed the edit.
  Redditor get author => data['author'];

  /// The [WikiPageRef] which was edited.
  WikiPageRef get page => data['page'];

  /// The optional reason the edit was made.
  String get reason => data['reason'];

  /// The ID of the revision.
  String get revision => data['id'];

  /// The date and time the revision was made.
  DateTime get timestamp => GetterUtils.dateTimeOrNull(data['timestamp']);

  WikiEdit._(this.data);

  @override
  bool operator ==(Object other) =>
      ((other is WikiEdit) && (other.revision == revision));

  @override
  int get hashCode => revision.hashCode;

  @override
  String toString() => data.toString();
}

// DO NOT REORDER!
/// [WikiPage] permissions for editing and viewing.
///
/// [WikiPermissionLevel.useSubredditWikiPermissions]: use the wiki permissions
/// set by the subreddit.
///
/// [WikiPermissionLevel.approvedWikiContributors]: only approved wiki
/// contributors for a given page may edit.
///
/// [WikiPermissionlevel.modsOnly]: only moderators may edit and view this page.
enum WikiPermissionLevel {
  useSubredditWikiPermissions,
  approvedWikiContributors,
  modsOnly,
}

/// Contains the current settings of a [WikiPageRef].
class WikiPageSettings {
  Map get data => _data;
  final WikiPageRef wikiPage;
  Map _data;
  final List<Redditor> _editors = <Redditor>[];

  WikiPageSettings._(this.wikiPage, this._data) {
    _populateEditorsList();
  }

  void _populateEditorsList() {
    final rawEditors = data['editors'];
    for (final e in rawEditors) {
      _editors.add(Redditor.parse(wikiPage.reddit, e['data']));
    }
  }

  /// A list of [Redditor]s who are approved to edit this wiki page.
  ///
  /// These [Redditor] objects may be partially populated. Print their `data`
  /// property to see which fields are populated.
  List<Redditor> get editors => _editors;

  /// Whether the wiki page is listed and visible for non-moderators.
  bool get listed => data['listed'];

  /// Who can edit this wiki page.
  WikiPermissionLevel get permissionLevel =>
      WikiPermissionLevel.values[data['permlevel']];

  /// Retrieve the most up-to-date settings and update in-place.
  ///
  /// Returns a reference to the existing [WikiPageSettings] object.
  Future<WikiPageSettings> refresh() async {
    final settings = await wikiPage.mod.settings();
    _data = settings.data;
    _editors.clear();
    _populateEditorsList();
    return this;
  }

  @override
  String toString() => data.toString();
}

// TODO(bkonyi): de-duplicate from subreddit.dart
String _redditorNameHelper(/* String, RedditorRef */ redditor) {
  if (redditor is RedditorRef) {
    return redditor.displayName;
  } else if (redditor is! String) {
    throw DRAWArgumentError('Parameter redditor must be either a'
        'String or Redditor');
  }
  return redditor;
}

/// Provides a set of moderation functions for a [WikiPageRef].
class WikiPageModeration {
  static final RegExp _kMethodRegExp = RegExp(r'{method}');
  final WikiPageRef wikiPage;

  WikiPageModeration._(this.wikiPage);

  Future<void> _addRemoveHelper(String redditor, String method) async {
    final data = <String, String>{
      'page': wikiPage.name,
      'username': redditor,
    };
    final url = apiPath['wiki_page_editor']
        .replaceAll(
            WikiPageRef._kSubredditRegExp, wikiPage._subreddit.displayName)
        .replaceAll(_kMethodRegExp, method);
    await wikiPage.reddit.post(url, data, discardResponse: true);
  }

  /// Add an editor to this [WikiPageRef].
  Future<void> add(/* RedditorRef, String */ redditor) async =>
      _addRemoveHelper(_redditorNameHelper(redditor), 'add');

  /// Remove an editor from this [WikiPageRef].
  Future<void> remove(/* RedditorRef, String */ redditor) async =>
      _addRemoveHelper(_redditorNameHelper(redditor), 'del');

  /// The settings for this [WikiPageRef].
  Future<WikiPageSettings> settings() async {
    final url = apiPath['wiki_page_settings']
        .replaceAll(
            WikiPageRef._kSubredditRegExp, wikiPage._subreddit.displayName)
        .replaceAll(WikiPageRef._kPageRegExp, wikiPage.name);
    final data = (await wikiPage.reddit.get(url, objectify: false))['data'];
    return WikiPageSettings._(wikiPage, data);
  }

  /// Updates the settings for this [WikiPageRef].
  ///
  /// `listed` specifies whether this page appears on the page list.
  /// `permissionLevel` specifies who can edit this page. See
  /// [WikiPermissionLevel] for details.
  ///
  /// Returns a new [WikiPageSettings] object with the updated settings.
  Future<WikiPageSettings> update(
      bool listed, WikiPermissionLevel permissionLevel) async {
    final data = <String, String>{
      'listed': listed.toString(),
      'permlevel': permissionLevel.index.toString(),
    };
    final url = apiPath['wiki_page_settings']
        .replaceAll(
            WikiPageRef._kSubredditRegExp, wikiPage._subreddit.displayName)
        .replaceAll(WikiPageRef._kPageRegExp, wikiPage.name);
    final result =
        (await wikiPage.reddit.post(url, data, objectify: false))['data'];
    return WikiPageSettings._(wikiPage, result);
  }
}
