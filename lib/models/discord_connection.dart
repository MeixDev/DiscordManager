import 'package:meta/meta.dart';
import 'dart:convert';

/// Returns a list of DiscordConnection from a JSON String list.
List<DiscordConnection> discordConnectionFromJson(String str) =>
    List<DiscordConnection>.from(
        json.decode(str).map((x) => DiscordConnection.fromJson(x)));

/// Transforms a list of DiscordPartialGuild to a JSON String list.
String discordConnectionToJson(List<DiscordConnection> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// The model of a third-party Connection from Discord.
///
/// It requires the "connections" scope.
class DiscordConnection {
  DiscordConnection({
    @required this.type,
    @required this.id,
    @required this.name,
    @required this.visibility,
    @required this.friendSync,
    @required this.showActivity,
    @required this.verified,
  });

  /// The type of connection, such as "youtube" or "spotify".
  final String type;

  /// Your user id on the said connection, such as your username, a battle tag, or a simple id.
  final String id;

  /// Your visible name on that website.
  final String name;

  /// Is the connection visible on your profile. Could be cast as a boolean (0: false // 1: true)
  final int visibility;

  /// Should Discord try to sync your friends with the ones from that account.
  final bool friendSync;

  /// Should this connection be able to show some special activity/rich presence.
  final bool showActivity;

  /// Is the account verified.
  final bool verified;

  /// Returns a new DiscordConnection from a JSON-translated Map<String, dynamic>.
  factory DiscordConnection.fromJson(Map<String, dynamic> json) =>
      DiscordConnection(
        type: json["type"],
        id: json["id"],
        name: json["name"],
        visibility: json["visibility"],
        friendSync: json["friend_sync"],
        showActivity: json["show_activity"],
        verified: json["verified"],
      );

  /// Transforms a DiscordConnection to a JSON-translatable Map<String, dynamic>.
  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "name": name,
        "visibility": visibility,
        "friend_sync": friendSync,
        "show_activity": showActivity,
        "verified": verified,
      };
}
