DRAW: The Dart Reddit API Wrapper
=================================

[![Build Status](https://travis-ci.org/draw-dev/DRAW.svg?branch=master)](https://travis-ci.org/draw-dev/DRAW/) [![Pub Version](https://img.shields.io/pub/v/draw.svg)](https://pub.dartlang.org/packages/draw) [![Coverage Status](https://coveralls.io/repos/github/draw-dev/DRAW/badge.svg?branch=master&service=github)](https://coveralls.io/github/draw-dev/DRAW?branch=master&service=github) [![Join Gitter Chat Channel -](https://badges.gitter.im/DRAW-reddit/DRAW-reddit.svg)](https://gitter.im/DRAW-reddit/DRAW?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

DRAW, also known as the Dart Reddit API Wrapper, is a Dart package that
provides simple access to the Reddit API. DRAW is inspired by
[PRAW](https://github.com/praw-dev/praw), the Python Reddit API Wrapper, and
aims to also maintain a similar interface.
 
Want to get involved? Check out [how to contribute](https://github.com/draw-dev/DRAW/blob/master/CONTRIBUTING.md) to get started!

Disclaimer: This is not an official Google product.

# Installation
Installing DRAW is simple using Dart's package management system, [pub](https://pub.dartlang.org). Instructions on how to import DRAW into your project can be found [here](https://pub.dartlang.org/packages/draw#-installing-tab-). If you would prefer to live on the hemorrhaging-edge, methods to depend on a local copy of DRAW or on the Github repository can be found [here](https://www.dartlang.org/tools/pub/dependencies).

# Getting Started
Assuming you already have your [Reddit OAuth credentials](https://github.com/reddit/reddit/wiki/OAuth2), getting started with DRAW is simple:

```dart
import 'dart:async';
import 'package:draw/draw.dart';

Future<void> main() async {
  // Create the `Reddit` instance and authenticated
  Reddit reddit = await Reddit.createScriptInstance(
    clientId: CLIENT_ID,
    clientSecret: SECRET,
    userAgent: AGENT_NAME,
    username: "DRAWApiOfficial",
    password: "hunter12", // Fake
  );

  // Retrieve information for the currently authenticated user
  Redditor currentUser = await reddit.user.me();
  // Outputs: My name is DRAWApiOfficial
  print("My name is ${currentUser.displayName}");
}
```

This simple example is a great way to confirm that DRAW is working and that your credentials have been configured correctly.

# Web Authentication
To authenticate via the Reddit authentication page, the web authentication flow needs to be used. This requires that a web application is registered with a valid Reddit account, which provides a `client-id` and a `client-secret`. As part of this process, a `redirect URL` is associated with the registered web application. These three values are all that is needed to complete the web authentication flow.

Here is a simple example of how to use web authentication with DRAW:

```dart
import 'package:draw/draw.dart';

main() async {
  final userAgent = 'foobar';
  final configUri = Uri.parse('draw.ini');

  // Create a `Reddit` instance using a configuration file in the
  // current directory.
  final reddit = Reddit.createWebFlowInstance(userAgent: userAgent,
                                              configUri: configUri);

  // Build the URL used for authentication. See `WebAuthenticator`
  // documentation for parameters.
  final auth_url = reddit.auth.url(['*'], 'foobar');

  // ...
  // Complete authentication at `auth_url` in the browser and retrieve
  // the `code` query parameter from the redirect URL.
  // ...

  // Assuming the `code` query parameter is stored in a variable
  // `auth_code`, we pass it to the `authorize` method in the
  // `WebAuthenticator`.
  await reddit.auth.authorize(auth_code);

  // If everything worked correctly, we should be able to retrieve
  // information about the authenticated account.
  print(await reddit.user.me());
}
```

It is also possible to restore cached credentials in order to avoid the need to complete the web authentication flow on each run:

```dart
import 'package:draw/draw.dart';

// Provides methods to load and save credentials.
import 'credential_loader.dart';

main() async {
  final userAgent = 'foobar';
  final configUri = Uri.parse('draw.ini');

  // Load cached credentials from disk, if available.
  final credentialsJson = await loadCredentials();

  var reddit;

  if (credentialsJson == null) {
    reddit =
        await Reddit.createWebFlowInstance(userAgent: userAgent,
                                           configUri: configUri);

    // Build the URL used for authentication. See `WebAuthenticator`
    // documentation for parameters.
    final auth_url = reddit.auth.url(['*'], 'foobar');

    // ...
    // Complete authentication at `auth_url` in the browser and retrieve
    // the `code` query parameter from the redirect URL.
    // ...

    // Assuming the `code` query parameter is stored in a variable
    // `auth_code`, we pass it to the `authorize` method in the
    // `WebAuthenticator`.
    await reddit.auth.authorize(auth_code);

    // Write credentials to disk.
    await writeCredentials(reddit.auth.credentials.toJson());
  } else {
    // Create a new Reddit instance using previously cached credentials.
    reddit = Reddit.restoreAuthenticatedInstance(
        userAgent: userAgent,
        configUri: configUri,
        credentialsJson: credentialsJson);
  }

  // If everything worked correctly, we should be able to retrieve
  // information about the authenticated account.
  print(await reddit.user.me());
}
```
# Installed Application Authentication

For usage in environments where it is impossible to keep a client secret secure, the installed application flow should be used. This requires that an installed application is registered with a valid Reddit account, which provides a `client-id`. As part of this process, a `redirect URL` is associated with the registered installed application. These two values are all that is needed to complete the installed application authentication flow.

The installed application authentication flow is almost identical to the web authentication flow described above, and it is also possible to save and restore credentials for installed applications in a similar fashion.

Here is a simple example of how to use the installed application authentication flow with DRAW:

```dart
import 'package:draw/draw.dart';

main() async {
  final userAgent = 'foobar';
  final configUri = Uri.parse('draw.ini');

  // Create a `Reddit` instance using a configuration file in the current
  // directory. Unlike the web authentication example, a client secret does
  // not need to be provided in the configuration file.
  final reddit = Reddit.createInstalledFlowInstance(userAgent: userAgent,
                                                    configUri: configUri);

  // Build the URL used for authentication. See `WebAuthenticator`
  // documentation for parameters.
  final auth_url = reddit.auth.url(['*'], 'foobar');

  // ...
  // Complete authentication at `auth_url` in the browser and retrieve
  // the `code` query parameter from the redirect URL.
  // ...

  // Assuming the `code` query parameter is stored in a variable
  // `auth_code`, we pass it to the `authorize` method in the
  // `WebAuthenticator`.
  await reddit.auth.authorize(auth_code);

  // If everything worked correctly, we should be able to retrieve
  // information about the authenticated account.
  print(await reddit.user.me());
}
```

# DRAW Configuration Files (draw.ini)

Here's an example `draw.ini` suitable for web based authentication:

```ini
default=default
reddit_url='https://www.reddit.com'
oauth_url=https://oauth.reddit.com
redirect_uri=https://www.google.com
client_id=YOUR_CLIENT_ID_HERE
client_secret=YOUR_SECRET_HERE
userAgent=draw_testing_agent
```

Here the redirect URI is set to https://www.google.com, but you'll need to replace that with whatever redirect you have registered.

The format of `draw.ini` configuration files is very similar to that of [praw.ini files used by PRAW](http://praw.readthedocs.io/en/latest/getting_started/configuration/prawini.html), although there may be some minor differences due to the .ini parser used by DRAW.

# Frequently Asked Questions (FAQ)

## Q: "I'm having trouble authenticating. What's wrong?"

Assuming the build status of DRAW is passing, there's likely something wrong
with your credentials or user-agent. Here's some things to check:

* Ensure your client ID and client secret match those provided by Reddit,
  applicable for your use case.
* Try a new value for `userAgent`. Reddit rejects requests with commonly used
  user-agents like "foobar", "testing", or "reddit", so try using a randomly
  generated user-agent to make sure this isn't the issue you're seeing.

# License
DRAW is provided under a [BSD 3-clause license](https://github.com/draw-dev/DRAW/blob/master/LICENSE). Copyright (c), 2017, the DRAW Project Authors and Google LLC.
