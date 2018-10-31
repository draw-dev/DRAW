// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
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
  int get hashCode => name.hashCode;

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

// TODO(bkonyi): WikiModeration
