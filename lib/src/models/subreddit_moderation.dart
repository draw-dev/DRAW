// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:draw/src/api_paths.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/listing/listing_generator.dart';
import 'package:draw/src/models/message.dart';
import 'package:draw/src/models/redditor.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/user_content.dart';
import 'package:draw/src/reddit.dart';

String _subredditTypeToString(SubredditType type) {
  switch (type) {
    case SubredditType.archivedSubreddit:
      return 'archived';
    case SubredditType.employeesOnlySubreddit:
      return 'employees_only';
    case SubredditType.goldOnlySubreddit:
      return 'gold_only';
    case SubredditType.goldRestrictedSubreddit:
      return 'gold_restricted';
    case SubredditType.privateSubreddit:
      return 'private';
    case SubredditType.publicSubreddit:
      return 'public';
    case SubredditType.restrictedSubreddit:
      return 'restricted';
    default:
      throw new DRAWInternalError('Invalid subreddit type: $type.');
  }
}

SubredditType _stringToSubredditType(String s) {
  switch (s) {
    case 'archived':
      return SubredditType.archivedSubreddit;
    case 'employees_only':
      return SubredditType.employeesOnlySubreddit;
    case 'gold_only':
      return SubredditType.goldOnlySubreddit;
    case 'gold_restricted':
      return SubredditType.goldRestrictedSubreddit;
    case 'private':
      return SubredditType.privateSubreddit;
    case 'public':
      return SubredditType.publicSubreddit;
    case 'restricted':
      return SubredditType.restrictedSubreddit;
    default:
      throw new DRAWInternalError("Invalid subreddit type: $s.");
  }
}

enum SubredditType {
  archivedSubreddit,
  employeesOnlySubreddit,
  goldOnlySubreddit,
  goldRestrictedSubreddit,
  privateSubreddit,
  publicSubreddit,
  restrictedSubreddit,
}

enum ModeratorActionType {
  acceptModeratorInvite,
  addContributor,
  addModerator,
  approveComment,
  approveLink,
  banUser,
  communityStyling,
  communityWidgets,
  createRule,
  deleteRule,
  distinguish,
  editFlair,
  editRule,
  editSettings,
  ignoreReports,
  inviteModerator,
  lock,
  markNSFW,
  modmailEnrollment,
  muteUser,
  removeComment,
  removeContributor,
  removeLink,
  removeModerator,
  removeWikiContributor,
  setContestMode,
  setPermissions,
  setSuggestedSort,
  spamComment,
  spamLink,
  spoiler,
  sticky,
  unbanUser,
  unignoreReports,
  uninviteModerator,
  unlock,
  unmuteUser,
  unsetContestMode,
  unspoiler,
  unsticky,
  wikiBanned,
  wikiContributor,
  wikiPageListed,
  wikiPermLevel,
  wikiRevise,
  wikiUnbanned,
}

