// Copyright (c) 2017, the Dart Reddit API Wrapper  project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import "package:oauth2/src/handle_access_token_response.dart";

import 'draw_common.dart';

abstract class AuthorizerBase {
  AuthorizerBase(oauth2.AuthorizationCodeGrant grant)
      : _grant = grant,
        _client = null;

  void authorize(String code) {
    // TODO(bkonyi) implement.
    throw new UnimplementedError();
  }

  void revoke() {
    // TODO(bkonyi) implement.
    throw new UnimplementedError();
  }

  bool isValid() {
    return credentials?.isExpired ?? false;
  }

  // Just clears the authenticated client.
  void _clearAccessToken() {
    _client = null;
  }

  // Make a simple `GET` request.
  Future<Map> get(Uri path) async {
    return _request("GET", path);
  }

  // Request data from Reddit using our OAuth2 client.
  //
  // [type] can be one of `GET`, `POST`, and `PUT`. [path] represents the
  // request parameters.
  Future<Map> _request(String type, Uri path) async {
    // TODO(bkonyi) check for error response.
    http.Request request = new http.Request(type, path);
    final http.StreamedResponse response = await _client.send(request);
    Map parsed = JSON.decode(await response.stream.bytesToString());
    return parsed;
  }

  // Requests the authentication token from Reddit based on parameters provided
  // in [accountInfo] and [_grant].
  Future _requestToken(Map<String, String> accountInfo) async {
    if (_client != null) {
      throw new DRAWAuthorizationError('Token has already been requested.');
    }

    // Retrieve the client ID and secret.
    String clientId = _grant.identifier;
    String clientSecret = _grant.secret;

    // TODO(bkonyi) handle cases where clientSecret isn't used.
    String userInfo = '$clientId:$clientSecret';
    http.Client httpClient = new http.Client();
    DateTime start = new DateTime.now();

    // TODO(bkonyi) Check for error response.
    // Request the token from the server.
    http.Response response = await httpClient.post(
        _grant.tokenEndpoint.replace(userInfo: userInfo),
        body: accountInfo);

    // Create the Credentials object from the authentication token.
    oauth2.Credentials credentials = handleAccessTokenResponse(
        response, _grant.tokenEndpoint, start, ['*'], ',');

    // Generate the OAuth2 client that will be used to query Reddit servers.
    _client = new oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret, httpClient: httpClient);
  }

  oauth2.Credentials get credentials => _client?.credentials;

  oauth2.AuthorizationCodeGrant _grant;
  oauth2.Client _client;
}

class ScriptAuthorizer extends AuthorizerBase {
  static Future<ScriptAuthorizer> Create(oauth2.AuthorizationCodeGrant grant,
      String username, String password) async {
    ScriptAuthorizer authorizer = new ScriptAuthorizer._(grant);
    Map<String, String> accountInfo = new Map<String, String>();
    accountInfo['username'] = username;
    accountInfo['password'] = password;
    accountInfo['grant_type'] = 'password';
    accountInfo['duration'] = 'permanent';
    await authorizer._requestToken(accountInfo);
    return authorizer;
  }

  ScriptAuthorizer._(oauth2.AuthorizationCodeGrant grant) : super(grant);

  void refresh() {
    credentials.refresh();
  }
}
