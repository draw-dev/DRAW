// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:color/color.dart';
import 'package:draw/src/api_paths.dart';
import 'package:draw/src/base.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/reddit.dart';
import 'package:draw/src/user.dart';

enum Visibility { hidden, private, public }

String _visibilityToString(Visibility visibility) {
  switch (visibility) {
    case Visibility.hidden:
      return "hidden";
    case Visibility.private:
      return "private";
    case Visibility.public:
      return "public";
    default:
      throw new DRAWInternalError('Visiblitity: $visibility is not supported');
  }
}

enum WeightingScheme { classic, fresh }

String _weightingSchemeToString(WeightingScheme weightingScheme) {
  switch (weightingScheme) {
    case WeightingScheme.classic:
      return "classic";
    case WeightingScheme.fresh:
      return "fresh";
    default:
      throw new DRAWInternalError(
          'WeightingScheme: $weightingScheme is not supported');
  }
}

enum IconName {
  artAndDesign,
  ask,
  books,
  business,
  cars,
  comic,
  cuteAnimals,
  diy,
  entertainment,
  foodAndDrink,
  funny,
  games,
  grooming,
  health,
  lifeAdvice,
  military,
  modelsPinup,
  music,
  news,
  philosophy,
  picturesAndGifs,
  science,
  shopping,
  sports,
  style,
  tech,
  travel,
  unusualStories,
  video,
  emptyString,
  none,
}

String _iconNameToString(IconName iconName) {
  switch (iconName) {
    case IconName.artAndDesign:
      return "art and design";
    case IconName.ask:
      return "ask";
    case IconName.books:
      return "books";
    case IconName.business:
      return "business";
    case IconName.cars:
      return "cars";
    case IconName.comic:
      return "comics";
    case IconName.cuteAnimals:
      return "cute animals";
    case IconName.diy:
      return "diy";
    case IconName.entertainment:
      return "entertainment";
    case IconName.foodAndDrink:
      return "food and drink";
    case IconName.funny:
      return "funny";
    case IconName.games:
      return "games";
    case IconName.grooming:
      return "grooming";
    case IconName.health:
      return "health";
    case IconName.lifeAdvice:
      return "life advice";
    case IconName.military:
      return "military";
    case IconName.modelsPinup:
      return "models pinup";
    case IconName.music:
      return "music";
    case IconName.news:
      return "news";
    case IconName.philosophy:
      return "philosophy";
    case IconName.picturesAndGifs:
      return "pictures and gifs";
    case IconName.science:
      return "science";
    case IconName.shopping:
      return "shopping";
    case IconName.sports:
      return "sports";
    case IconName.style:
      return "style";
    case IconName.tech:
      return "tech";
    case IconName.travel:
      return "travel";
    case IconName.unusualStories:
      return "unusual stories";
    case IconName.video:
      return "video";
    case IconName.emptyString:
      return "";
    case IconName.none:
      return "None";
    default:
      throw new DRAWInternalError('IconName: $iconName is not supported');
  }
}

/// A class which represents a Multireddit, which is a collection of
/// [Subreddit]s.
// TODO(@ckartik): Add CommentHelper.
class Multireddit extends RedditBase with RedditBaseInitializedMixin {
  static const String _kDisplayName = 'display_name';
  static const String _kFrom = "from";
  static const String _kMultiApi = 'multireddit_api';
  static const String _kMultiredditRename = 'multireddit_rename';
  static const String _kMultiredditUpdate = 'multireddit_update';
  static const String _kSubreddits = "subreddits";
  static const String _kTo = "to";
  static const String _kVisibility = "visibility";
  static const String _kWeightingScheme = "weighting_scheme";
  static const int _redditorNameInPathIndex = 2;
  static final _subredditRegExp = new RegExp(r'{subreddit}');
  static final RegExp _userRegExp = new RegExp(r'{user}');
  static final RegExp _multiredditRegExp = new RegExp(r'{multi}');

  // TODO(@ckartik): Try to make the _data['key_color'] value null.
  Color get keyColor => new HexColor(_data['key_color']);

