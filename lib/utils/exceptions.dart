class DiscordCannotLaunchUrlException implements Exception {
  final String message;
  const DiscordCannotLaunchUrlException([this.message]);
  String toString() => message == null
      ? "DiscordCannotLaunchUrlException"
      : "DiscordCannotLaunchUrlException: $message";
}

class DiscordScopeNotSetException implements Exception {
  final String message;
  const DiscordScopeNotSetException([this.message]);
  String toString() => message == null
      ? "DiscordScopeNotSetException"
      : "DiscordScopeNotSetException: $message";
}

class DiscordCredentialsNotSetException implements Exception {
  final String message;
  const DiscordCredentialsNotSetException([this.message]);
  String toString() => message == null
      ? "DiscordCredentialsNotSetException"
      : "DiscordCredentialsNotSetException: $message";
}

class DiscordGrantCodeNotSetException implements Exception {
  final String message;
  const DiscordGrantCodeNotSetException([this.message]);
  String toString() => message == null
      ? "DiscordGrantCodeNotSetException"
      : "DiscordGrantCodeNotSetException: $message";
}

class DiscordUserNotSetException implements Exception {
  final String message;
  const DiscordUserNotSetException([this.message]);
  String toString() => message == null
      ? "DiscordUserNotSetException"
      : "DiscordUserNotSetException: $message";
}

class DiscordUnsupportedImageFormatException implements Exception {
  final String message;
  const DiscordUnsupportedImageFormatException([this.message]);
  String toString() => message == null
      ? "DiscordUnsupportedImageFormatException"
      : "DiscordUnsupportedImageFormatException: $message";
}
