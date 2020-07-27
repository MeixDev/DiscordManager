import 'package:discord_manager/discord_manager.dart';

/// A class of useful static methods to DiscordManager.
class DiscordUtils {
  /// Converts back a list of scopes as a whitespace-separated String to a List of DiscordScope.
  static List<DiscordScope> toEnum(String str) {
    List<String> scopesStr = str.split(' ');
    List<DiscordScope> scopes = [];
    scopesStr.forEach((x) {
      scopes.add(DiscordScope.values.firstWhere((y) {
        return y
                .toString()
                .split('.')
                .last
                .toLowerCase()
                .replaceAll('_', '.') ==
            x;
      }));
    });
    return scopes;
  }

  /// Converts a list of Discorscope to their whitespace-separated string equivalent.
  static String toStr(List<DiscordScope> list) {
    List<String> scopesStr = [];
    list.forEach((x) => scopesStr.add(x.str));
    return scopesStr.join(' ');
  }
}
