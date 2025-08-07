import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

class FullScreenHelper {
  static Timer? _hideTimer;

  /// فعال‌سازی حالت immersiveSticky (تمام‌صفحه)
  static void enableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// شروع شنیدن gesture های کاربر و مخفی کردن دوباره دکمه‌ها
  static void attachAutoHideOnUserInteraction() {
    final gestureBinding = PlatformDispatcher.instance;

    gestureBinding.onPointerDataPacket = (PointerDataPacket packet) {
      _scheduleAutoHide();
    };
  }

  /// زمان‌بندی برای مخفی‌سازی دوباره بعد از ۲ ثانیه
  static void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      enableImmersiveMode();
    });
  }

  static void dispose() {
    _hideTimer?.cancel();
  }
}
