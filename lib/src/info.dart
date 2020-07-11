import 'package:ably_flutter_plugin/src/generated/platformconstants.dart' show PlatformMethod;

import 'platform.dart' show invoke;


/// Get android/iOS platform version
Future<String> platformVersion() async {
  return await invoke(PlatformMethod.getPlatformVersion);
}

/// Get ably library version
Future<String> version() async {
  return await invoke(PlatformMethod.getVersion);
}
