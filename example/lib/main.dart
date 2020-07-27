import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:examplediscordmanager/bindings/home_binding.dart';
import 'package:examplediscordmanager/controllers/discord_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      initialRoute: '/home',
      smartManagement: SmartManagement.keepFactory,
      locale: Locale("en", "US"),
      getPages: [
        GetPage(
            name: '/home',
            page: () => HomePage(title: "Discord Manager Example"),
            binding: HomeBinding()),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends GetView {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;
  static DiscordController discordController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() {
              if (discordController.discordUser == null)
                return Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                "https://cdn.discordapp.com/embed/avatars/1.png"))));
              else
                return Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(discordController
                                .discordManager
                                .buildAvatarUrl()))));
            }),
            Obx(() {
              if (discordController.discordUser == null)
                return Text("Undefined", textScaleFactor: 1.5);
              else
                return Text(
                  discordController.discordUser.username +
                      "#" +
                      discordController.discordUser.discriminator,
                  textScaleFactor: 1.5,
                );
            }),
            SizedBox(
              height: 30,
            ),
            RaisedButton(
              child: Text("Auth Grant"),
              onPressed: () =>
                  discordController.discordManager.getAuthorizationGrant(),
            ),
            RaisedButton(
              child: Text("Refresh Token"),
              onPressed: () => discordController.discordManager.smartGetToken(),
            ),
            RaisedButton(
              child: Text("Get User @Me"),
              onPressed: () async {
                discordController.discordUser =
                    await discordController.discordManager.getUsersMe();
              },
            ),
          ],
        ),
      ),
    );
  }
}
