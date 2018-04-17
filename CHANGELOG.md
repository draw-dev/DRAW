Change Log
=================================
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
