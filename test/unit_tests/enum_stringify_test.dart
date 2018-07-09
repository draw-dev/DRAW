// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:draw/src/exceptions.dart';
import 'package:draw/src/listing/mixins/base.dart';
import 'package:draw/src/models/multireddit.dart';
import 'package:draw/src/models/mixins/user_content_moderation.dart';
import 'package:draw/src/models/submission_impl.dart';
import 'package:draw/src/models/subreddit.dart';
import 'package:draw/src/models/subreddit_moderation.dart';

void main() {
  test('commentSortTypeToString', () {
    expect(commentSortTypeToString(CommentSortType.confidence), 'confidence');
    expect(commentSortTypeToString(CommentSortType.top), 'top');
    expect(commentSortTypeToString(CommentSortType.newest), 'new');
    expect(commentSortTypeToString(CommentSortType.controversial),
        'controversial');
    expect(commentSortTypeToString(CommentSortType.old), 'old');
    expect(commentSortTypeToString(CommentSortType.random), 'random');
    expect(commentSortTypeToString(CommentSortType.qa), 'qa');
    expect(commentSortTypeToString(CommentSortType.blank), 'blank');
    expect(() => commentSortTypeToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('distinctionTypeToString', () {
    expect(distinctionTypeToString(DistinctionType.admin), 'admin');
    expect(distinctionTypeToString(DistinctionType.no), 'no');
    expect(distinctionTypeToString(DistinctionType.special), 'special');
    expect(distinctionTypeToString(DistinctionType.yes), 'yes');
    expect(() => distinctionTypeToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('iconNameToString', () {
    expect(iconNameToString(IconName.artAndDesign), 'art and design');
    expect(iconNameToString(IconName.ask), 'ask');
    expect(iconNameToString(IconName.books), 'books');
    expect(iconNameToString(IconName.business), 'business');
    expect(iconNameToString(IconName.cars), 'cars');
    expect(iconNameToString(IconName.comic), 'comics');
    expect(iconNameToString(IconName.cuteAnimals), 'cute animals');
    expect(iconNameToString(IconName.diy), 'diy');
    expect(iconNameToString(IconName.entertainment), 'entertainment');
    expect(iconNameToString(IconName.foodAndDrink), 'food and drink');
    expect(iconNameToString(IconName.funny), 'funny');
    expect(iconNameToString(IconName.games), 'games');
    expect(iconNameToString(IconName.grooming), 'grooming');
    expect(iconNameToString(IconName.health), 'health');
    expect(iconNameToString(IconName.lifeAdvice), 'life advice');
    expect(iconNameToString(IconName.military), 'military');
    expect(iconNameToString(IconName.modelsPinup), 'models pinup');
    expect(iconNameToString(IconName.music), 'music');
    expect(iconNameToString(IconName.news), 'news');
    expect(iconNameToString(IconName.philosophy), 'philosophy');
    expect(iconNameToString(IconName.picturesAndGifs), 'pictures and gifs');
    expect(iconNameToString(IconName.science), 'science');
    expect(iconNameToString(IconName.shopping), 'shopping');
    expect(iconNameToString(IconName.sports), 'sports');
    expect(iconNameToString(IconName.style), 'style');
    expect(iconNameToString(IconName.tech), 'tech');
    expect(iconNameToString(IconName.travel), 'travel');
    expect(iconNameToString(IconName.unusualStories), 'unusual stories');
    expect(iconNameToString(IconName.video), 'video');
    expect(iconNameToString(IconName.emptyString), '');
    expect(iconNameToString(IconName.none), 'None');
    expect(() => iconNameToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('moderatorActionTypeToString', () {
    expect(
        moderatorActionTypesToString(ModeratorActionType.acceptModeratorInvite),
        'acceptmoderatorinvite');
    expect(moderatorActionTypesToString(ModeratorActionType.addContributor),
        'addcontributor');
    expect(moderatorActionTypesToString(ModeratorActionType.addModerator),
        'addmoderator');
    expect(moderatorActionTypesToString(ModeratorActionType.approveComment),
        'approvecomment');
    expect(moderatorActionTypesToString(ModeratorActionType.approveLink),
        'approvelink');
    expect(
        moderatorActionTypesToString(ModeratorActionType.banUser), 'banuser');
    expect(moderatorActionTypesToString(ModeratorActionType.communityStyling),
        'community_styling');
    expect(moderatorActionTypesToString(ModeratorActionType.communityWidgets),
        'community_widgets');
    expect(moderatorActionTypesToString(ModeratorActionType.createRule),
        'createrule');
    expect(moderatorActionTypesToString(ModeratorActionType.deleteRule),
        'deleterule');
    expect(moderatorActionTypesToString(ModeratorActionType.distinguish),
        'distinguish');
    expect(moderatorActionTypesToString(ModeratorActionType.editFlair),
        'editflair');
    expect(
        moderatorActionTypesToString(ModeratorActionType.editRule), 'editrule');
    expect(moderatorActionTypesToString(ModeratorActionType.editSettings),
        'editsettings');
    expect(moderatorActionTypesToString(ModeratorActionType.ignoreReports),
        'ignorereports');
    expect(moderatorActionTypesToString(ModeratorActionType.inviteModerator),
        'invitemoderator');
    expect(moderatorActionTypesToString(ModeratorActionType.lock), 'lock');
    expect(
        moderatorActionTypesToString(ModeratorActionType.markNSFW), 'marknsfw');
    expect(moderatorActionTypesToString(ModeratorActionType.modmailEnrollment),
        'modmail_enrollment');
    expect(
        moderatorActionTypesToString(ModeratorActionType.muteUser), 'muteuser');
    expect(moderatorActionTypesToString(ModeratorActionType.removeComment),
        'removecomment');
    expect(moderatorActionTypesToString(ModeratorActionType.removeContributor),
        'removecontributor');
    expect(moderatorActionTypesToString(ModeratorActionType.removeLink),
        'removelink');
    expect(moderatorActionTypesToString(ModeratorActionType.removeModerator),
        'removemoderator');
    expect(
        moderatorActionTypesToString(ModeratorActionType.removeWikiContributor),
        'removewikicontributor');
    expect(moderatorActionTypesToString(ModeratorActionType.setContestMode),
        'setcontestmode');
    expect(moderatorActionTypesToString(ModeratorActionType.setPermissions),
        'setpermissions');
    expect(moderatorActionTypesToString(ModeratorActionType.setSuggestedSort),
        'setsuggestedsort');
    expect(moderatorActionTypesToString(ModeratorActionType.spamComment),
        'spamcomment');
    expect(
        moderatorActionTypesToString(ModeratorActionType.spamLink), 'spamlink');
    expect(
        moderatorActionTypesToString(ModeratorActionType.spoiler), 'spoiler');
    expect(moderatorActionTypesToString(ModeratorActionType.sticky), 'sticky');
    expect(moderatorActionTypesToString(ModeratorActionType.unbanUser),
        'unbanuser');
    expect(moderatorActionTypesToString(ModeratorActionType.unignoreReports),
        'unignorereports');
    expect(moderatorActionTypesToString(ModeratorActionType.uninviteModerator),
        'uninvitemoderator');
    expect(moderatorActionTypesToString(ModeratorActionType.unlock), 'unlock');
    expect(moderatorActionTypesToString(ModeratorActionType.unmuteUser),
        'unmuteuser');
    expect(moderatorActionTypesToString(ModeratorActionType.unsetContestMode),
        'unsetcontestmode');
    expect(moderatorActionTypesToString(ModeratorActionType.unspoiler),
        'unspoiler');
    expect(
        moderatorActionTypesToString(ModeratorActionType.unsticky), 'unsticky');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiBanned),
        'wikibanned');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiContributor),
        'wikicontributor');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiPageListed),
        'wikipagelisted');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiPermLevel),
        'wikipermlevel');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiRevise),
        'wikirevise');
    expect(moderatorActionTypesToString(ModeratorActionType.wikiUnbanned),
        'wikiunbanned');
    expect(() => moderatorActionTypesToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('searchSyntaxToString', () {
    expect(searchSyntaxToString(SearchSyntax.cloudSearch), 'cloudsearch');
    expect(searchSyntaxToString(SearchSyntax.lucene), 'lucene');
    expect(searchSyntaxToString(SearchSyntax.plain), 'plain');
    expect(() => searchSyntaxToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('subredditTypeToString', () {
    expect(subredditTypeToString(SubredditType.archivedSubreddit), 'archived');
    expect(subredditTypeToString(SubredditType.employeesOnlySubreddit),
        'employees_only');
    expect(subredditTypeToString(SubredditType.goldOnlySubreddit), 'gold_only');
    expect(subredditTypeToString(SubredditType.goldRestrictedSubreddit),
        'gold_restricted');
    expect(subredditTypeToString(SubredditType.privateSubreddit), 'private');
    expect(subredditTypeToString(SubredditType.publicSubreddit), 'public');
    expect(
        subredditTypeToString(SubredditType.restrictedSubreddit), 'restricted');
    expect(() => subredditTypeToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('stringToModeratorActionType', () {
    expect(stringToModeratorActionType('acceptmoderatorinvite'),
        ModeratorActionType.acceptModeratorInvite);
    expect(stringToModeratorActionType('addcontributor'),
        ModeratorActionType.addContributor);
    expect(stringToModeratorActionType('addmoderator'),
        ModeratorActionType.addModerator);
    expect(stringToModeratorActionType('approvecomment'),
        ModeratorActionType.approveComment);
    expect(stringToModeratorActionType('approvelink'),
        ModeratorActionType.approveLink);
    expect(stringToModeratorActionType('banuser'), ModeratorActionType.banUser);
    expect(stringToModeratorActionType('community_styling'),
        ModeratorActionType.communityStyling);
    expect(stringToModeratorActionType('community_widgets'),
        ModeratorActionType.communityWidgets);
    expect(stringToModeratorActionType('createrule'),
        ModeratorActionType.createRule);
    expect(stringToModeratorActionType('deleterule'),
        ModeratorActionType.deleteRule);
    expect(stringToModeratorActionType('distinguish'),
        ModeratorActionType.distinguish);
    expect(stringToModeratorActionType('editflair'),
        ModeratorActionType.editFlair);
    expect(
        stringToModeratorActionType('editrule'), ModeratorActionType.editRule);
    expect(stringToModeratorActionType('editsettings'),
        ModeratorActionType.editSettings);
    expect(stringToModeratorActionType('ignorereports'),
        ModeratorActionType.ignoreReports);
    expect(stringToModeratorActionType('invitemoderator'),
        ModeratorActionType.inviteModerator);
    expect(stringToModeratorActionType('lock'), ModeratorActionType.lock);
    expect(
        stringToModeratorActionType('marknsfw'), ModeratorActionType.markNSFW);
    expect(stringToModeratorActionType('modmail_enrollment'),
        ModeratorActionType.modmailEnrollment);
    expect(
        stringToModeratorActionType('muteuser'), ModeratorActionType.muteUser);
    expect(stringToModeratorActionType('removecomment'),
        ModeratorActionType.removeComment);
    expect(stringToModeratorActionType('removecontributor'),
        ModeratorActionType.removeContributor);
    expect(stringToModeratorActionType('removelink'),
        ModeratorActionType.removeLink);
    expect(stringToModeratorActionType('removemoderator'),
        ModeratorActionType.removeModerator);
    expect(stringToModeratorActionType('removewikicontributor'),
        ModeratorActionType.removeWikiContributor);
    expect(stringToModeratorActionType('setcontestmode'),
        ModeratorActionType.setContestMode);
    expect(stringToModeratorActionType('setpermissions'),
        ModeratorActionType.setPermissions);
    expect(stringToModeratorActionType('setsuggestedsort'),
        ModeratorActionType.setSuggestedSort);
    expect(stringToModeratorActionType('spamcomment'),
        ModeratorActionType.spamComment);
    expect(
        stringToModeratorActionType('spamlink'), ModeratorActionType.spamLink);
    expect(stringToModeratorActionType('spoiler'), ModeratorActionType.spoiler);
    expect(stringToModeratorActionType('sticky'), ModeratorActionType.sticky);
    expect(stringToModeratorActionType('unbanuser'),
        ModeratorActionType.unbanUser);
    expect(stringToModeratorActionType('unignorereports'),
        ModeratorActionType.unignoreReports);
    expect(stringToModeratorActionType('uninvitemoderator'),
        ModeratorActionType.uninviteModerator);
    expect(stringToModeratorActionType('unlock'), ModeratorActionType.unlock);
    expect(stringToModeratorActionType('unmuteuser'),
        ModeratorActionType.unmuteUser);
    expect(stringToModeratorActionType('unsetcontestmode'),
        ModeratorActionType.unsetContestMode);
    expect(stringToModeratorActionType('unspoiler'),
        ModeratorActionType.unspoiler);
    expect(
        stringToModeratorActionType('unsticky'), ModeratorActionType.unsticky);
    expect(stringToModeratorActionType('wikibanned'),
        ModeratorActionType.wikiBanned);
    expect(stringToModeratorActionType('wikicontributor'),
        ModeratorActionType.wikiContributor);
    expect(stringToModeratorActionType('wikipagelisted'),
        ModeratorActionType.wikiPageListed);
    expect(stringToModeratorActionType('wikipermlevel'),
        ModeratorActionType.wikiPermLevel);
    expect(stringToModeratorActionType('wikirevise'),
        ModeratorActionType.wikiRevise);
    expect(stringToModeratorActionType('wikiunbanned'),
        ModeratorActionType.wikiUnbanned);
    expect(() => stringToModeratorActionType(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('stringToSubredditType', () {
    expect(stringToSubredditType('archived'), SubredditType.archivedSubreddit);
    expect(stringToSubredditType('employees_only'),
        SubredditType.employeesOnlySubreddit);
    expect(stringToSubredditType('gold_only'), SubredditType.goldOnlySubreddit);
    expect(stringToSubredditType('gold_restricted'),
        SubredditType.goldRestrictedSubreddit);
    expect(stringToSubredditType('private'), SubredditType.privateSubreddit);
    expect(stringToSubredditType('public'), SubredditType.publicSubreddit);
    expect(
        stringToSubredditType('restricted'), SubredditType.restrictedSubreddit);
    expect(() => stringToSubredditType(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('timeFilterToString', () {
    expect(timeFilterToString(TimeFilter.all), 'all');
    expect(timeFilterToString(TimeFilter.day), 'day');
    expect(timeFilterToString(TimeFilter.hour), 'hour');
    expect(timeFilterToString(TimeFilter.month), 'month');
    expect(timeFilterToString(TimeFilter.week), 'week');
    expect(timeFilterToString(TimeFilter.year), 'year');
    expect(() => timeFilterToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('sortToString', () {
    expect(sortToString(Sort.comments), 'comments');
    expect(sortToString(Sort.hot), 'hot');
    expect(sortToString(Sort.newest), 'new');
    expect(sortToString(Sort.relevance), 'relevance');
    expect(sortToString(Sort.top), 'top');
    expect(() => sortToString(null), throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('visibilityToString', () {
    expect(visibilityToString(Visibility.hidden), 'hidden');
    expect(visibilityToString(Visibility.private), 'private');
    expect(visibilityToString(Visibility.public), 'public');
    expect(() => visibilityToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });

  test('weightingSchemeToString', () {
    expect(weightingSchemeToString(WeightingScheme.classic), 'classic');
    expect(weightingSchemeToString(WeightingScheme.fresh), 'fresh');
    expect(() => weightingSchemeToString(null),
        throwsA(TypeMatcher<DRAWInternalError>()));
  });
}
