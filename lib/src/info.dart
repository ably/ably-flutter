import 'generated/platformconstants.dart' show PlatformMethod;
import 'platform.dart' show invokePlatformMethod;

/// Get android/iOS platform version
Future<String> platformVersion() async =>
    invokePlatformMethod(PlatformMethod.getPlatformVersion);

/// Get ably library version
Future<String> version() async =>
    invokePlatformMethod(PlatformMethod.getVersion);
