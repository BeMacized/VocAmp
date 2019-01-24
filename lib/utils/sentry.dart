import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:package_info/package_info.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/views/crash_view/crash_view.dart';

SentryClient _sentry;

initialize() async {
  PackageInfo info = await PackageInfo.fromPlatform();
  _sentry = SentryClient(
    dsn: 'https://b703979b68b643e98188d65fdf220d0f@sentry.io/1378135',
    environmentAttributes: Event(
      release: info.version + '-' + info.buildNumber,
    ),
  );
}

bool get isInDebugMode {
  // Assume we're in production mode
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code will only turn `inDebugMode` to true
  // in our development environments!
  assert(inDebugMode = true);

  return inDebugMode;
}

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  // TODO: HACKY FIX FOR UNHANDLEABLE ERRORS FROM CACHED NETWORK IMAGE DEPENDENCY
  if (error == "Couldn't download or retreive file.") return;
  // Print the exception to the console
  print('Caught error: $error');
  // Show crash view
  Application.navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => CrashView(error.toString(), stackTrace.toString()),
    ),
    (_) => false,
  );
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode
    print(stackTrace);
    return;
  } else {
    // Send the Exception and Stacktrace to Sentry in Production mode
    _sentry?.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
}