String _moderatorActionTypesToString(ModeratorActionType a) {
  switch (a) {
    case ModeratorActionType.acceptModeratorInvite:
      return 'acceptmoderatorinvite';
    case ModeratorActionType.addContributor:
      return 'addcontributor';
    case ModeratorActionType.addModerator:
      return 'addmoderator';
    case ModeratorActionType.approveComment:
      return 'approvecomment';
    case ModeratorActionType.approveLink:
      return 'approvelink';
    case ModeratorActionType.banUser:
      return 'banuser';
    case ModeratorActionType.communityStyling:
      return 'community_styling';
    case ModeratorActionType.communityWidgets:
      return 'community_widgets';
    case ModeratorActionType.createRule:
      return 'createrule';
    case ModeratorActionType.deleteRule:
      return 'deleterule';
    case ModeratorActionType.distinguish:
      return 'distinguish';
    case ModeratorActionType.editFlair:
      return 'editflair';
    case ModeratorActionType.editRule:
      return 'editrule';
    case ModeratorActionType.editSettings:
      return 'editsettings';
    case ModeratorActionType.ignoreReports:
      return 'ignorereports';
    case ModeratorActionType.inviteModerator:
      return 'invitemoderator';
    case ModeratorActionType.lock:
      return 'lock';
    case ModeratorActionType.markNSFW:
      return 'marknsfw';
    case ModeratorActionType.modmailEnrollment:
      return 'modmail_enrollment';
    case ModeratorActionType.muteUser:
      return 'muteuser';
    case ModeratorActionType.removeComment:
      return 'removecomment';
    case ModeratorActionType.removeContributor:
      return 'removecontributor';
    case ModeratorActionType.removeLink:
      return 'removelink';
    case ModeratorActionType.removeModerator:
      return 'removemoderator';
    case ModeratorActionType.removeWikiContributor:
      return 'removewikicontributor';
    case ModeratorActionType.setContestMode:
      return 'setcontestmode';
    case ModeratorActionType.setPermissions:
      return 'setpermissions';
    case ModeratorActionType.setSuggestedSort:
      return 'setsuggestedsort';
    case ModeratorActionType.spamComment:
      return 'spamcomment';
    case ModeratorActionType.spamLink:
      return 'spamlink';
    case ModeratorActionType.spoiler:
      return 'spoiler';
    case ModeratorActionType.sticky:
      return 'sticky';
    case ModeratorActionType.unbanUser:
      return 'unbanuser';
    case ModeratorActionType.unignoreReports:
      return 'unignorereports';
    case ModeratorActionType.uninviteModerator:
      return 'uninvitemoderator';
    case ModeratorActionType.unlock:
      return 'unlock';
    case ModeratorActionType.unmuteUser:
      return 'unmuteuser';
    case ModeratorActionType.unsetContestMode:
      return 'unsetcontestmode';
    case ModeratorActionType.unspoiler:
      return 'unspoiler';
    case ModeratorActionType.unsticky:
      return 'unsticky';
    case ModeratorActionType.wikiBanned:
      return 'wikibanned';
    case ModeratorActionType.wikiContributor:
      return 'wikicontributor';
    case ModeratorActionType.wikiPageListed:
      return 'wikipagelisted';
    case ModeratorActionType.wikiPermLevel:
      return 'wikipermlevel';
    case ModeratorActionType.wikiRevise:
      return 'wikirevise';
    case ModeratorActionType.wikiUnbanned:
      return 'wikiunbanned';
    default:
      throw new DRAWInternalError('Invalid moderator action type: $a.');
  }
}

ModeratorActionType _stringToModeratorActionType(String s) {
  switch (s) {
    case 'acceptmoderatorinvite':
      return ModeratorActionType.acceptModeratorInvite;
    case 'addcontributor':
      return ModeratorActionType.addContributor;
    case 'addmoderator':
      return ModeratorActionType.addModerator;
    case 'approvecomment':
      return ModeratorActionType.approveComment;
    case 'approvelink':
      return ModeratorActionType.approveLink;
    case 'banuser':
      return ModeratorActionType.banUser;
    case 'community_styling':
      return ModeratorActionType.communityStyling;
    case 'community_widgets':
      return ModeratorActionType.communityWidgets;
    case 'createrule':
      return ModeratorActionType.createRule;
    case 'deleterule':
      return ModeratorActionType.deleteRule;
    case 'distinguish':
      return ModeratorActionType.distinguish;
    case 'editflair':
      return ModeratorActionType.editFlair;
    case 'editrule':
      return ModeratorActionType.editRule;
    case 'editsettings':
      return ModeratorActionType.editSettings;
    case 'ignorereports':
      return ModeratorActionType.ignoreReports;
    case 'invitemoderator':
      return ModeratorActionType.inviteModerator;
    case 'lock':
      return ModeratorActionType.lock;
    case 'marknsfw':
      return ModeratorActionType.markNSFW;
    case 'modmail_enrollment':
      return ModeratorActionType.modmailEnrollment;
    case 'muteuser':
      return ModeratorActionType.muteUser;
    case 'removecomment':
      return ModeratorActionType.removeComment;
    case 'removecontributor':
      return ModeratorActionType.removeContributor;
    case 'removelink':
      return ModeratorActionType.removeLink;
    case 'removemoderator':
      return ModeratorActionType.removeModerator;
    case 'removewikicontributor':
      return ModeratorActionType.removeWikiContributor;
    case 'setcontestmode':
      return ModeratorActionType.setContestMode;
    case 'setpermissions':
      return ModeratorActionType.setPermissions;
    case 'setsuggestedsort':
      return ModeratorActionType.setSuggestedSort;
    case 'spamcomment':
      return ModeratorActionType.spamComment;
    case 'spamlink':
      return ModeratorActionType.spamLink;
    case 'spoiler':
      return ModeratorActionType.spoiler;
    case 'sticky':
      return ModeratorActionType.sticky;
    case 'unbanuser':
      return ModeratorActionType.unbanUser;
    case 'unignorereports':
      return ModeratorActionType.unignoreReports;
    case 'uninvitemoderator':
      return ModeratorActionType.uninviteModerator;
    case 'unlock':
      return ModeratorActionType.unlock;
    case 'unmuteuser':
      return ModeratorActionType.unmuteUser;
    case 'unsetcontestmode':
      return ModeratorActionType.unsetContestMode;
    case 'unspoiler':
      return ModeratorActionType.unspoiler;
    case 'unsticky':
      return ModeratorActionType.unsticky;
    case 'wikibanned':
      return ModeratorActionType.wikiBanned;
    case 'wikicontributor':
      return ModeratorActionType.wikiContributor;
    case 'wikipagelisted':
      return ModeratorActionType.wikiPageListed;
    case 'wikipermlevel':
      return ModeratorActionType.wikiPermLevel;
    case 'wikirevise':
      return ModeratorActionType.wikiRevise;
    case 'wikiunbanned':
      return ModeratorActionType.wikiUnbanned;
    default:
      throw new DRAWInternalError("Invalid moderator action type: $s.");
  }
}

