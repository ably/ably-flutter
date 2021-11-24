import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Get android/iOS platform version
Future<String> platformVersion() async => Platform()
    .invokePlatformMethodNonNull<String>(PlatformMethod.getPlatformVersion);

/// Get ably library version
Future<String> version() async =>
    Platform().invokePlatformMethodNonNull<String>(PlatformMethod.getVersion);
