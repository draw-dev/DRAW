# Contributing

DRAW is always looking for contributors (the more the merrier, right?), 
and if you're reading this document you must be interested in helping out!
If you're a first time contributor, welcome aboard! Otherwise, welcome back!

This document contains all the information needed to contribute to DRAW, including
how to write tests and how to prepare to create a pull request.

# Checkout
The project uses the line seperator LF in tests. In order to run tests locally on Windows, you have to configure Git to use LF on checkout, as described [here](https://help.github.com/en/articles/dealing-with-line-endings).

# Adding new features
*TODO*

# Testing

Most changes should include test cases for newly added features and bug fixes.

## Writing new tests
As you may have noticed, existing tests for DRAW do not require network access
or Reddit credentials to run. This is made possible through the use of the
[reply package](https://pub.dartlang.org/packages/reply), which allows for replaying
interactions which have requests and responses. 

Any new test for DRAW which requires a network request to be made will need to create
a recording of the requests so they can be replayed later. To create a new test, first
determine in which test directory the test belongs. If adding functionality to an existing 
class, there's likely already a directory for the tests for the class. Otherwise, create a
new directory under `$DRAW_ROOT/test/`.

DRAW uses Dart's [test package](https://pub.dartlang.org/packages/test) to handle running tests. 
All new tests should (generally) have the following format:

```dart
test('lib/$CLASS_NAME/$TEST_NAME', () async {
  final reddit = 
      await createRedditTestInstance('test/$CLASS_NAME/$TEST_NAME.json',
                                     live: true); // Perform network requests.
  // ...
  // TEST BODY HERE
  // ...
  
  // Write requests recording to 'test/$CLASS_NAME/$TEST_NAME.json'.
  // TODO: remove after recording is made.
  await writeRecording(reddit);
});
```

Both `createRedditTestInstance` and `writeRecording` are defined in `test/test_utils.dart`.
`createRedditTestInstance` creates an instance of `Reddit` which has a special authenticator
that can either record network requests or replay them, depending on the state of the `live` parameter.
`writeRecording` writes the recorded network requests to the JSON file specified when calling
`createRedditTestInstance`.

**NOTE:** Credentials used to authenticate with Reddit when running a
test in 'live' mode *are not recorded as part of the replays*, so there shouldn't be any issues
using a personal account for writing tests. However, it's highly recommended that you create a
dedicated testing account to avoid any risk of personal information being exposed.

# Creating your PR

Before creating a PR, be sure to run the following from the root of the project:
1. `dartfmt -w .`: formats all Dart code throughout the repository.
2. `dartanalyzer lib/`: run static analysis on the project's library code and ensure there are no failures
and warnings. Lints are *okay*, but fixing lint issues is preferrable to leaving them.
3. `dart test/test_all.dart`: runs all the tests for the project. All tests (except for the live
tests which authenticate with Reddit) should be passing before submission.

Checks are run for each commit and PR for the repository and changes will not be accepted if
any of the above commands produces failures.

All changes to DRAW are reviewed by a designated contributor (typically bkonyi@) before being 
merged into the master branch.
