// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'package:color/color.dart';

import '../api_paths.dart';
import '../base.dart';
import '../base_impl.dart';
import '../reddit.dart';
import '../user.dart';
import '../exceptions.dart';
import 'redditor.dart';
import 'subreddit.dart';


enum Visibility { hidden, private, public }
String visibilityToString(Visibility visibility) {
  switch (visibility) {
    case Visibility.hidden:
      return "hidden";
      break;
    case Visibility.private:
      return "private";
      break;
    case Visibility.public:
      return "public";
      break;
    default:
      throw new DRAWInternalError('Visiblitity: $visibility is not supported');
  }
}

enum WeightingScheme { classic, fresh }
String weightingSchemeToString(WeightingScheme weightingScheme) {
  switch (weightingScheme) {
    case WeightingScheme.classic:
      return "classic";
      break;
    case WeightingScheme.fresh:
      return "fresh";
      break;
    default:
      throw new DRAWInternalError('WeightingScheme: $weightingScheme is not supported');
  }
}

//For Reference: "https://www.reddit.com/dev/api/#PUT_api_multi_{multipath}".
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

String iconNameToString(IconName iconName) {
  switch (iconName) {
    case IconName.artAndDesign:
      return "art and design";
      break;
    case IconName.ask:
      return "ask";
      break;
    case IconName.books:
      return "books";
      break;
    case IconName.business:
      return "business";
      break;
    case IconName.cars:
      return "cars";
      break;
    case IconName.comic:
      return "comics";
      break;
    case IconName.cuteAnimals:
      return "cute animals";
      break;
    case IconName.diy:
      return "diy";
      break;
    case IconName.entertainment:
      return "entertainment";
      break;
    case IconName.foodAndDrink:
      return "food and drink";
      break;
    case IconName.funny:
      return "funny";
      break;
    case IconName.games:
      return "games";
      break;
    case IconName.grooming:
      return "grooming";
      break;
    case IconName.health:
      return "health";
      break;
    case IconName.lifeAdvice:
      return "life advice";
      break;
    case IconName.military:
      return "military";
      break;
    case IconName.modelsPinup:
      return "models pinup";
      break;
    case IconName.music:
      return "music";
      break;
    case IconName.news:
      return "news";
      break;
    case IconName.philosophy:
      return "philosophy";
      break;
    case IconName.picturesAndGifs:
      return "pictures and gifs";
      break;
    case IconName.science:
      return "science";
      break;
    case IconName.shopping:
      return "shopping";
      break;
    case IconName.sports:
      return "sports";
      break;
    case IconName.style:
      return "style";
      break;
    case IconName.tech:
      return "tech";
      break;
    case IconName.travel:
      return "travel";
      break;
    case IconName.unusualStories:
      return "unusual stories";
      break;
    case IconName.video:
      return "video";
      break;
    case IconName.emptyString:
      return "";
      break;
    case IconName.none:
      return "None";
      break;
    default:
      throw new DRAWInternalError('IconName: $iconName is not supported');
  }
}

/// A class which represents a Multireddit, which is a collection of
/// [Subreddit]s.
//TODO(kchopra): Implement subreddit list storage.
class Multireddit extends RedditBase with RedditBaseInitializedMixin{

  // A number of private variables used as constants in the REST Calls.
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

  /// The [Redditor] associated with this Multireddit.
  RedditorRef get author => new RedditorRef.name(reddit, _author);
  String _author;

  List<String> get subreddits => _data['subreddits'];
  /*
  List<String> _subreddits = [];
  Future<List<String>> get loadSubreddits async => fetch()
      .then((data) => data['data']['subreddits']
      .forEach((pair) => _subreddits.add(pair["name"])));
  */

  String get displayName => data['display_name'];
  String _name;

  String get infoPath => _infoPath ?? '/';
  String _infoPath;

  Map get data => _data;
  Map _data;

  Multireddit.parse(Reddit reddit, Map data)
  : super(reddit){
    _data = data['data'];
    _name = _data['name'];
    // Based on the Reddit API, this seems to be the only way to
    // extract the name of the author.
    // TODO(@ckartik): Test if this works in the case of multireddit being,
    // the authenticated users, as the path may differ.
    _author = _data['path']?.split('/')[_redditorNameInPathIndex];
    _infoPath = _generateInfoPath(_name, _author);
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
/*
  /// Add a [Subreddit] to this [Multireddit].
  ///
  /// [subreddit] is the name of the [Subreddit] to be added to this [Multireddit].
  Future add(/* String, Subreddit */ subreddit) async {
    subreddit = _subredditNameHelper(subreddit);
    if (subreddit == null) return;
    final url = apiPath[_kMultiredditUpdate]
        .replaceAll(_userRegExp, _author)
        .replaceAll(_multiredditRegExp, _name)
        .replaceAll(_subredditRegExp, subreddit);
    final data = {'model': "{'name': $subreddit}"};
    // TODO(ckartik): Check if it may be more applicable to use POST here.
    // Direct Link: (https://www.reddit.com/dev/api/#DELETE_api_multi_{multipath}).
    await reddit.put(url, body: data);
    // TODO(ckartik): Research if we should GET subreddits.
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
*/
  /// Copy this [Multireddit], and return the new [Multireddit] of type [Future].
  ///
  /// [multiName] is an optional string that will become the display name of the new
  /// multireddit and be used as the source for the [name]. If [multiName] is not
  /// provided, the [name] of this [Multireddit] will be used.
  Future<Multireddit> copy([String multiName]) async {
    final url = apiPath['multireddit_copy'];
    final name = sluggify(multiName) ?? _data['display_name'];
    final userName = await reddit.user.me().then((me) => me.displayName);

    multiName ??= _data['display_name'];

    final data = {
      _kDisplayName: multiName,
      _kFrom: _infoPath,
      _kTo: apiPath['multireddit']
          .replaceAll(_multiredditRegExp, name)
          .replaceAll(_userRegExp, userName),
    };
    return await reddit.post(url, data);
  }

/*
  /// Delete this [Multireddit].
  Future delete() async {
    await reddit.delete(_infoPath);
  }

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
    /*
      The Reddit api requires we use the following JSON for a subreddit:
      {'name': theNameOfTheSubreddit}, for each subreddit in the list.
      For this reason we do a map here to convert back to api format.
     */
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
