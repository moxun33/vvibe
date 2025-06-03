import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class UnilinkSub {
  StreamSubscription? _sub;
  bool _initialUriIsHandled = false;
  Uri? initialUri;
  Uri? latestUri;
  Object? err;

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void handleIncomingLinks(void onIncomingLinks(Uri? uri, Object? err)) {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        print('got uri: $uri');

        latestUri = uri;
        err = null;
        onIncomingLinks(uri, err);
      }, onError: (Object err) {
        print('got err: $err');

        latestUri = null;
        if (err is FormatException) {
          err = err;
        } else {
          err = Null;
        }
        onIncomingLinks(latestUri, err);
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<Uri?> handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).

    try {
      final uri = await getInitialUri();

      print('got initial uri: $uri');
      initialUri = uri;
      return uri;
    } on PlatformException {
      // Platform messages may fail but we ignore the exception
      print('falied to get initial uri');
    } on FormatException catch (e) {
      print('malformed initial uri: $e');
      err = e;
    }
  }

  void destroy() {
    _sub?.cancel();
  }
}
