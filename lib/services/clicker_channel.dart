import 'package:flutter/services.dart';

class ClickerChannel {
  static const _channel = MethodChannel('com.sakunia.auto_tap/clicker');

  static Future<bool> isAccessibilityEnabled() async {
    final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
    return result ?? false;
  }

  static Future<bool> canDrawOverlays() async {
    final result = await _channel.invokeMethod<bool>('canDrawOverlays');
    return result ?? false;
  }

  static Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }

  static Future<void> openOverlayPermissionSettings() async {
    await _channel.invokeMethod('openOverlayPermissionSettings');
  }

  static Future<void> showOverlay() async {
    await _channel.invokeMethod('showOverlay');
  }

  static Future<void> hideOverlay() async {
    await _channel.invokeMethod('hideOverlay');
  }

  static Future<void> stopClicking() async {
    await _channel.invokeMethod('stopClicking');
  }

  static Future<void> updateConfig({
    required int delayMs,
    required int clickCount,
  }) async {
    await _channel.invokeMethod('updateConfig', {
      'delayMs': delayMs,
      'clickCount': clickCount,
    });
  }

  static Future<Map<String, dynamic>?> getState() async {
    final result = await _channel.invokeMethod('getState');
    if (result is Map) {
      return {
        'isRunning': result['isRunning'] as bool? ?? false,
        'currentClicks': result['currentClicks'] as int? ?? 0,
      };
    }
    return null;
  }

  static void setMethodCallHandler(Future<void> Function(MethodCall call) handler) {
    _channel.setMethodCallHandler(handler);
  }
}
