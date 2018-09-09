// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../reddit.dart';
import 'package:draw/src/models/flair.dart';

/// An abstract static class used to generate [Stream]s of [RedditBase] objects.
/// This class should not be used directly, as it is used by various methods
/// defined in children of [RedditBase].
abstract class ListingGenerator {
  static const defaultRequestLimit = 100;

  static int getLimit(Map<String, String> params) {
    if ((params != null) && params.containsKey('limit')) {
      return int.tryParse(params['limit']);
    }
    return null;
  }

  static Stream<T> createBasicGenerator<T>(
          final Reddit reddit, final String path,
          {Map<String, String> params}) =>
      generator<T>(reddit, path, limit: getLimit(params), params: params);

  /// An asynchronous iterator method used to make Reddit API calls as defined
  /// by [api] in blocks of size [limit]. The default [limit] is specified by
  /// [defaultRequestLimit]. Returns a [Stream<T>] which can be iterated over
  /// using an asynchronous for-loop.
  static Stream<T> generator<T>(final Reddit reddit, final String api,
      {int limit, Map<String, String> params}) async* {
    final kLimitKey = 'limit';
    final kAfterKey = 'after';
    final nullLimit = 1024;
    final paramsInternal = (params == null)
        ? new Map<String, String>()
        : new Map<String, String>.from(params);
    final _limit = limit ?? nullLimit;
    paramsInternal[kLimitKey] = _limit.toString();
    int yielded = 0;
    int index = 0;
    List<T> listing;
    bool exhausted = false;

    Future<List> _nextBatch() async {
      if (exhausted) {
        return null;
      }
      var response = await reddit.get(api, params: paramsInternal);
      var newListing;
      if (response is List<Flair>) {
        newListing = response;
        exhausted = true;
      } else {
        response = response as Map;
        newListing = response['listing'].cast<T>();
        if (response[kAfterKey] == null) {
          exhausted = true;
        } else {
          paramsInternal[kAfterKey] = response[kAfterKey];
        }
      }
      if (newListing.length == 0) {
        return null;
      }
      index = 0;
      return newListing;
    }

    while ((_limit == null) || (yielded < _limit)) {
      if ((listing == null) || (index >= listing.length)) {
        listing = (await _nextBatch())?.cast<T>();
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
