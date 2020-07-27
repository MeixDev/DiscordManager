import 'package:meta/meta.dart';
import 'dart:convert';

/// The model of an User Object from Discord.
///
/// It requires the "identify" scope. Some parameters may require more.
class DiscordUser {
  DiscordUser({
    @required this.id,
    @required this.username,
    @required this.avatar,
    @required this.discriminator,
    this.publicFlags,
    this.flags,
    this.email,
    this.verified,
    this.locale,
    this.mfaEnabled,
    this.premiumType,
    this.bot,
    this.system,
  });

  /// The unique uid of an user.
  final String id;

  /// The username of an user. It is NOT unique across the platform.
  final String username;

  /// The user's [avatar hash](https://discord.com/developers/docs/reference#image-formatting).
  ///
  /// It is technically required, but it can be null if the user doesn't have an avatar.
  /// In such case, it is still possible to get their "Basic" discord avatar through their discriminator.
  final String avatar;

  /// The user's 4-digit discord-tag.
  final String discriminator;

  /// The public [flags](https://discord.com/developers/docs/resources/user#user-object-user-flags) on an user's account.
  final int publicFlags;

  /// The [flags](https://discord.com/developers/docs/resources/user#user-object-user-flags) on an user's account.
  final int flags;

  /// The user's email.
  ///
  /// It is only returned if the app has the "email" scope in addition to identify.
  final String email;

  /// Whether the email on this account has been verified or not.
  ///
  /// It is only returned if the app has the "email" scope in addition to identify.
  final bool verified;

  /// The user's chosen language option.
  final String locale;

  /// Whether the user has two factor enabled on their account.
  final bool mfaEnabled;

  /// The type of [Nitro subscription](https://discord.com/developers/docs/resources/user#user-object-premium-types) on an user's account.
  final int premiumType;

  /// Whether the user belongs to an OAuth2 application.
  final bool bot;

  /// Whether the user is an Official Discord System user (part of the urgence message system).
  final bool system;

  /// Returns a new DiscordUser from a JSON String.
  factory DiscordUser.fromRawJson(String str) =>
      DiscordUser.fromJson(json.decode(str));

  /// Transforms a DiscordUser to a JSON String.
  String toRawJson() => json.encode(toJson());

  /// Returns a new DiscordUser from a JSON-translated Map<String, dynamic>.
  factory DiscordUser.fromJson(Map<String, dynamic> json) => DiscordUser(
        id: json["id"],
        username: json["username"],
        avatar: json["avatar"],
        discriminator: json["discriminator"],
        publicFlags: json["public_flags"] ?? null,
        flags: json["flags"] ?? null,
        email: json["email"] ?? null,
        verified: json["verified"] ?? null,
        locale: json["locale"] ?? null,
        mfaEnabled: json["mfa_enabled"] ?? null,
        premiumType: json["premium_type"] ?? null,
        bot: json["bot"] ?? null,
        system: json["system"] ?? null,
      );

  /// Transforms a DiscordUser to a JSON-translatable Map<String, dynamic>.
  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "avatar": avatar,
        "discriminator": discriminator,
        "public_flags": publicFlags ?? null,
        "flags": flags ?? null,
        "email": email ?? null,
        "verified": verified ?? null,
        "locale": locale ?? null,
        "mfa_enabled": mfaEnabled ?? null,
        "premium_type": premiumType ?? null,
        "bot": bot ?? null,
        "system": system ?? null,
      };

  @override
  String toString() {
    return '''Discord User [[[
    |   User Id: $id
    |   Username: $username
    |   Avatar Hash: $avatar
    |   Discriminator: $discriminator
    |   Flags: $flags
    |   Public Flags: $publicFlags
    |   Locale: $locale
    |   Mfa Enabled: $mfaEnabled
    |   Premium Type: $premiumType
    |   Bot: $bot
    |   System: $system
    |   Email: $email
    |   Verified: $verified
    ]]]''';
  }
}
