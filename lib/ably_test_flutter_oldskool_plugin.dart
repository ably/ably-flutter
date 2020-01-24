import 'dart:async';

import 'package:flutter/services.dart';

class AblyTestFlutterOldskoolPlugin {
  static const MethodChannel _channel =
      MethodChannel('ably_test_flutter_oldskool_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get ablyVersion async {
    return await _channel.invokeMethod('getAblyVersion');
  }
}
