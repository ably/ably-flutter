import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/provisioning.dart';

import '../factory/reporter.dart';

Future<Map<String, dynamic>> testAppKeyProvision({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async =>
    {
      'appKey': (await provision('sandbox-')).toString(),
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
