import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:discord_manager/discord_manager.dart';
import 'package:discord_manager/utils/discord_utils.dart';

class DiscordCredentials {
  DiscordCredentials({
    @required this.accessToken,
    @required this.tokenType,
    @required this.expiresIn,
    @required this.refreshToken,
    @required this.scope,
  }) {
    expireInstant = DateTime.now().add(Duration(seconds: this.expiresIn - 800));
  }

  /// The current accessToken of the user.
  final String accessToken;

  /// The token type of the user. In most cases, it should be "Bearer"
  final String tokenType;

  /// The number of seconds until the current [accessToken] gets expired.
  final int expiresIn;

  /// The refresh token used to refresh the [accessToken].
  final String refreshToken;

  /// The scopes allowed by the OAuth2 flow, they're whitespace-separated.
  final String scope;

  /// List of the scopes allowed by the OAuth2 flow, as DiscordScope.
  List<DiscordScope> get scopesEnum => DiscordUtils.toEnum(scope);

  /// DateTime when the token will get expired, for comparison purposes.
  ///
  /// It is actually slightly lower than the real expires_in, of 800 seconds, in order to avoid weird situations where the token could expire between the check and the API call.
  DateTime expireInstant;

  /// Returns a new DiscordCredentials with the same values as before except for those explicitly changed.
  DiscordCredentials copyWith({
    String accessToken,
    String tokenType,
    int expiresIn,
    String refreshToken,
    String scope,
  }) =>
      DiscordCredentials(
        accessToken: accessToken ?? this.accessToken,
        tokenType: tokenType ?? this.tokenType,
        expiresIn: expiresIn ?? this.expiresIn,
        refreshToken: refreshToken ?? this.refreshToken,
        scope: scope ?? this.scope,
      );

  /// Returns a new DiscordCredentials from a JSON String.
  factory DiscordCredentials.fromRawJson(String str) =>
      DiscordCredentials.fromJson(json.decode(str));

  /// Transforms a DiscordCredentials to a JSON String.
  String toRawJson() => json.encode(toJson());

  /// Returns a new DiscordCredentials from a JSON-translated Map<String, dynamic>.
  factory DiscordCredentials.fromJson(Map<String, dynamic> json) =>
      DiscordCredentials(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
        refreshToken: json["refresh_token"],
        scope: json["scope"],
      );

  /// Transforms a DiscordCredentials to a JSON-translatable Map<String, dynamic>.
  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
        "refresh_token": refreshToken,
        "scope": scope,
      };

  @override
  String toString() {
    return '''Discord Credentials [[[
    |   Access Token: $accessToken
    |   Token Type: $tokenType
    |   Expires In: $expiresIn
    |   Expire Instant: ${expireInstant.toString()}
    |   Refresh Token: $refreshToken
    |   Scope: $scope
    ]]]''';
  }
}
