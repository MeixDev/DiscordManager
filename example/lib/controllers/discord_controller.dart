import 'package:get/get.dart';
import 'package:discord_manager/discord_manager.dart';

class DiscordController extends GetxController {
  Rx<DiscordManager> _discordManager = DiscordManager(
      clientId: "[YOUR CLIENT ID]",
      clientSecret: "[YOUR CLIENT SECRET]",
      redirectUrl: "[YOUR CALLBACK URI]",
      scopes: [
        DiscordScope.Identify,
      ]).obs;

  Rx<DiscordUser> _discordUser = Rx<DiscordUser>();

  get discordManager => _discordManager.value;

  DiscordUser get discordUser => _discordUser.value;
  set discordUser(newValue) => _discordUser.value = newValue;
}
