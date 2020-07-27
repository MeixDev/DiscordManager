import 'package:get/get.dart';
import 'package:examplediscordmanager/controllers/discord_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscordController>(() => DiscordController());
  }
}
