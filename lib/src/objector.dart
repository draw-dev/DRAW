// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'base.dart';
import 'exceptions.dart';
import 'reddit.dart';
import 'models/multireddit.dart';
import 'models/redditor.dart';
import 'models/subreddit.dart';

/// Converts responses from the Reddit API into instances of [RedditBase].
class Objector extends RedditBase {
  Objector(Reddit reddit) : super(reddit);

  dynamic _objectifyDictionary(Map data) {
    if (data.containsKey('name')) {
      // Redditor type.
      return new Redditor.parse(reddit, data);
    } else if (data.containsKey('data') &&
        (data['data'] is Map) &&
        data['data'].containsKey('subreddit_type')) {
      return new Subreddit.parse(reddit, data);
    } else if (data.containsKey('kind') && (data['kind'] == 'LabeledMulti')) {
      assert(
          data.containsKey('data'),
          'field "data" is expected in a response'
          'of type "LabeledMulti"');
      return new Multireddit.parse(reddit, data['data']);
    } else if (data.containsKey('sr') &&
        data.containsKey('comment_karma') &&
        data.containsKey('link_karma')) {
      final karmaMap = new Map<Subreddit, Map<String, int>>();
      final subreddit = new Subreddit(reddit, data['sr']);
      final value = {
        'commentKarma': data['comment_karma'],
        'linkKarma': data['link_karma'],
      };
      return {subreddit: value};
    } else {
      throw new DRAWUnimplementedError('Cannot objectify unsupported response');
    }
  }

  List<RedditBase> _objectifyList(List listing) {
    final objectifiedListing = new List<RedditBase>(listing.length);
    for (var i = 0; i < listing.length; ++i) {
      objectifiedListing[i] = _objectifyDictionary(listing[i]);
    }
    return objectifiedListing;
  }

  /// Converts a response from the Reddit API into an instance of [RedditBase]
  /// or a container of [RedditBase] objects. [data] should be one of [List] or
  /// [Map], and the return type is one of [RedditBase], [List<RedditBase>], or
  /// [Map<RedditBase>] depending on the response type.
  dynamic objectify(dynamic data) {
    if (data is List) {
      return _objectifyList(data);
    } else if (data is! Map) {
      throw new DRAWInternalError('data must be of type List or Map, got '
          '${data.runtimeType}');
    } else if (data.containsKey('kind')) {
      final kind = data['kind'];
      if (kind == 'Listing') {
        final listing = data['data']['children'];
        final before = data['data']['before'];
        final after = data['data']['after'];
        final objectifiedListing = _objectifyList(listing);
        final result = {
          'listing': objectifiedListing,
          'before': before,
          'after': after
        };
        return result;
      } else if (kind == 'UserList') {
        final listing = data['data']['children'];
        return _objectifyList(listing);
      } else if (kind == 'KarmaList') {
        final listing = _objectifyList(data['data']);
        final karmaMap = new Map<Subreddit, Map<String, int>>();
        // TODO(bkonyi): there's probably a nicer way to merge all of these
        // maps.
        listing.forEach((map) {
          karmaMap.addAll(map);
        });
        return karmaMap;
      }
      throw new DRAWUnimplementedError('response kind, ${kind}, is not '
          'currently implemented.');
    }
    return _objectifyDictionary(data);
  }
}
