// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'exceptions.dart';
import 'reddit.dart';

String fullnameSync(RedditBase base) {
  if (base.data != null) {
    return base.data['name'];
  }
  return null;
}

void setData(RedditBase base, Map data) {
  base._data = data;
}

/// A base class for most DRAW objects which handles lazy-initialization of
/// objects and Reddit API request state.
abstract class RedditBase {
  /// The current [Reddit] instance.
  final Reddit reddit;

  /// Returns the raw properties dictionary for this object.
  ///
  /// This getter returns null if the object is lazily initialized.
  Map get data => _data;
  Map _data;

  /// The base request format for the current object.
  String get infoPath => _infoPath;
  String _infoPath;

  /// The fullname of a Reddit object.
  ///
  /// Reddit object fullnames take the form of 't3_15bfi0'.
  String get fullname => (data == null) ? null : data['name'];

  /// The id of a Reddit object.
  ///
  /// Reddit object ids take the form of '15bfi0'.
  String get id => (data == null) ? null : data['id'];

  RedditBase(this.reddit);

  RedditBase.withPath(this.reddit, String infoPath) : _infoPath = infoPath;

  RedditBase.loadData(this.reddit, Map data) : _data = data;

  RedditBase.loadDataWithPath(this.reddit, Map data, String infoPath)
      : _data = data,
        _infoPath = infoPath;

  /// Requests the data associated with the current object.
  Future fetch() async => reddit.get(_infoPath);

  /// Requests updated information from the Reddit API and updates the current
  /// object properties.
  Future refresh() async {
    final response = await fetch();
    if (response is Map) {
      _data = response;
    } else if (response is List) {
      // TODO(bkonyi): this is for populating a Submission, since requesting
      // Submission returns a list of listings, containing a Submission at [0]
      // and a listing of Comments at [1]. This probably needs to be changed
      // at some point to be a bit more robust, but it works for now.
      _data = response[0]['listing'][0].data;
      return [this, response[1]['listing']];
    } else {
      throw new DRAWInternalError('Refresh response is of unknown type: '
          '${response.runtimeType}.');
    }
    return this;
  }

  @override
  String toString() {
    if (_data != null) {
      final encoder = new JsonEncoder.withIndent('  ');
      return encoder.convert(_data);
    }
    return 'null';
  }
}
