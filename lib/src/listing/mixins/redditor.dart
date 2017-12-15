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
abstract class RedditorListingMixin {
  Reddit get reddit;
  String get path;
  SubListing _comments;
  SubListing _submissions;

  /// Provides an instance of [SubListing], used to make requests for
  /// [Comment]s.
  SubListing get comments {
    _comments ??= new SubListing(reddit, path, 'comments/');
    return _comments;
  }

  /// Provides an instance of [SubListing], used to make requests for
  /// [Submission]s.
  SubListing get submissions {
    _submissions ??= new SubListing(reddit, path, 'submissions/');
    return _submissions;
  }

  /// Returns a [Stream] of content that the user has downvoted.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> downvoted({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'downvoted', params: params);

  /// Returns a [Stream] of content that the user has gilded.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> gildings({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'gilded/given', params: params);

  /// Returns a [Stream] of content that the user has hidden.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> hidden({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'hidden', params: params);

  /// Returns a [Stream] of content that the user has saved.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> saved({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'saved', params: params);

  /// Returns a [Stream] of content that the user has upvoted.
  ///
  /// May raise an exception on access if the current user is not authorized to
  /// access this list.
  Stream<UserContent> upvoted({Map params}) => ListingGenerator
      .createBasicGenerator(reddit, path + 'upvoted', params: params);
}

class SubListing extends Object with BaseListingMixin {
  final Reddit reddit;
  String _path;
  String get path => _path;

  SubListing(this.reddit, final String path, final String api) {
    _path = path + api;
  }
}
