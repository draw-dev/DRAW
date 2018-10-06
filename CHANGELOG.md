Change Log
=================================
## Version 0.4.4 (2019/10/06)
* Added `Modmail`, `ModmailConversation`, `ModmailMessage`, `ModmailAction` and
  `ModmailActionType`, which can be used to perform mod-mail actions.
* Added `vote` getter to `Submission` to be consistent with `Comment`.
* Marked `likes` getter in `Submission` as deprecated.

## Version 0.4.3 (2019/09/23)
* Added `nsfw` and `spoiler` parameters to `Subreddit.submit` (Thanks @LucasCLuk!)
* Fixed issue where exceptions generated during client authentication could not be caught.

## Version 0.4.2 (2018/09/10)
* Added support for flair. See documentation for `SubredditFlair` and
  `SubmissionFlair` for details.
* Updated dependency versions for Dart 2.0.

Bug fixes:
  * `PreviewImage` now automatically replaces `$amp;` with `$` ([Issue
    #104](https://github.com/draw-dev/DRAW/issues/104)).
  * Cleaned up various analyzer failures.

## Version 0.4.0 (2018/09/01)
### Major breaking changes:
`Reddit.createInstance` has been removed. Please use one of the following static methods instead:

* `createReadOnlyInstance`
* `createScriptInstance`
* `createUntrustedReadOnlyInstance`
* `createWebFlowInstance`
* `restoreAuthenticatedInstance`

## Other changes:
* Bumped SDK constraints to reflect official Dart 2.0 release.
* Added `SubmissionPreview` and `PreviewImage` which represent preview images for a `Submission`.
* Added `preview` to `Submission`, which returns a `List<SubmissionPreview>`.
* Fixed various bugs discovered while improving code coverage.

## Version 0.3.4 (2018/06/12)
### Deprecation Notice:
`Reddit.createInstance` has been deprecated and will be removed in the 0.4.0 release. Please use one of the following static methods instead:

* `createReadOnlyInstance`
* `createScriptInstance`
* `createUntrustedReadOnlyInstance`
* `createWebFlowInstance`
* `restoreAuthenticatedInstance`

### Other changes:
* Added the following static methods to `Reddit`:
  * `createWebFlowInstance`
* Added live tests to exercise the web implicit grant flow authentication mode.


## Version 0.3.3 (2018/06/08)
* Added the following static methods to `Reddit`:
  * `createReadOnlyInstance`
  * `createScriptInstance`
  * `createUntrustedReadOnlyInstance`

  This should make creating `Reddit` instances simpler and easier to debug.
* Added live tests to exercise the read-only and script authentication modes.

## Version 0.3.2 (2018/05/07)
Bug fixes:
  * Fixed additional Dart 2 runtime type errors.

## Version 0.3.1 (2018/05/06)
Bug fixes:
  * Fixed exception thrown from `WebAuthenticator` when running in Dart 2.

## Version 0.3.0 (2018/05/05)
### Major breaking changes:
Dropped support for Dart 1.x. Flutter has moved to enable Dart 2 by default
which required some changes in DRAW that are not compatible with Dart 1.x.
Some of these changes required some method signatures to be modified, but
this shouldn't require any changes for users.

If running in a command-line script, that script must be run using a dev SDK
while passing the `--preview-dart-2` flag.

If used in a Flutter application, `--preview-dart-2` is enabled by default as
of the Flutter Beta 2 release.

### Functionality:
* Basic `Multireddit` functionality:
  * Added `Multireddit.parse(reddit, data)` constructor that will create an instance of
  a `Multireddit`, given the correct `Map` of `data`.
  * Added `add(subreddit)` method to add the corresponding `subreddit` to the
    instance of `Multireddit`. `subreddit` can be of type `Subreddit` or `String`.
  * Added `delete()` method to delete the multireddit.
  * Added `copy()` and `copy(multiName)`, this will create a copy of the `Multireddit` for
    for the currently authenticated user and return an instance of the new `Multireddit`
    encapsulated as a `Future`. When `multiName` is provided it will set the display name
    of the new `Multireddit` to `multiName`.
  * Added getters for the following properties: `keyColor`, `iconName`, `subreddits`, `author`
    `displayName`, `visibility`, `weightingScheme`, `canEdit`, `over18`.
* Comment and Submission moderation.
* Miscellaneous bug fixes.

## Version 0.2.1 (2018/04/17)
* Added `Reddit.comment`, which allows for the creation of `CommentRef` objects
  from a comment ID or url.
* Added `CommentRef.populate` and `Comment.refresh`.
* Added `likes` getter to `Submission`.
* Miscellaneous fixes for minor bugs related to `CommentForest`.

## Version 0.2.0 (2018/04/13)
Breaking changes:
* `Subreddit.submissions` has been removed as the Reddit API endpoint no longer
  exists. See [this
  post](https://www.reddit.com/r/changelog/comments/7tus5f/update_to_search_api/)
  for context.

Miscellaneous:
* Added initial support for Fuchsia. draw.ini configurations are not yet
  supported on this platform.
* Loosened some version restrictions for pub packages.

## Version 0.1.6 (2018/04/08)
* Added the property `Reddit.front`, which exposes methods to retrieve content
  from the Reddit front page.

## Version 0.1.5 (2018/04/03)
* Added `Reddit.restoreAuthenticatedInstance`, which can be used to create a
  Reddit instance from previously cached credentials.
* Documentation improvements.
* Various bug fixes.

## Version 0.1.4 (2018/03/31)
* Added `SubredditModeration`, a class which implements moderator functionality for `Subreddit`s.
* Fixed issue #46 which was causing `WebAuthenticator.url` to hit an assertion when `compactLogin` was set
to `true`.

## Version 0.1.3 (2018/03/22)
* Added additional convenience accessors to various classes, including `Comment`, `Redditor`, `Submission`,
and `Subreddit`.
* Added classes `SubredditFilters` and `SubredditQuarantine`.

## Version 0.1.2 (2018/03/04)
Breaking changes:
* Removed `property` method. Properties of initialized objects that do not yet have convenience
accessors can be accessed through the `data` property
* Removed `fullname`, `id`, and `data` fields from lazily initialized objects
* Removed `refresh()` from lazily initialized objects

Miscellaneous:
* Improved documentation
* Various internal refactoring

## Version 0.1.1 (2018/03/03)
Minor bug fix:
* Fixed issue where `DRAWConfigContext` would throw an exception on Android and iOS.

## Version 0.1.0 (2018/03/03)
Breaking changes:
* Created separate classes for lazily initialized and initialized instances
* Deprecated the `property` method. Will be completely removed in the near future

Major changes and bug fixes:
* Added `Inbox` and `Message` functionality
* Added convenience accessors for common properties. Properties without an accessor can be accessed
  through the `data` map in each object
* Additional fixes to `DRAWConfigContext`
* Rolled `package:quiver` forward to version `0.28.0` to match that used by `flutter_test`

## Version 0.0.3 (2018/01/22)
Minor changes and bug fixes:
* Fixed bug that caused authentication to fail when using `draw.ini` with the `ScriptAuthenticator`
* Refactored `DRAWConfigContext`

## Version 0.0.2 (2017/12/15)
Minor updates:
* Added `CHANGELOG.md`
* Formatted sample code in `README.md`
* Renamed `.analysis_options` to `analysis_options.yaml`
* Documentation added for classes and methods that had none
* Commented out currently unimplemented functionality to clean up generated
  documents

## Version 0.0.1 (2017/12/08)
Initial release with basic functionality, including:
* OAuth2 support for login
* `Comment`, `Redditor`, and `Subreddit` interfaces
