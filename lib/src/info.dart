import 'generated/platformconstants.dart' show PlatformMethod;
import 'platform.dart' show invoke;

/// Get android/iOS platform version
Future<String> platformVersion() async =>
    invoke(PlatformMethod.getPlatformVersion);

/// Get ably library version
Future<String> version() async => invoke(PlatformMethod.getVersion);
