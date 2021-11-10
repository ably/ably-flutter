import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';

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
  final _platformVersion = await platformVersion();
  final _ablyVersion = await version();

  return {
    'platformVersion': _platformVersion,
    'ablyVersion': _ablyVersion,
  };
}
