// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

/// A [Map] containing all of the Reddit API paths.
final Map apiPath = {
  'about_edited': 'r/{subreddit}/about/edited/',
  'about_log': 'r/{subreddit}/about/log/',
  'about_modqueue': 'r/{subreddit}/about/modqueue/',
  'about_reports': 'r/{subreddit}/about/reports/',
  'about_spam': 'r/{subreddit}/about/spam/',
  'about_sticky': 'r/{subreddit}/about/sticky/',
  'about_stylesheet': 'r/{subreddit}/about/stylesheet/',
  'about_traffic': 'r/{subreddit}/about/traffic/',
  'about_unmoderated': 'r/{subreddit}/about/unmoderated/',
  'accept_mod_invite': 'r/{subreddit}/api/accept_moderator_invite',
  'approve': 'api/approve/',
  'block': 'api/block',
  'blocked': 'prefs/blocked/',
  'comment': 'api/comment/',
  'comment_replies': 'message/comments/',
  'compose': 'api/compose/',
  'contest_mode': 'api/set_contest_mode/',
  'del': 'api/del/',
  'deleteflair': 'r/{subreddit}/api/deleteflair',
  'delete_sr_banner': 'r/{subreddit}/api/delete_sr_banner',
  'delete_sr_header': 'r/{subreddit}/api/delete_sr_header',
  'delete_sr_icon': 'r/{subreddit}/api/delete_sr_icon',
  'delete_sr_image': 'r/{subreddit}/api/delete_sr_img',
  'distinguish': 'api/distinguish/',
  'domain': 'domain/{domain}/',
  'duplicates': 'duplicates/{submission_id}/',
  'edit': 'api/editusertext/',
  'flair': 'r/{subreddit}/api/flair/',
  'flairconfig': 'r/{subreddit}/api/flairconfig/',
  'flaircsv': 'r/{subreddit}/api/flaircsv/',
  'flairlist': 'r/{subreddit}/api/flairlist/',
  'flairselector': 'r/{subreddit}/api/flairselector/',
  'flairtemplate': 'r/{subreddit}/api/flairtemplate/',
  'flairtemplateclear': 'r/{subreddit}/api/clearflairtemplates/',
  'flairtemplatedelete': 'r/{subreddit}/api/deleteflairtemplate/',
  'friend': 'r/{subreddit}/api/friend/',
  'friend_v1': 'api/v1/me/friends/{user}',
  'friends': 'api/v1/me/friends/',
  'gild_thing': 'api/v1/gold/gild/{fullname}/',
  'gild_user': 'api/v1/gold/give/{username}/',
  'hide': 'api/hide/',
  'ignore_reports': 'api/ignore_reports/',
  'inbox': 'message/inbox/',
  'info': 'api/info/',
  'karma': 'api/v1/me/karma',
  'leavecontributor': 'api/leavecontributor',
  'leavemoderator': 'api/leavemoderator',
  'list_banned': 'r/{subreddit}/about/banned/',
  'list_contributor': 'r/{subreddit}/about/contributors/',
  'list_moderator': 'r/{subreddit}/about/moderators/',
  'list_muted': 'r/{subreddit}/about/muted/',
  'list_wikibanned': 'r/{subreddit}/about/wikibanned/',
  'list_wikicontributor': 'r/{subreddit}/about/wikicontributors/',
  'live_accept_invite': 'api/live/{id}/accept_contributor_invite',
  'live_add_update': 'api/live/{id}/update',
  'live_close': 'api/live/{id}/close_thread',
  'live_contributors': 'live/{id}/contributors',
  'live_discussions': 'live/{id}/discussions',
  'live_info': 'api/live/by_id/{ids}',
  'live_invite': 'api/live/{id}/invite_contributor',
  'live_leave': 'api/live/{id}/leave_contributor',
  'live_now': 'api/live/happening_now',
  'live_remove_update': 'api/live/{id}/delete_update',
  'live_remove_contrib': 'api/live/{id}/rm_contributor',
  'live_remove_invite': 'api/live/{id}/rm_contributor_invite',
  'live_report': 'api/live/{id}/report',
  'live_strike': 'api/live/{id}/strike_update',
  'live_update_perms': 'api/live/{id}/set_contributor_permissions',
  'live_update_thread': 'api/live/{id}/edit',
  'live_updates': 'live/{id}',
  'liveabout': 'api/live/{id}/about/',
  'livecreate': 'api/live/create',
  'lock': 'api/lock/',
  'me': 'api/v1/me',
  'mentions': 'message/mentions',
  'message': 'message/messages/{id}/',
  'messages': 'message/messages/',
  'moderator_messages': 'r/{subreddit}/message/moderator/',
  'moderator_unread': 'r/{subreddit}/message/moderator/unread/',
  'morechildren': 'api/morechildren/',
  'my_contributor': 'subreddits/mine/contributor/',
  'my_moderator': 'subreddits/mine/moderator/',
  'my_multireddits': 'api/multi/mine/',
  'my_subreddits': 'subreddits/mine/subscriber/',
  'marknsfw': 'api/marknsfw/',
  'modmail_archive': 'api/mod/conversations/{id}/archive',
  'modmail_conversation': 'api/mod/conversations/{id}',
  'modmail_conversations': 'api/mod/conversations/',
  'modmail_highlight': 'api/mod/conversations/{id}/highlight',
  'modmail_mute': 'api/mod/conversations/{id}/mute',
  'modmail_read': 'api/mod/conversations/read',
  'modmail_unarchive': 'api/mod/conversations/{id}/unarchive',
  'modmail_unmute': 'api/mod/conversations/{id}/unmute',
  'modmail_unread': 'api/mod/conversations/unread',
  'multireddit': 'user/{user}/m/{multi}/',
  'multireddit_api': 'api/multi/user/{user}/m/{multi}/',
  'multireddit_base': 'api/multi/',
  'multireddit_copy': 'api/multi/copy/',
  'multireddit_rename': 'api/multi/rename/',
  'multireddit_update': 'api/multi/user/{user}/m/{multi}/r/{subreddit}',
  'multireddit_user': 'api/multi/user/{user}/',
  'mute_sender': 'api/mute_message_author/',
  'quarantine_opt_in': 'api/quarantine_optin',
  'quarantine_opt_out': 'api/quarantine_optout',
  'read_message': 'api/read_message/',
  'remove': 'api/remove/',
  'report': 'api/report/',
  'rules': 'r/{subreddit}/about/rules',
  'save': 'api/save/',
  'search': 'r/{subreddit}/search/',
  'select_flair': 'r/{subreddit}/api/selectflair/',
  'sent': 'message/sent/',
  'setpermissions': 'r/{subreddit}/api/setpermissions/',
  'spoiler': 'api/spoiler/',
  'site_admin': 'api/site_admin/',
  'sticky_submission': 'api/set_subreddit_sticky/',
  'sub_recommended': 'api/recommend/sr/{subreddits}',
  'submission': 'comments/{id}/',
  'submission_replies': 'message/selfreply/',
  'submit': 'api/submit/',
  'subreddit': 'r/{subreddit}/',
  'subreddit_about': 'r/{subreddit}/about/',
  'subreddit_filter': ('api/filter/user/{user}/f/{special}/'
      'r/{subreddit}'),
  'subreddit_filter_list': 'api/filter/user/{user}/f/{special}',
  'subreddit_random': 'r/{subreddit}/random/',
  'subreddit_settings': 'r/{subreddit}/about/edit/',
  'subreddit_stylesheet': 'r/{subreddit}/api/subreddit_stylesheet/',
  'subreddits_by_topic': 'api/subreddits_by_topic',
  'subreddits_default': 'subreddits/default/',
  'subreddits_gold': 'subreddits/gold/',
  'subreddits_new': 'subreddits/new/',
  'subreddits_popular': 'subreddits/popular/',
  'subreddits_name_search': 'api/search_reddit_names/',
  'subreddits_search': 'subreddits/search/',
  'subscribe': 'api/subscribe/',
  'suggested_sort': 'api/set_suggested_sort/',
  'unfriend': 'r/{subreddit}/api/unfriend/',
  'unhide': 'api/unhide/',
  'unignore_reports': 'api/unignore_reports/',
  'unlock': 'api/unlock/',
  'unmarknsfw': 'api/unmarknsfw/',
  'unmute_sender': 'api/unmute_message_author/',
  'unread': 'message/unread/',
  'unread_message': 'api/unread_message/',
  'unsave': 'api/unsave/',
  'unspoiler': 'api/unspoiler/',
  'upload_image': 'r/{subreddit}/api/upload_sr_img',
  'user': 'user/{user}/',
  'user_about': 'user/{user}/about/',
  'vote': 'api/vote/',
  'wiki_edit': 'r/{subreddit}/api/wiki/edit/',
  'wiki_page': 'r/{subreddit}/wiki/{page}',
  'wiki_page_editor': 'r/{subreddit}/api/wiki/alloweditor/{method}',
  'wiki_page_revisions': 'r/{subreddit}/wiki/revisions/{page}',
  'wiki_page_settings': 'r/{subreddit}/wiki/settings/{page}',
  'wiki_pages': 'r/{subreddit}/wiki/pages/',
  'wiki_revisions': 'r/{subreddit}/wiki/revisions/'
};
