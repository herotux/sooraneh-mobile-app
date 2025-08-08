import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FullScreenHelper {
  static void enableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  static void disableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  static void attachAutoHideOnUserInteraction() {
    // فقط یک بار فعال شود
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == 'AppLifecycleState.resumed') {
        enableImmersiveMode();
      }
      return Future.value();
    });
  }

  static void dispose() {
    SystemChannels.lifecycle.setMessageHandler(null);
  }
}