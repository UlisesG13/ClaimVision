import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const _channel = MethodChannel('com.claimvision/screenshot_protection');

  Future<void> enable() async {
    try {
      await _channel.invokeMethod('enableScreenshotProtection');
    } on MissingPluginException {
      // No soportado en la plataforma actual
    }
  }

  Future<void> disable() async {
    try {
      await _channel.invokeMethod('disableScreenshotProtection');
    } on MissingPluginException {
      // No soportado en la plataforma actual
    }
  }
}
