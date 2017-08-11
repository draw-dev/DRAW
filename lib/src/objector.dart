// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'base.dart';
import 'exceptions.dart';
import 'reddit.dart';
import 'models/redditor.dart';
import 'models/subreddit.dart';

/// Converts responses from the Reddit API into instances of [RedditBase].
class Objector extends RedditBase {
  Objector(Reddit reddit) : super(reddit);

  RedditBase _objectifyDictionary(Map data) {
    if (data.containsKey('name')) {
      // Redditor type.
      return new Redditor.parse(reddit, data);
    } else if (data.containsKey('data') &&
        (data['data'] is Map) &&
        data['data'].containsKey('subreddit_type')) {
      return new Subreddit.parse(reddit, data);
    } else {
      throw new DRAWUnimplementedError('Cannot objectify unsupported response');
    }
  }

  /// Converts a response from the Reddit API into an instance of [RedditBase]
  /// or a container of [RedditBase] objects. [data] should be one of [List] or
  /// [Map], and the return type is one of [RedditBase], [List<RedditBase>], or
  /// [Map<RedditBase>] depending on the response type.
  dynamic objectify(dynamic data) {
    if (data is List) {
      // TODO(bkonyi) handle list objects, if they occur.
      throw new DRAWUnimplementedError('objectify cannot yet parse Lists');
    } else if (data is! Map) {
      throw new DRAWInternalError('data must be of type List or Map, got '
          '${data.runtimeType}');
    } else if (data.containsKey('kind')) {
      final kind = data['kind'];
      if (kind == 'Listing') {
        final listing = data['data']['children'];
        final before = data['data']['before'];
        final after = data['data']['after'];
        final objectifiedListing = new List<RedditBase>(listing.length);
        for (var i = 0; i < listing.length; ++i) {
          objectifiedListing[i] = _objectifyDictionary(listing[i]);
        }
        final result = {
          'listing': objectifiedListing,
          'before': before,
          'after': after
        };
        return result;
      }
      throw new DRAWUnimplementedError('response kind, ${kind}, is not '
          'currently implemented.');
    }
    return _objectifyDictionary(data);
  }
}
