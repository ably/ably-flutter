import '../../generated/platform_constants.dart';
import '../platform.dart';

/// Get android/iOS platform version
Future<String> platformVersion() async =>
    (await Platform.invokePlatformMethod<String>(PlatformMethod.getPlatformVersion))!;

/// Get ably library version
Future<String> version() async =>
    (await Platform.invokePlatformMethod<String>(PlatformMethod.getVersion))!;
