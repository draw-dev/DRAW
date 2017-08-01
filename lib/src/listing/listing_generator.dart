// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../reddit.dart';

/// An abstract static class used to generate [Stream]s of [RedditBase] objects.
/// This class should not be used directly, as it is used by various methods
/// defined in children of [RedditBase].
abstract class ListingGenerator {
  static const defaultRequestLimit = 100;

  /// An asynchronous iterator method used to make Reddit API calls as defined
  /// by [api] in blocks of size [limit]. The default [limit] is specified by
  /// [defaultRequestLimit]. Returns a [Stream<T>] which can be iterated over
  /// using an asynchronous for-loop.
  static Stream<T> generator<T>(final Reddit reddit, final String api,
      {int limit, Map params}) async* {
    final kLimitKey = 'limit';
    final nullLimit = 1024;
    final paramsInternal = params ?? new Map();
    paramsInternal[kLimitKey] = (limit ?? nullLimit).toString();
    int yielded = 0;
    int index = 0;
    List<T> listing;

    Future<List<T>> _nextBatch() async {
      final response = (await reddit.get(api, params: paramsInternal)) as Map;
      final newListing = response['listing'];
      paramsInternal['after'] = response['after'];
      if (newListing.length == 0) {
        return null;
      }
      index = 0;
      return newListing;
    }

    while (yielded < limit) {
      if ((listing == null) || (index >= listing.length)) {
        if (listing != null &&
            listing.length < int.parse(paramsInternal[kLimitKey])) {
          break;
        }
        listing = await _nextBatch();
        if (listing == null) {
          break;
        }
      }
      yield listing[index];
      ++index;
      ++yielded;
    }
  }
}