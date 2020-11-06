import 'package:ably_flutter_integration_test/test/appkey_provision_test.dart';
import 'package:ably_flutter_integration_test/test/platform_and_ably_version_test.dart';
import 'package:ably_flutter_integration_test/test/realtime_events_test.dart';
import 'package:ably_flutter_integration_test/test/realtime_publish_test.dart';
import 'package:ably_flutter_integration_test/test/realtime_subscribe.dart';
import 'package:ably_flutter_integration_test/test/rest_publish_test.dart';
import 'package:ably_flutter_integration_test/test/rest_publish_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/test_helper_flutter_error_test.dart';
import 'package:ably_flutter_integration_test/test/test_helper_unhandled_exception_test.dart';
import 'package:ably_flutter_integration_test/test_dispatcher.dart';

import 'test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.platformAndAblyVersion: (d) => PlatformAndAblyVersionTest(d),
  TestName.appKeyProvisioning: (d) => AppKeyProvisionTest(d),
  TestName.realtimePublish: (d) => RealtimePublishTest(d),
  TestName.realtimeEvents: (d) => RealtimeEventsTest(d),
  TestName.realtimeSubscribe: (d) => RealtimeSubscribeTest(d),
  TestName.restPublish: (d) => RestPublishTest(d),
  TestName.restPublishWithAuthCallback: (d) => RestPublishWithAuthCallbackTest(d),
  TestName.testHelperFlutterErrorTest: (d) => TestHelperFlutterErrorTest(d),
  TestName.testHelperUnhandledExceptionTest: (d) =>
      TestHelperUnhandledExceptionTest(d),
};
