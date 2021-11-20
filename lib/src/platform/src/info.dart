import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Get android/iOS platform version
Future<String> platformVersion() async =>
    (await Platform.invokePlatformMethod<String>(
        PlatformMethod.getPlatformVersion))!;

/// Get ably library version
Future<String> version() async =>
    (await Platform.invokePlatformMethod<String>(PlatformMethod.getVersion))!;
