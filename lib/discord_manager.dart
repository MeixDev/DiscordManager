import 'dart:convert';
import 'dart:math';

import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:discord_manager/models/discord_connection.dart';
import 'package:discord_manager/models/discord_partial_guild.dart';
import 'package:discord_manager/models/discord_user.dart';
import 'package:discord_manager/utils/discord_utils.dart';
import 'package:discord_manager/utils/exceptions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

import 'models/discord_credentials.dart';

/// A translation of Discord's OAuth2 Scopes as Dart-codified values.
///
/// Refer to Discord's documentation for the meaning of each Scope:
/// https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes
enum DiscordScope {
  Identify, // Can be used for an OAuth2 app.
  Email, // Can be used for an OAuth2 app.
  Connections, // Can be used for an OAuth2 app.
  Guilds, // Can be used for an OAuth2 app.
  Guilds_Join,
  Gdm_Join,
  Rpc, // Whitelist only
  Rpc_Api, // Whitelist only
  Rpc_Notifications_Read, // Whitelist only
  Bot,
  Webhook_Incoming, //Not supported on the Mobile Discord App
  Messages_Read,
  Applications_Builds_Upload, // Whitelist only
  Applications_Builds_Read,
  Applications_Store_Update,
  Applications_Entitlements,
  Activities_Read, // Whitelist only
  Activities_Write, // Whitelist only
  Relationships_Read // Whitelist only
}

extension ScopeToString on DiscordScope {
  /// The discord version of this scope.
  ///
  /// ```dart
  /// print(DiscordScope.Applications_Store_Update.str);
  /// ```
  /// Results in:
  /// ```
  /// applications.store.update
  /// ```
  String get str =>
      this.toString().split('.').last.toLowerCase().replaceAll('_', '.');
}

/// An enum of the available formats for images from Discord CDN.
enum DiscordImageFormat {
  JPEG,
  PNG,
  WEBP,
  GIF
}

extension FormatToString on DiscordImageFormat {
  /// The lowercase headless version of the format
  ///
  /// ```dart
  /// print(DiscordImageFormat.PNG.str);
  /// ```
  /// Results in:
  /// ```
  /// png
  /// ```
  String get str =>
      this.toString().split('.').last.toLowerCase();
}

/// An enum to select which type of Token to revoke through /token/revoke with token_type_hint
enum DiscordTokenType {
  Access_Token,
  Refresh_Token
}

extension TokenToString on DiscordTokenType {
  /// The lowercase headless version of the token type
  ///
  /// ```dart
  /// print(DiscordTokenType.Access_Token.str);
  /// ```
  /// Results in:
  /// ```
  /// access_token
  /// ```
  String get str =>
      this.toString().split('.').last.toLowerCase();
}

/// A manager for everything related to Discord's OAuth2 Flow.
class DiscordManager {
  /// The client secret of your application on Discord's Developer Portal.
  final String clientId;

  /// The client secret of your application on Discord's Developer Portal.
  final String clientSecret;

  /// The base url called to get an authorization code.
  final String authorizationEndpoint =
      "https://discord.com/api/oauth2/authorize";

  /// The base url called to get an access and a refresh token.
  final String tokenEndpoint = "https://discord.com/api/oauth2/token";

  /// The base url called to revoke an access token.
  final String revokeEndpoint = "https://discord.com/api/oauth2/token/revoke";

  /// The base url of the current Discord API.
  /// Current supported version: V6
  final String baseEndpoint = "https://discord.com/api/v6";

  final String cndEndpoint = "https://cdn.discordapp.com/";

  /// The Url Discord will use to redirect tokens if the OAuth2 flow.
  ///
  /// The best usage is to use a custom scheme that can be caught by [uni_links](https://pub.dev/packages/uni_links)
  final String redirectUrl;

  /// A simple http client.
  final Client _client = Client();

  /// Close the http client.
  closeClient() => _client.close();

  /// An instance of credentials used for the calls, and to check if the token is expired.
  ///
  /// It should be populated with stored credentials whenever possible.
  DiscordCredentials credentials;

  /// An instance of the user linked to the credentials above. It is necessary for some API calls.
  DiscordUser discordUser;

