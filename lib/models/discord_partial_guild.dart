import 'package:meta/meta.dart';
import 'dart:convert';

/// Returns a list of DiscordPartialGuild from a JSON String list.
List<DiscordPartialGuild> discordPartialGuildFromJson(String str) => List<DiscordPartialGuild>.from(json.decode(str).map((x) => DiscordPartialGuild.fromJson(x)));

/// Transforms a list of DiscordPartialGuild to a JSON String list.
String discordPartialGuildToJson(List<DiscordPartialGuild> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// The model of a Partial Guild Object from Discord.
///
/// It requires the "guilds" scope.
class DiscordPartialGuild {
  DiscordPartialGuild({
    @required this.id,
    @required this.name,
    @required this.icon,
    @required this.owner,
    @required this.permissions,
    @required this.features,
    @required this.permissionsNew,
  });

  /// The id of the guild.
  final String id;

  /// The current name of the guild.
  final String name;

  /// The hash of the icon of the guild.
  final String icon;

  /// Whether the user linked to the access token is the owner of the server or not.
  final bool owner;

  /// The permissions the user has in the server. It uses bit-shifting.
  final int permissions;

  /// A list of features the server has, such as a banner, animated icon, etc.
  final List<Feature> features;

  /// ???.
  final String permissionsNew;

  /// Returns a new DiscordPartialGuild from a JSON-translated Map<String, dynamic>.
  factory DiscordPartialGuild.fromJson(Map<String, dynamic> json) => DiscordPartialGuild(
    id: json["id"],
    name: json["name"],
    icon: json["icon"] == null ? null : json["icon"],
    owner: json["owner"],
    permissions: json["permissions"],
    features: List<Feature>.from(json["features"].map((x) => featureValues.map[x])),
    permissionsNew: json["permissions_new"],
  );

  /// Transforms a DiscordPartialGuild to a JSON-translatable Map<String, dynamic>.
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon": icon == null ? null : icon,
    "owner": owner,
    "permissions": permissions,
    "features": List<dynamic>.from(features.map((x) => featureValues.reverse[x])),
    "permissions_new": permissionsNew,
  };
}

/// The features a server can add, mostly through Discord Partnership, or through Discord Boosting.
enum Feature { NEWS, VIP_REGIONS, BANNER, ANIMATED_ICON, INVITE_SPLASH, PARTNERED, VANITY_URL, DISCOVERABLE, WELCOME_SCREEN_ENABLED, COMMUNITY, ENABLED_DISCOVERABLE_BEFORE, COMMERCE, FEATURABLE, VERIFIED }

/// Instance of EnumValues which converts Strings to the Feature Enum.
final featureValues = EnumValues({
  "ANIMATED_ICON": Feature.ANIMATED_ICON,
  "BANNER": Feature.BANNER,
  "COMMERCE": Feature.COMMERCE,
  "COMMUNITY": Feature.COMMUNITY,
  "DISCOVERABLE": Feature.DISCOVERABLE,
  "ENABLED_DISCOVERABLE_BEFORE": Feature.ENABLED_DISCOVERABLE_BEFORE,
  "FEATURABLE": Feature.FEATURABLE,
  "INVITE_SPLASH": Feature.INVITE_SPLASH,
  "NEWS": Feature.NEWS,
  "PARTNERED": Feature.PARTNERED,
  "VANITY_URL": Feature.VANITY_URL,
  "VERIFIED": Feature.VERIFIED,
  "VIP_REGIONS": Feature.VIP_REGIONS,
  "WELCOME_SCREEN_ENABLED": Feature.WELCOME_SCREEN_ENABLED
});

/// Converts Strings to the an Enum.
class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
