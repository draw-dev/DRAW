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
    WikiPage._revisionGenerator(s, url);

class WikiPage extends RedditBase with RedditBaseInitializedMixin {
  static final RegExp _kSubredditRegExp = RegExp(r'{subreddit}');
  static final RegExp _kPageRegExp = RegExp(r'{page}');
  final String name;
  final String _revision;
  final SubredditRef _subreddit;

  String get infoPath => apiPath['wiki_page']
      .replaceAll(_kSubredditRegExp, _subreddit.displayName)
      .replaceAll(_kPageRegExp, name);

  WikiPage(Reddit reddit, SubredditRef subreddit, String name,
      {String revision, Map<String, String> data})
      : _subreddit = subreddit,
        _revision = revision,
        name = name,
        super(reddit) {
    setData(this, data);
  }

  @override
  bool operator ==(Object a) =>
      ((a is WikiPage) && (name.toLowerCase() == a.name.toLowerCase()));

  @override
  int get hashCode => name.hashCode;

  @override
  Future<dynamic> fetch() async {
    Map<String, String> params = <String, String> {
      'api_type': 'json',
    };
    if (name != null) {
      params['page'] = name;
    }
    if (_revision != null) {
      params['v'] = _revision;
    }
    final result = (await reddit.get(infoPath, params: params))['data'] as Map;
    if (result.containsKey('revision_by')) {
      result['revision_by'] = Redditor.parse(reddit, result['revision_by']['data']);
    }
    data.addAll(result);
    return data;
  }

  static Stream<WikiEdit> _revisionGenerator(
      SubredditRef subreddit, String url) async* {
    await for (final Map<String, dynamic> revision
        in ListingGenerator.createBasicGenerator(subreddit.reddit, url)) {
      if (revision.containsKey('author')) {
        revision['author'] =
            Redditor.parse(subreddit.reddit, revision['author']['data']);
      }
      revision['page'] = WikiPage(subreddit.reddit, subreddit, revision['page'],
          revision: revision['id']);
      yield WikiEdit._(revision);
    }
  }

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

  WikiPage revision(String revision) =>
      WikiPage(reddit, _subreddit, name, revision: revision);

  Stream<WikiEdit> revisions() {
    final url = apiPath['wiki_page_revisions']
        .replaceAll(_kSubredditRegExp, _subreddit.displayName);
    return _revisionGenerator(_subreddit, url);
  }
}

class WikiEdit {
  final Map<String, dynamic> data;
  Redditor get author => data['author'];
  String get page => data['page'];
  String get reason => data['reason'];
  String get revision => data['id'];
  DateTime get timestamp => GetterUtils.dateTimeOrNull(data['timestamp']);

  WikiEdit._(this.data);

  @override
  String toString() => data.toString();
}
