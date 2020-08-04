import 'package:ably_flutter_plugin/ably.dart' as ably;

import 'provisioning.dart' as provisioning;


class TestFlow{

  provisioning.AppKey appKey;
  provisionAppKey() async {
    try {
      appKey = await provisioning.provision('sandbox-');
      return true;
    } catch (error) {
      print('Error provisioning Ably: ${error}');
      return false;
    }
  }

  String platformVersion;
  getPlatformVersion() async {
    try {
      platformVersion = await ably.platformVersion();
      return true;
    } catch (error) {
      print('Error getting platform version: ${error}');
      return false;
    }
  }

  String ablyVersion;
  getAblyVersion() async {
    try {
      ablyVersion = await ably.version();
      return true;
    } catch (error) {
      print('Error getting ably version: ${error}');
      return false;
    }
  }

}
