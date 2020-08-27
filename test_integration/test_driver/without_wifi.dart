import 'package:ably_flutter_integration_test/main.dart' as app;

import 'package:ably_flutter_integration_test/test/appkey_provision_test.dart';
import 'package:ably_flutter_integration_test/test/platform_and_ably_version_test.dart';
import 'package:ably_flutter_integration_test/test_dispatcher.dart';
import 'package:ably_flutter_integration_test/test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.platformAndAblyVersion: (d) => PlatformAndAblyVersionTest(d),
  TestName.appKeyProvisioning: (d) => AppKeyProvisionTest(d),
};

void main() => app.main(testFactory);
