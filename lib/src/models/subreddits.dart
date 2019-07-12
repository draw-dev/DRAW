// Copyright (c) 2019, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/util.dart';

/// Contains functionality which allows for querying information related to
/// Subreddits.
class Subreddits {
  static final RegExp _kSubredditsRegExp = RegExp(r'{subreddits}');
  final Reddit reddit;

  Subreddits(this.reddit);

  /// Returns a [Stream] of default subreddits.
  Stream<SubredditRef> defaults({int limit, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(
          reddit, apiPath['subreddits_default'],
          limit: limit, params: params);

  /// Returns a [Stream] of gold subreddits.
  Stream<SubredditRef> gold({int limit, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['subreddits_gold'],
          limit: limit, params: params);

  /// Returns a [Stream] of new subreddits.
  Stream<SubredditRef> newest({int limit, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, apiPath['subreddits_new'],
          limit: limit, params: params);

  /// Returns a [Stream] of popular subreddits.
  Stream<SubredditRef> popular({int limit, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(
          reddit, apiPath['subreddits_popular'],
          limit: limit, params: params);

  /// Returns a [List] of subreddit recommendedations based on the given list
  /// of subreddits.
  ///
  /// `subreddits` is a list of [SubredditRef]s and/or subreddit names as
  /// [String]s. `omitSubreddits` is a list of [SubredditRef]s and/or subreddit
  /// names as [String]s which are to be excluded from the results.
  Future<List<SubredditRef>> recommended(List subreddits,
      {List omitSubreddits}) async {
    if (subreddits == null) {
      throw DRAWArgumentError('Argument "subreddits" cannot be null.');
    }
    String subredditsToString(List subs) {
      if (subs == null) {
        return '';
      }
      final strings = <String>[];
      for (final s in subs) {
        if (s is SubredditRef) {
          strings.add(s.displayName);
        } else if (s is String) {
          strings.add(s);
        } else {
          throw DRAWArgumentError('A subreddit list must contain either ' +
              'instances of SubredditRef or String. Got type: ${s.runtimeType}.');
        }
      }
      return strings.join(',');
    }

    final params = <String, String>{'omit': subredditsToString(omitSubreddits)};
    final url = apiPath['sub_recommended']
        .replaceAll(_kSubredditsRegExp, subredditsToString(subreddits));

    return <SubredditRef>[
      for (final sub in await reddit.get(url, params: params, objectify: false))
        SubredditRef.name(reddit, sub['sr_name'])
    ];
  }

  /// Returns a [Stream] of subreddits matching `query`.
  ///
  /// This search is performed using both the title and description of
  /// subreddits. To search solely by name, see [Subreddits.searchByName].
  Stream<SubredditRef> search(String query,
      {int limit, Map<String, String> params}) {
    if (query == null) {
      throw DRAWArgumentError('Parameter "query" cannot be null');
    }
    params ??= <String, String>{};
    params['q'] = query;
    return ListingGenerator.createBasicGenerator(
        reddit, apiPath['subreddits_search'],
        limit: limit, params: params);
  }

  /// Returns a [List<SubredditRef>] of subreddits whose names being with
  /// `query`.
  ///
  /// If `includeNsfw` is true, NSFW subreddits will be included in the
  /// results. If `exact` is true, only results which are directly matched by
  /// `query` will be returned.
  Future<List<SubredditRef>> searchByName(String query,
      {bool includeNsfw = true, bool exact = false}) async {
    if (query == null) {
      throw DRAWArgumentError('Parameter "query" cannot be null.');
    }
    final params = <String, String>{};
    params['query'] = query;
    params['exact'] = exact.toString();
    params['include_over_18'] = includeNsfw.toString();
    return <SubredditRef>[
      for (final s in (await reddit.post(
          apiPath['subreddits_name_search'], params,
          objectify: false))['names'])
        reddit.subreddit(s)
    ];
  }

  /// Returns a [Stream] which is populated as new subreddits are created.
  Stream<SubredditRef> stream({int limit, int pauseAfter}) =>
      streamGenerator(newest, itemLimit: limit, pauseAfter: pauseAfter);
}