  /// When was this [Multireddit] created.
  DateTime get createdUtc => new DateTime.fromMillisecondsSinceEpoch(
      data['created_utc'].round() * 1000,
      isUtc: true);

  /// The [IconName] associated with this multireddit.
  ///
  /// Can be one of { artAndDesign, ask, books, business, cars, comic,
  /// cuteAnimals, diy, entertainment, foodAndDrink, funny, games, grooming,
  /// health, lifeAdvice, military, modelsPinup, music, news, philosophy,
  /// picturesAndGifs, science, shopping, sports, style, tech, travel,
  /// unusualStories, video, emptyString, none }.
  /// If this information is not provided, will return null.
  IconName get iconName => IconName.values.firstWhere(
      (e) => e.toString() == ('IconName.' + _data['icon_name']),
      orElse: () => null);

  List<SubredditRef> get subreddits {
    final subredditList = [];
    subredditList.addAll(_data['subreddits']
        .map((subreddit) => new SubredditRef.name(reddit, subreddit['name'])));
    return subredditList;
  }

  /// The [Map] of data associated with this multireddit.
  Map get data => _data;
  Map _data;

  /// The [Redditor] associated with this multireddit.
  RedditorRef get author => new RedditorRef.name(reddit, _author);
  String _author;

  /// The displayName given to the [Multireddit].
  String get displayName => _data['display_name'];

  /// The infoPath will be used to uniquely identify this multireddit.
  String get infoPath => _infoPath ?? '/';
  String _infoPath;

  /// The visibility of this multireddit.
  ///
  /// Can be one of { hidden, private, public }.
  /// If this information is not provided, will return null.
  Visibility get visibility => Visibility.values.firstWhere(
      (e) => e.toString() == ('Visibility.' + _data['visibility']),
      orElse: () => null);

  /// The visibility of this multireddit.
  ///
  /// Can be one of { hidden, private, public }.
  /// If this information is not provided, will return null.
  WeightingScheme get weightingScheme => WeightingScheme.values.firstWhere(
      (e) => e.toString() == ('WeightingScheme.' + _data['weighting_scheme']),
      orElse: () => null);

  /// Does the currently authenticated [User] have the privilege to edit this
  /// multireddit.
  bool get canEdit => _data['can_edit'];

  /// Does this multireddit require visitors to be over the age of 18.
  bool get over18 => _data['over_18'];

  Multireddit.parse(Reddit reddit, Map data) : super(reddit) {
    _data = data['data'];
    _author = _data['path']?.split('/')[_redditorNameInPathIndex];
    _infoPath = _generateInfoPath(_data['name'], _author);
  }