class SubredditSettings {
  final Map _data;
  final SubredditRef subreddit;

  SubredditSettings.copy(SubredditSettings original)
      : _data = new Map.from(original._data),
        subreddit = original.subreddit;

  SubredditSettings._(this.subreddit, this._data);

  bool get defaultSet => _data['default_set'];
  void set defaultSet(bool x) => _data['default_set'] = x;

  bool get allowImages => _data['allow_images'];
  void set allowImages(bool x) => _data['allow_images'] = x;

  bool get allowFreeformReports => _data['free_form_reports'];
  void set allowFreeformReports(bool x) => _data['free_form_reports'] = x;

  bool get showMedia => _data['show_media'];
  void set showMedia(bool x) => _data['show_media'] = x;

  int get wikiEditAge => _data['wiki_edit_age'];
  void set wikiEditAge(int x) => _data['wiki_edit_age'] = x;

  String get submitText => _data['submit_text'];
  void set submitText(String x) => _data['submit_text'] = x;

  // TODO(bkonyi): figure out what this is.
  // get spamLinks => _data['spam_links'];

  String get title => _data['title'];
  void set title(String x) => _data['title'] = x;

  bool get collapseDeletedComments => _data['collapse_deleted_comments'];
  void set collapseDeletedComments(bool x) =>
      _data['collapse_deleted_comments'] = x;

  // TODO(bkonyi): figure out what this is.
  // get wikimode => _data['wikimode'];

  bool get publicTraffic => _data['public_traffic'];
  void set publicTraffic(bool x) => _data['public_traffic'] = x;

  bool get over18 => _data['over_18'];
  void set over18(bool x) => _data['over_18'] = x;

  bool get allowVideos => _data['allow_videos'];
  void set allowVideos(bool x) => _data['allow_videos'] = x;

  bool get spoilersEnabled => _data['spoilers_enabled'];
  void set spoilersEnabled(bool x) => _data['spoilers_enabled'] = x;

  // TODO(bkonyi): figure out what this is.
  // get suggestedCommentSort => _data['suggested_comment_sort'];

  String get description => _data['description'];
  void set description(String x) => _data['description'] = x;

  String get submitLinkLabel => _data['submit_link_label'];
  void set submitLinkLabel(String x) => _data['submit_link_label'] = x;

  bool get allowPostCrossposts => _data['allow_post_crossposts'];
  void set allowPostCrossposts(bool x) => _data['allow_post_crossposts'] = x;

  // TODO(bkonyi): figure out what this is.
  // get spamComments => _data['spam_comments'];

  // TODO(bkonyi): figure out what this is.
  // get spamSelfposts => _data['spam_selfposts'];

  String get submitTextLabel => _data['submit_text_label'];
  void set submitTextLabel(String x) => _data['submit_text_label'] = x;

  // TODO(bkonyi): we might want to use a color class for this.
  // get keyColor => _data['key_color];

