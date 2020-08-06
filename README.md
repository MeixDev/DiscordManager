# DiscordManager

![Pub Version](https://img.shields.io/pub/v/discord_manager?color=blue&logo=dart) ![GitHub](https://img.shields.io/github/license/meixdev/discordmanager) 

Helper for Discord OAuth2.

The sources are fully documented if needed.

## Dependencies

- [http](https://pub.dev/packages/http) : Used to make the HTTP Requests, and works independently of the platform.
- [meta](https://pub.dev/packages/meta) : Used for code clarity such as `@required` declarations.
- [crypto](https://pub.dev/packages/crypto) : Necessary to create some the code_challenge used in the OAuth2 PKCE implementation.
- [url_launcher](https://pub.dev/packages/url_launcher) : Used to launch URLs from any platform, which is necessary to get the authorization grant code.
- [uni_links](https://pub.dev/packages/uni_links) : Supports the App/Deep Links on Android and Universal Links/Custom URL schemes on iOS. 
It is necessary to catch the callback uri from the authorization endpoint, which opened a web browser or the Discord app, and open the app back before parsing and using it.
Please note this package needs some tinkering with your AndroidManifest.xml and your Info.plist to be functional.

## Getting Started

Create a new DiscordManager object, with your clientId, clientSecret and redirectUri as required parameters. It is somewhat intended to be kept through all your app,
either with your state management architecture (Such as BLoC, MobX, or any architecture really), or with a Singleton.

It will create a HTTP Client that you should close when it becomes unneeded through the closeClient() method.

If you need to load your credentials (Which should be the case almost everytime except for the first launch), you can pass your loaded
DiscordCredentials when creating your DiscordManager. You can also pass scopes to it. Those two variables can be set later if necessary.

- Example:
```dart
  DiscordManager _discordManager = DiscordManager(
      clientId: "[client id]",
      clientSecret: "[client secret]",
      redirectUrl: "some-uri://callback",
      scopes: [
        DiscordScope.Identify,
      ]);

  // Implementation of your own way of stocking the credentials.
  _discordManager.credentials = await myDB.read('credentials');
```

## API access

DiscordManager wraps the following API calls:

- getAuthorizationGrant() : Goes through the first step of the OAuth2 flow, and requests a new grant code through user approval.
- getNewToken() : Returns a new token with the previously retrieved grant code. Requires a call to getAuthorizationGrant() beforehand.
- refreshToken() : Returns a refreshed token by using the refresh token from the user's credentials. It needs to have an initialized DiscordCredentials object.
- smartGetToken() : Calls getNewToken() or refreshToken() accordingly depending on the current credentials (Basically calls getNewToken() if there is no credentials and refreshToken() otherwise)
- revokeToken() : Is used to revoke a Specific Token from the user's credentials.

- getUsersMe() : Makes an API call to /users/@me and retrieves a DiscordUser object.
- getUsersMeGuilds() : Makes an API call to /users/@me/guilds and retrieves a list of DiscordPartialGuild objects. Can be queried with before/after ids and a limit of results (defaults to 100)
- getUsersMeConnections() : Makes an API call to /users/@me/connections and retrieves a list of DiscordConnection objects.
- get() : The function used under the others. Can be used if you need more tinkering of your calls, or if a new endpoint is available.


- buildAvatarUrl() : Returns the CDN url of the user's Discord avatar, or the default avatar corresponding to their discriminator. Can return a GIF in case of Discord Nitro users.
- buildGuildIconUrl() : Returns the CDN url of the DiscordPartialGuild passed as parameter. Can return a GIF in case of Boosted or Partenered guilds.

## TODO

- Test the revokeToken() method.
- Make the [uni_links](https://pub.dev/packages/uni_links) dependency a mobile-only dependency and do a web-based implementation of the getAuthorizationGrant() function.
