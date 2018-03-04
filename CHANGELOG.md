Change Log
=================================

## Version 0.1.1 (2018/03/03)
Minor bug fix:
* Fixed issue where DRAWConfigContext would throw an exception on Android and iOS.

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
* Comment, Redditor, and Subreddit interfaces