  String get language => _data['language'];
  void set language(String x) => _data['language'] = x;

  int get wikiEditKarma => _data['wiki_edit_karma'];
  void set wikiEditKarma(int x) => _data['wiki_edit_karma'] = x;

  bool get hideAds => _data['hide_ads'];
  void set hideAds(bool x) => _data['hide_ads'] = x;

  String get headerHoverText => _data['header_hover_text'];
  void set headerHoverText(String x) => _data['header_hover_text'] = x;

  bool get allowDiscovery => _data['allow_discovery'];
  void set allowDiscovery(bool x) => _data['allow_discovery'] = x;

  String get publicDescription => _data['public_description'];
  void set publicDescription(String x) => _data['public_description'];

  bool get showMediaPreview => _data['show_media_preview'];
  void set showMediaPreview(bool x) => _data['show_media_preview'] = x;

  int get commentScoreHideMins => _data['comment_score_hide_mins'];
  void set commentScoreHideMins(int x) => _data['comment_score_hide_mins'] = x;

  SubredditType get subredditType =>
      _stringToSubredditType(_data['subreddit_type']);

  void set subredditType(SubredditType type) {
    if (type == null) {
      throw new DRAWArgumentError("Parameter 'type' cannot be null.");
    }
    _data['subreddit_type'] = _subredditTypeToString(type);
  }

  bool get excludeBannedModQueue => _data['exclude_banned_modqueue'];
  void set excludeBannedModQueue(bool x) =>
      _data['exclude_banned_modqueue'] = x;

  // TODO(bkonyi): figure out what this is for.
  // get contentOptions => _data['content_options'];

  @override
  String toString() {
    if (_data != null) {
      final encoder = new JsonEncoder.withIndent('  ');
      return encoder.convert(_data);
    }
    return 'null';
  }
}

enum SubredditModerationContentTypeFilter {
  commentsOnly,
  submissionsOnly,
}

ModeratorAction buildModeratorAction(Reddit reddit, Map data) =>
    new ModeratorAction._(reddit, data);

/// Represents an action taken by a moderator.
class ModeratorAction {
  final Reddit _reddit;
  final Map data;
  ModeratorAction._(this._reddit, this.data);

  ModeratorActionType get action =>
      _stringToModeratorActionType(data['action']);

  RedditorRef get mod => _reddit.redditor(data['mod']);

  SubredditRef get subreddit => _reddit.subreddit(data['subreddit']);

  @override
  String toString() {
    if (data != null) {
      final encoder = new JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    }
    return 'null';
  }
}

/// Provides a set of moderation functions to a [Subreddit].
class SubredditModeration {
  static final _subredditRegExp = new RegExp(r'{subreddit}');
  final SubredditRef _subreddit;
  SubredditModeration(this._subreddit);

  Map<String, String> _buildOnlyMap(SubredditModerationContentTypeFilter only) {
    final params = <String, String>{};
    if (only != null) {
      var _only;
      if (only == SubredditModerationContentTypeFilter.submissionsOnly) {
        _only = 'links';
      } else {
        _only = 'comments';
      }
      params['only'] = _only;
    }
    return params;
  }

  Stream<T> _subredditModerationListingGeneratorHelper<T>(
          String api, SubredditModerationContentTypeFilter only, {int limit}) =>
      ListingGenerator.generator<T>(_subreddit.reddit, _formatApiPath(api),
          params: _buildOnlyMap(only), limit: limit);

  String _formatApiPath(String api) =>
      apiPath[api].replaceAll(_subredditRegExp, _subreddit.displayName);

  /// Accept an invitation to moderate the community.
  Future acceptInvite() async {
    final url = apiPath['accept_mod_invite']
        .replaceAll(_subredditRegExp, _subreddit.displayName);
    return _subreddit.reddit.post(url, {});
  }

  /// Returns a [Stream<UserContent>] of edited [Comment]s and [Submission]s.
  ///
  /// If `only` is provided, only [Comment]s or [Submission]s will be returned
  /// exclusively.
  Stream<UserContent> edited(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_edited', only,
          limit: limit);

  /// Returns a [Stream<Message>] of moderator messages.
  Stream<Message> inbox({int limit}) =>
      _subredditModerationListingGeneratorHelper('moderator_messages', null,
          limit: limit);

