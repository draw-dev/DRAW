// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import '../../exceptions.dart';
import '../../reddit.dart';
import '../../models/user_content.dart';
import '../../models/redditor.dart';
import '../listing_generator.dart';
import 'redditor.dart';

/// An enum used to specify how to filter results based on time.
enum TimeFilter {
  all,
  day,
  hour,
  month,
  week,
  year,
}

/// Converts a [TimeFilter] into a simple [String].
String timeFilterToString(TimeFilter filter) {
  switch (filter) {
    case TimeFilter.all:
      return 'all';
    case TimeFilter.day:
      return 'day';
    case TimeFilter.hour:
      return 'hour';
    case TimeFilter.month:
      return 'month';
    case TimeFilter.week:
      return 'week';
    case TimeFilter.year:
      return 'year';
    default:
      throw DRAWInternalError('TimeFilter $filter is not'
          'supported');
  }
}

/// An enum used to specify how to sort results.
enum Sort {
  relevance,
  hot,
  top,
  newest,
  comments,
}

/// Converts a [Sort] into a simple [String].
String sortToString(Sort sort) {
  switch (sort) {
    case Sort.relevance:
      return 'relevance';
    case Sort.hot:
      return 'hot';
    case Sort.top:
      return 'top';
    case Sort.newest:
      return 'new';
    case Sort.comments:
      return 'comments';
    default:
      throw DRAWInternalError('Sort $sort is not supported');
  }
}

/// A mixin with common listing functionality, including [ListingGenerator]
/// creation and standard listing requests by [Sort] type.
mixin BaseListingMixin {
  Reddit get reddit;
  String get path;

  Stream<UserContent> _buildGenerator(Map<String, String> params, String sort) {
    Map<String, String> _params = params;
    if ((this is RedditorRef) || (this is SubListing)) {
      var arg = '';
      if (this is RedditorRef) {
        arg = 'overview';
      }
      _params ??= Map<String, String>();
      _params['sort'] = sort;
      return ListingGenerator.generator<UserContent>(reddit, path + arg,
          limit: ListingGenerator.getLimit(params), params: _params);
    }
    return ListingGenerator.generator<UserContent>(reddit, path + sort,
        limit: ListingGenerator.getLimit(_params), params: _params);
  }

  Stream<UserContent> _buildTimeFilterGenerator(
      Map<String, String> params, String sort, TimeFilter timeFilter) {
    if (timeFilter == null) {
      throw DRAWArgumentError('Argument "timeFilter" cannot be null');
    }
    final _params = params ?? Map();
    _params['t'] = timeFilterToString(timeFilter);
    return _buildGenerator(_params, sort);
  }

  /// Returns a [Stream] of controversial comments and submissions. [timeFilter]
  /// is used to filter comments and submissions by time period.
  Stream<UserContent> controversial(
          {TimeFilter timeFilter: TimeFilter.all,
          Map<String, String> params}) =>
      _buildTimeFilterGenerator(params, 'controversial', timeFilter);

  /// Returns a [Stream] of hot comments and submissions.
  Stream<UserContent> hot({Map<String, String> params}) =>
      _buildGenerator(params, 'hot');

  /// Returns a [Stream] of the newest comments and submissions.
  Stream<UserContent> newest({Map<String, String> params}) =>
      _buildGenerator(params, 'new');

  /// Returns a [Stream] of the top comments and submissions. [timeFilter] is
  /// used to filter comments and submissions by time period.
  Stream<UserContent> top(
          {TimeFilter timeFilter: TimeFilter.all,
          Map<String, String> params}) =>
      _buildTimeFilterGenerator(params, 'top', timeFilter);
}
