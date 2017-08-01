// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'reddit.dart';

class RedditBase {
  final Reddit reddit;
  final Map _data;
  final RegExp _snakecaseRegexp = new RegExp("[A-Z]");

  RedditBase(this.reddit) : _data = null;

  RedditBase.loadData(this.reddit, Map data) : _data = data;

  String _snakeCase(String name, [separator = '_']) => name.replaceAllMapped(
      _snakecaseRegexp,
      (Match match) =>
          (match.start != 0 ? separator : '') + match.group(0).toLowerCase());

  dynamic noSuchMethod(Invocation invocation) {
    // This is a dirty hack to allow for dynamic field population based on the
    // API response instead of hardcoding these fields and having to update them
    // when the API updates. Invocation.memberName is a Symbol, which
    // unfortunately doesn't have a getName method due to code minification
    // restrictions in dart2js, so the only way to get the name properly is
    // using the dart:mirrors library. Unfortunately, dart:mirrors isn't
    // supported in Flutter/Dart AOT, which makes it unacceptable to use in this
    // library. However, Symbol.toString() returns a string in the form of
    // Symbol("memberName") consistently on the Dart VM. We're abusing this
    // behaviour here, and there's no promise that this will work in the future,
    // but there's no reason to assume that this behaviour will change any time
    // soon.
    var name = invocation.memberName.toString();
    name = _snakeCase(name.substring(8, name.length - 2));
    if (!invocation.isGetter || (_data == null) || !_data.containsKey(name)) {
      // Check that the accessed field is a getter and the property exists.
      throw new NoSuchMethodError(this, invocation.memberName,
          invocation.positionalArguments, invocation.namedArguments);
    }
    return _data[name];
  }
}