  /// Returns a [Stream<ModeratorAction>] of moderator log entries.
  ///
  /// If `mod` is provided, only log entries for the specified moderator(s)
  /// will be returned. `mod` can be a [RedditorRef], [List<RedditorRef>], or
  /// a [String] of comma-separated moderator names. If `type` is provided,
  /// only [ModeratorAction]s of that [ModeratorActionType] will be returned.
  Stream<ModeratorAction> log(
      {/* RedditorRef, List<RedditorRef>, String */ mod,
      ModeratorActionType type,
      int limit}) {
    final params = <String, String>{};
    if (mod != null) {
      const kMods = 'mod';
      if (mod is RedditorRef) {
        params[kMods] = mod.displayName;
      } else if (mod is List<RedditorRef>) {
        params[kMods] = mod.map((r) => r.displayName).join(',');
      } else if (mod is String) {
        params[kMods] = mod;
      } else {
        throw new DRAWArgumentError("Argument type 'mod' must be of "
            "'RedditorRef' `List<RedditorRef>`, or `String`; got "
            "${mod.runtimeType}.");
      }
    }

    if (type != null) {
      const kType = 'type';
      params[kType] = _moderatorActionTypesToString(type);
    }
    return ListingGenerator.generator(
        _subreddit.reddit, _formatApiPath('about_log'),
        limit: limit, params: params);
  }

  /// Returns a [Stream<UserContent>] of [Comment]s and [Submission]s in the
  /// mod queue.
  ///
  /// If `only` is provided, only [Comment]s or [Submission]s will be returned
  /// exclusively.
  Stream<UserContent> modQueue(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_modqueue', only,
          limit: limit);

  /// Returns a [Stream<UserContent>] of [Comment]s and [Submission]s which
  /// have been reported.
  ///
  /// If `only` is provided, only [Comment]s or [Submission]s will be returned
  /// exclusively.
  Stream<UserContent> reports(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_reports', only,
          limit: limit);

  /// Returns the current settings for the [Subreddit].
  Future<SubredditSettings> settings() async {
    final data = (await _subreddit.reddit
        .get(_formatApiPath('subreddit_settings'), objectify: false))['data'];
    return new SubredditSettings._(_subreddit, data);
  }

  /// Returns a [Stream<UserContent>] of [Comment]s and [Submission]s which
  /// have been marked as spam.
  ///
  /// If `only` is provided, only [Comment]s or [Submission]s will be returned
  /// exclusively.
  Stream<UserContent> spam(
          {SubredditModerationContentTypeFilter only, int limit}) =>
      _subredditModerationListingGeneratorHelper('about_spam', only,
          limit: limit);

  /// Returns a [Stream<UserContent>] of unmoderated [Comment]s and
  /// [Submission]s.
  Stream<UserContent> unmoderated({int limit}) =>
      _subredditModerationListingGeneratorHelper('about_unmoderated', null,
          limit: limit);

  /// Returns a [Stream<Message>] of unread moderator messages.
  Stream<Message> unread({int limit}) =>
      _subredditModerationListingGeneratorHelper<Message>(
          'moderator_unread', null,
          limit: limit);

  /// Update the [Subreddit]s settings.
  Future update(SubredditSettings updated) async {
    if (updated == null) {
      throw new DRAWArgumentError("Field 'updated' cannot be null.");
    }
    final data = new Map<String, dynamic>.from(updated._data);
    final remap = <String, String>{
      'allow_top': 'default_set',
      'lang': 'language',
      'link_type': 'content_options',
      'type': 'subreddit_type',
      'sr': 'subreddit_id',
    };

    // Remap keys to what Reddit expects (this is dumb on their part).
    remap.forEach((k, v) {
      if (data[v] != null) {
        data[k] = data[v];
        data.remove(v);
      }
    });

    // Not a valid key for the response.
    if (data.containsKey('domain')) {
      data.remove('domain');
    }

    // Cleanup the map before we send the request.
    data.forEach((k, v) {
      if (v == null) {
        data[k] = 'null';
      } else {
        data[k] = v.toString();
      }
    });

    data['api_type'] = 'json';
    return _subreddit.reddit
        .post(apiPath['site_admin'], data.cast<String, String>());
  }
}