  // Returns valid info_path for multireddit with name `name`.
  static String _generateInfoPath(String name, String user) =>
      apiPath['multireddit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(_userRegExp, user);

  /// Returns a slug version of the [title].
  static String sluggify(String title) {
    if (title == null) {
      return null;
    }
    final RegExp _invalidRegExp = new RegExp(r'(\s|\W|_)+');
    var titleScoped = title.replaceAll(_invalidRegExp, '_').trim();
    if (titleScoped.length > 21) {
      titleScoped = titleScoped.substring(21);
      final lastWord = titleScoped.lastIndexOf('_');
      //TODO(ckartik): Test this well.
      if (lastWord > 0) {
        titleScoped = titleScoped.substring(lastWord);
      }
    }
    return titleScoped ?? '_';
  }

  /// Add a [Subreddit] to this [Multireddit].
  ///
  /// [subreddit] is the name of the [Subreddit] to be added to this [Multireddit].
  Future add(/* String, Subreddit */ subreddit) async {
    subreddit = _subredditNameHelper(subreddit);
    if (subreddit == null) return;
    final url = apiPath[_kMultiredditUpdate]
        .replaceAll(_userRegExp, _author)
        .replaceAll(_multiredditRegExp, displayName)
        .replaceAll(_subredditRegExp, subreddit);
    await reddit.put(url, body: {'model': '{"name" : "$subreddit"}'});
    await refresh();
  }

  // TODO(@ckartik): Ask @bkonyi if this function should me moved in as a static function
  // in the [Subreddit] class, and the respective versions of it like [_redditorNameHelper]
  // in [Subreddit] me moved into the [Redditor] class as a static function.
  String _subredditNameHelper(/* String, Subreddit */ subreddit) {
    if (subreddit is Subreddit) {
      return subreddit.displayName;
    } else if (subreddit is! String) {
      throw new DRAWArgumentError('Parameter subreddit must be either a'
          'String or Subreddit');
    }
    return subreddit;
  }

  /// Copy this [Multireddit], and return the new [Multireddit] of type [Future].
  ///
  /// [multiName] is an optional string that will become the display name of the new
  /// multireddit and be used as the source for the [name]. If [multiName] is not
  /// provided, the [name] of this [Multireddit] will be used.
  Future<Multireddit> copy([String multiName]) async {
    final url = apiPath['multireddit_copy'];
    final name = sluggify(multiName) ?? _data['display_name'];
    final userName = await reddit.user.me().then((me) => me.displayName);

    final scopedMultiName = multiName ?? _data['display_name'];

    final data = {
      _kDisplayName: scopedMultiName,
      _kFrom: _infoPath,
      _kTo: apiPath['multireddit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(_userRegExp, userName),
    };
    return await reddit.post(url, data);
  }

  /// Delete this [Multireddit].
  ///
  /// Does not refresh current instance of Multireddit, as it has been deleted.
  Future delete() async {
    await reddit.delete(apiPath['multireddit_base'] + _infoPath);
  }

/*
  /// Remove a [Subreddit] from this [Multireddit].
  ///
  /// [subreddit] contains the name of the subreddit to be deleted.
  Future remove({String subreddit, Subreddit subredditInstance}) async {
    subreddit = subredditInstance?.displayName;
    if (subreddit == null) return;
    final url = apiPath[_kMultiredditUpdate]
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(User.userRegExp, _author)
        .replaceAll(_subredditRegExp, subreddit);
    final data = {'model': "{'name': $subreddit}"};
    await reddit.delete(url, body: data);
  }

  /// Rename this [Multireddit].
  ///
  /// [newName] is the new display for this [Multireddit].
  /// The [name] will be auto generated from the displayName.
  Future rename(newName) async {
    final url = apiPath["multireddit_rename"];
    final data = {
      _kFrom: _infoPath,
      _kTo: newName,
    };
    final response = await reddit.post(url, data);
    _name = newName;
    return response;
  }

  /// Update this [Multireddit].
  Future update(
      {final String displayName,
      final List<String> subreddits,
      final String descriptionMd,
      final IconName iconName,
      final Color color,
      final Visibility visibility,
      final WeightingScheme weightingScheme}) async {
    final newSettings = {};
    if (displayName != null) {
      newSettings[_kDisplayName] = displayName;
    }
    final newSubredditList =
        subreddits?.map((item) => {'name': item})?.toList();
    if (newSubredditList != null) {
      newSettings[_kSubreddits] = newSubredditList;
    }
    if (descriptionMd != null) {
      newSettings["description_md"] = descriptionMd;
    }
    if (iconName != null) {
      newSettings["icon_name"] = iconNameToString(iconName);
    }
    if (visibility != null) {
      newSettings[_kVisibility] = visibilityToString(visibility);
    }
    if (weightingScheme != null) {
      newSettings[_kWeightingScheme] =
          weightingSchemeToString(weightingScheme);
    }
    if (color != null) {
      newSettings["key_color"] = color.toHexColor().toString();
    }
    //Link to api docs: https://www.reddit.com/dev/api/#PUT_api_multi_{multipath}
    final res = await reddit.put(_infoPath, body: newSettings.toString());
    final Multireddit newMulti = new Multireddit.parse(reddit, res['data']);
    _name = newMulti.displayName;
    _subreddits = newMulti._subreddits;
  }
  */
}
