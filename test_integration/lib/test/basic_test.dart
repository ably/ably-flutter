import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testAppKeyProvision({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final appProvisioning = AppProvisioning();

  return {
    'appKey': await appProvisioning.provisionApp(),
    'tokenRequest': await appProvisioning.getTokenRequest(),
  };
}

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