  /// A list of DiscordScope that should be set
  List<DiscordScope> scopes;

  String get scopesRaw => DiscordUtils.toStr(this.scopes);

  /// Allowed characters for generating the _codeVerifier
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// The generated PKCE code verifier
  String _codeVerifier;

  /// The code returned by the /authorize endpoint, and used to be granted an OAuth Token.
  ///
  /// It shouldn't be stored, as it's only used once.
  String _grantCode;

  DiscordManager(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.redirectUrl,
      this.credentials,
      this.scopes})
      : assert(clientId != null),
        assert(clientSecret != null),
        assert(redirectUrl != null);

  /// Randomly generate a 128 character string to be used as the PKCE code verifier
  static String _createCodeVerifier() {
    return List.generate(
        128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
  }

  /// Tries to get a grant code through the authorize endpoint.
  ///
  /// Returns false if no code was returned through the callback_uri
  Future<bool> getAuthorizationGrant() async {
    if (scopes == null)
      throw DiscordScopeNotSetException(
          "Invalid scope in getAuthorizationGrant");

    _codeVerifier = _createCodeVerifier();
    var codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(_codeVerifier)).bytes)
        .replaceAll('=', '');

    String url = authorizationEndpoint +
        "?client_id=" +
        Uri.encodeComponent(this.clientId) +
        "&redirect_uri=" +
        Uri.encodeComponent(this.redirectUrl) +
        "&response_type=code&prompt=none&scope=" +
        Uri.encodeComponent(DiscordUtils.toStr(scopes)) +
        "&code_challenge=" +
        Uri.encodeComponent(codeChallenge) +
        "&code_challenge_method=S256";

    print(url);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw DiscordCannotLaunchUrlException();
    }

    bool _returnedGrant = false;
    await getUriLinksStream().firstWhere((Uri uri) {
      print(uri.toString());
      if (uri.toString().contains("?code=")) {
        _grantCode = uri.queryParameters["code"];
        _returnedGrant = true;
        return true;
      } else {
        _returnedGrant = false;
        return false;
      }
    });

    return _returnedGrant;
  }

  /// A function calling the /token endpoint. Returns true if the credentials were retrieved and false in case the request failed.
  Future<bool> _getToken(bool isRefresh) async {
    if (scopes == null)
      throw DiscordScopeNotSetException("Invalid scope in _getToken");

    if (isRefresh) {
      if (credentials == null)
        throw DiscordCredentialsNotSetException(
            "Invalid credentials in _getToken");
    } else {
      if (_grantCode == null)
        throw DiscordGrantCodeNotSetException(
            "Invalid grant code in _getToken");
    }

    Map<String, String> body;
    if (isRefresh)
      body = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': credentials.refreshToken,
        'redirect_uri': redirectUrl,
        'scope': scopesRaw,
      };
    else
      body = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'authorization_code',
        'code': _grantCode,
        'redirect_uri': redirectUrl,
        'scope': scopesRaw,
        'code_verifier': _codeVerifier,
      };
    print("Map: " + body.toString());

    Response response;
    try {
      print("Code: " + _grantCode);
      response = await _client.post(tokenEndpoint, body: body);
    } catch (e) {
      print(e.toString());
      return false;
    }

    if (response != null) {
      print(response.body);
      credentials = DiscordCredentials.fromRawJson(response.body);
      print(credentials.toString());
      return true;
    }
    return false;
  }

  /// Calls _getToken with the objective of getting a new Token from a grant code.
  Future<bool> getNewToken() async {
    print("Getting New Token");
    return _getToken(false);
  }

  /// Calls _getToken with the objective of getting a new Token from a refresh token.
  Future<bool> refreshToken() async {
    print("Getting Refreshed Token");
    return _getToken(true);
  }

  /// Calls getNewToken() or refreshToken() accordingly depending on the state of the credentials : If no credentials were found, calls getNewToken(), otherwise it calls refreshToken().
  Future<bool> smartGetToken() async {
    if (credentials == null)
      return getNewToken();
    else
      return refreshToken();
  }

  /// A function calling the /token endpoint. Returns true if the credentials were retrieved and false in case the request failed.
  Future<bool> revokeToken(DiscordTokenType type) async {

    Map<String, String> body = {
        'token': type == DiscordTokenType.Access_Token ? credentials.accessToken : credentials.refreshToken,
        'token_type_hint': type.str,
      };
    print("Map: " + body.toString());

    Response response;
    try {
      response = await _client.post(revokeEndpoint, headers: {'Authorization': '${credentials.tokenType} ${credentials.accessToken}'}, body: body);
    } catch (e) {
      print(e.toString());
      return false;
    }

    if (response != null) {
      print(response.body);
      return true;
    }
    return false;
  }

  /// Returns the DiscordUser received from /users/@me and stores it in discordUser.
  Future<DiscordUser> getUsersMe() async {
    Response response = await get(baseEndpoint + '/users/@me');
    discordUser = DiscordUser.fromRawJson(response.body);
    return discordUser;
  }

  /// Returns a list of DiscordPartialGuild received from /users/@me/guilds.
  Future<List<DiscordPartialGuild>> getUsersMeGuilds({String before, String after, int limit}) async {
    String url = baseEndpoint + '/users/@me/guilds';
    bool hasQuery = false;
    if (before != null) {
      if (!hasQuery) url += "?before=";
      else url += "&before=";
      hasQuery = true;
      url += Uri.encodeComponent(before);
    }
    if (after != null) {
      if (!hasQuery) url += "?after=";
      else url += "&after=";
      hasQuery = true;
      url += Uri.encodeComponent(after);
    }
    if (limit != null) {
      if (!hasQuery) url += "?limit=";
      else url += "&limit=";
      hasQuery = true;
      url += Uri.encodeComponent(limit.toString());
    }
    print(url);
    Response response = await get(url);
    return discordPartialGuildFromJson(response.body);
  }

  /// Returns a list of DiscordConnections received from /users/@me/connections.
  Future<List<DiscordConnection>> getUsersMeConnections() async {
    Response response = await get(baseEndpoint + '/users/@me/connections');
    return discordConnectionFromJson(response.body);
  }

  /// Used to do all the API calls of the manager. Is smart enough to refresh the token beforehand if it seems to be expired.
  ///
  /// It can be called directly if needed, although through my understanding there a no others API calls available through the OAuth2 API as of now.
  Future<Response> get(String apiEndpoint) async {
    if (credentials == null)
      throw DiscordCredentialsNotSetException("Invalid credentials in get");
    if (credentials.expireInstant.isAfter(DateTime.now()))
      await refreshToken();
    try {
      return _client.get(apiEndpoint, headers: {'Authorization': '${credentials.tokenType} ${credentials.accessToken}'});
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  /// Returns the string of the URL of the avatar of a Discord User. Uses the internally loaded user.
  String buildAvatarUrl({DiscordImageFormat format = DiscordImageFormat.PNG}) {
    if (discordUser == null)
      throw DiscordUserNotSetException("User not set in buildAvatarUrl");
    if (discordUser.avatar == null) {
      // Defaults to PNG if default avatar must be used
      format = DiscordImageFormat.PNG;
      // throw DiscordUnsupportedImageFormatException("Default User Avatar is only available as a PNG");
      final int discriminator = int.parse(discordUser.discriminator) % 5;
      return cndEndpoint + "embed/avatars/" + discriminator.toString() + format.str;
    }
    if (format == DiscordImageFormat.GIF) {
      // Default to PNG if the image can't be used as a GIF
      if (!discordUser.avatar.contains("a_")) format = DiscordImageFormat.PNG;
    }
    return cndEndpoint + "avatars/" + discordUser.id + "/" + discordUser.avatar + "." + format.str;
  }

  /// Returns the string of the URL of the icon of a Discord Guild. A DiscordPartialGuild item must be used as a parameter.
  String buildGuildIconUrl(DiscordPartialGuild guild, {DiscordImageFormat format = DiscordImageFormat.PNG}) {
    if (format == DiscordImageFormat.GIF) {
      // Default to PNG if the image can't be used as a GIF
      if (!guild.icon.contains("a_")) format = DiscordImageFormat.PNG;
    }
    return cndEndpoint + "icons/" + guild.id + "/" + guild.icon + "." + format.str;
  }
}
