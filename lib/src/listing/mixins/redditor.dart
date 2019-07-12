// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../models/user_content.dart';
import '../../reddit.dart';
import '../listing_generator.dart';
import 'base.dart';

/// A mixin which provides the ability to get [Redditor] related streams.
mixin RedditorListingMixin {
  Reddit get reddit;
  String get path;
  SubListing _comments;
  SubListing _submissions;

  /// Provides an instance of [SubListing], used to make requests for
  /// [Comment]s.
  SubListing get comments {
    _comments ??= SubListing(reddit, path, 'comments/');
    return _comments;
  }

  /// Provides an instance of [SubListing], used to make requests for
  /// [Submission]s.
  SubListing get submissions {
    _submissions ??= SubListing(reddit, path, 'submitted/');
    return _submissions;
  }

  /// Returns a [Stream] of content that the user has downvoted.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> downvoted(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'downvoted',
          limit: limit, after: after, params: params);

  /// Returns a [Stream] of content that the user has gilded.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> gildings(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'gilded/given',
          limit: limit, after: after, params: params);

  /// Returns a [Stream] of content that the user has hidden.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> hidden(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'hidden',
          limit: limit, after: after, params: params);

  /// Returns a [Stream] of content that the user has saved.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> saved(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'saved',
          limit: limit, after: after, params: params);

  /// Returns a [Stream] of content that the user has upvoted.
  ///
  /// `limit` is the maximum number of objects returned by Reddit per request
  /// (the default is 100). If provided, `after` specifies from which point
  /// Reddit will return objects of the requested type. `params` is a set of
  /// additional parameters that will be forwarded along with the request.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> upvoted(
          {int limit, String after, Map<String, String> params}) =>
      ListingGenerator.createBasicGenerator(reddit, path + 'upvoted',
          limit: limit, after: after, params: params);
}

class SubListing extends Object with BaseListingMixin {
  final Reddit reddit;
  String _path;
  String get path => _path;

  SubListing(this.reddit, final String path, final String api) {
    _path = path + api;
  }
}
