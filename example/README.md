# examplediscordmanager

An example of the usage of DiscordManager using Get as a StateManager

## Getting Started

This example project is **NOT** usable without a bit of tinkering.
You will need to add your scheme in the AndroidManifest.xml and the Info.plist, as indicated by the [uni_links](https://pub.dev/packages/uni_links) documentation.


The architecture for custom schemes is already setup and you just need to replace it with your custom scheme. If you intend to use App/Deep links you'll need to add the corresponding entries yourself.


The second requirement is to edit the lib/controllers/discord_controller.dart file, adding your own clientId, ClientSecret, Callback Uri and scope to the Manager initialization.