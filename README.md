DRAW: The Dart Reddit API Wrapper
=================================

[![Build Status](https://travis-ci.org/draw-dev/DRAW.svg?branch=master)](https://travis-ci.org/draw-dev/DRAW/) [![Pub Version](https://img.shields.io/pub/v/draw.svg)](https://pub.dartlang.org/packages/draw)

DRAW, also known as the Dart Reddit API Wrapper, is a Dart package that
provides simple access to the Reddit API. DRAW is inspired by
[PRAW](https://github.com/praw-dev/praw), the Python Reddit API Wrapper, and
aims to also maintain a similar interface.
 
This project is in early stages, but is in active development. Check back soon
for more info!

Disclaimer: This is not an official Google product.

# Installation
Installing DRAW is simple using Dart's package management system, [pub](https://pub.dartlang.org). Instructions on how to import DRAW into your project can be found [here](https://pub.dartlang.org/packages/draw#-installing-tab-). If you would prefer to live on the hemorrhaging-edge, methods to depend on a local copy of DRAW or on the Github repository can be found [here](https://www.dartlang.org/tools/pub/dependencies).

# Getting Started
Assuming you already have your [Reddit OAuth credentials](https://github.com/reddit/reddit/wiki/OAuth2), getting started with DRAW is simple:

```dart
import 'dart:async';                                                                                                                                                                                               
import 'package:draw/draw.dart';                                                                                                                                                                                   
                                                                                                                                                                                                                   
Future main() async {                                                                                                                                                                                              
  // Create the `Reddit` instance and authenticate                                                                                                                                                                 
  Reddit reddit = await Reddit.createInstance(                                                                                                                                                                     
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

# License
DRAW is provided under a [BSD 3-clause license](https://github.com/draw-dev/DRAW/blob/master/LICENSE). Copyright (c), 2017, the DRAW Project Authors and Google LLC.
