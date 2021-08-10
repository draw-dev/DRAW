// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:draw/src/exceptions.dart';
import 'package:draw/src/models/subreddit.dart';

/// A set that can only contain up to a max number of elements. If the set is
/// full and another item is added, the oldest item in the set is removed.
class BoundedSet<T> {
  final int _maxItems;
  final List _fifo;
  final Set _set;

  BoundedSet(int maxItems)
      : _maxItems = maxItems,
        _fifo = <T>[],
        _set = <T>{};

  bool contains(T object) {
    return _set.contains(object);
  }

  void add(T object) {
    if (_set.length == _maxItems) {
      final success = _set.remove(_fifo.removeAt(0));
      assert(success);
    }
    _fifo.add(object);
    _set.add(object);
  }
}

/// A counter class which increases count exponentially with jitter up to a
/// maximum value.
class ExponentialCounter {
  final double _maxCounter;
  final Random _random;
  double _base = 1.0;

  ExponentialCounter(int maxCounter)
      : _maxCounter = maxCounter.toDouble(),
        _random = Random();

  int counter() {
    // See the following for a description of jitter and why we should use it:
    // https://www.awsarchitectureblog.com/2015/03/backoff.html
    final maxJitter = _base / 16.0;
    final value = _base + _random.nextDouble() * maxJitter - maxJitter / 2.0;
    _base = min(_base * 2, _maxCounter);
    return value.round();
  }

  void reset() {
    _base = 1.0;
  }
}

Stream<T?> streamGenerator<T>(function,
    {int? itemLimit, int? pauseAfter}) async* {
  final counter = ExponentialCounter(16);
  final BoundedSet<String?> seen = BoundedSet<String>(301);
  var withoutBeforeCounter = 0;
  var responsesWithoutNew = 0;
  var beforeFullname;
  var count = 0;

  while (true) {
    var limit = 100;
    var found = false;
    var newestFullname;
    if (beforeFullname == null) {
      limit -= withoutBeforeCounter;
      withoutBeforeCounter = (withoutBeforeCounter + 1) % 30;
    }

    final results = [];
    await for (final item in function(params: <String, String>{
      'limit': min(limit, itemLimit ?? limit).toString(),
      if (beforeFullname != null) 'before': beforeFullname
    })) {
      results.add(item);
    }

    for (final item in results.reversed) {
      final fullname = await item.fullname;
      if (seen.contains(fullname)) {
        continue;
      }
      found = true;
      seen.add(fullname);
      newestFullname = fullname;
      yield item as T;
      count++;
      if (itemLimit == count) {
        return;
      }
    }

    beforeFullname = newestFullname;
    if (pauseAfter != null && pauseAfter < 0) {
      yield null;
    } else if (found) {
      counter.reset();
      responsesWithoutNew = 0;
    } else {
      responsesWithoutNew += 1;
      if (pauseAfter != null && (responsesWithoutNew > pauseAfter)) {
        responsesWithoutNew = 0;
        yield null;
      } else {
        await Future.delayed(Duration(seconds: counter.counter()));
      }
    }
  }
}

Map<String, dynamic> snakeCaseMapKeys(Map<String, dynamic> m) =>
    m.map((k, v) => MapEntry(snakeCase(k), v));

final RegExp _snakecaseRegexp = RegExp('[A-Z]');
String snakeCase(String name, [separator = '_']) => name.replaceAllMapped(
    _snakecaseRegexp,
    (Match match) =>
        (match.start != 0 ? separator : '') + match.group(0)!.toLowerCase());

String permissionsString(
    List<String> permissions, Set<String> validPermissions) {
  final processed = <String>[];
  if (permissions.isEmpty ||
      ((permissions.length == 1) && (permissions[0] == 'all'))) {
    processed.add('+all');
  } else {
    //processed.add('-all');
    final omitted = validPermissions.difference(permissions.toSet());
    processed.addAll(omitted.map((s) => '-$s').toList());
    processed.addAll(permissions.map((s) => '+$s').toList());
  }
  return processed.join(',');
}

ModeratorPermission stringToModeratorPermission(String p) {
  switch (p) {
    case 'all':
      return ModeratorPermission.all;
    case 'access':
      return ModeratorPermission.access;
    case 'config':
      return ModeratorPermission.config;
    case 'flair':
      return ModeratorPermission.flair;
    case 'mail':
      return ModeratorPermission.mail;
    case 'posts':
      return ModeratorPermission.posts;
    case 'wiki':
      return ModeratorPermission.wiki;
    default:
      throw DRAWInternalError("Unknown moderator permission '$p'");
  }
}

List<ModeratorPermission> stringsToModeratorPermissions(
        List<String> permissions) =>
    permissions.map((p) => stringToModeratorPermission(p)).toList();

String moderatorPermissionToString(ModeratorPermission p) {
  switch (p) {
    case ModeratorPermission.all:
      return 'all';
    case ModeratorPermission.access:
      return 'access';
    case ModeratorPermission.config:
      return 'config';
    case ModeratorPermission.flair:
      return 'flair';
    case ModeratorPermission.mail:
      return 'mail';
    case ModeratorPermission.posts:
      return 'posts';
    case ModeratorPermission.wiki:
      return 'wiki';
    default:
      throw DRAWInternalError("Unknown ModeratorPermission '$p'");
  }
}

List<String> moderatorPermissionsToStrings(
        List<ModeratorPermission> permissions) =>
    permissions.map((p) => moderatorPermissionToString(p)).toList();
