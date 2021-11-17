import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../factory/reporter.dart';
import '../provisioning.dart';

Future<Map<String, dynamic>> testAppKeyProvision({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async =>
    {
      'appKey': (await createTemporaryApiKey('sandbox-')).toString(),
      'tokenRequest': await getTokenRequest(),
    };

Future<Map<String, dynamic>> testPlatformAndAblyVersion({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final platformVersion = await ably.platformVersion();
  final ablyVersion = await ably.version();

  return {
    'platformVersion': platformVersion,
    'ablyVersion': ablyVersion,
  };
}
