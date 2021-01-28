import '../test_dispatcher.dart';
import 'app_key_provision_test.dart';
import 'platform_and_ably_version_test.dart';
import 'realtime_events_test.dart';
import 'realtime_history_test.dart';
import 'realtime_publish_test.dart';
import 'realtime_publish_with_auth_callback_test.dart';
import 'realtime_subscribe.dart';
import 'rest_history_test.dart';
import 'rest_presence_history_test.dart';
import 'rest_presence_test.dart';
import 'rest_publish_test.dart';
import 'rest_publish_with_auth_callback_test.dart';
import 'test_helper_flutter_error_test.dart';
import 'test_helper_unhandled_exception_test.dart';
import 'test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.platformAndAblyVersion: (d) => PlatformAndAblyVersionTest(d),
  TestName.appKeyProvisioning: (d) => AppKeyProvisionTest(d),
  TestName.realtimePublish: (d) => RealtimePublishTest(d),
  TestName.realtimeEvents: (d) => RealtimeEventsTest(d),
  TestName.realtimeSubscribe: (d) => RealtimeSubscribeTest(d),
  TestName.realtimePublishWithAuthCallback: (d) =>
      RealtimePublishWithAuthCallbackTest(d),
  TestName.restPublish: (d) => RestPublishTest(d),
  TestName.restHistory: (d) => RestHistoryTest(d),
  TestName.restPresenceGet: (d) => RestPresenceTest(d),
  TestName.restPresenceHistory: (d) => RestPresenceHistoryTest(d),
  TestName.restPublishWithAuthCallback: (d) =>
      RestPublishWithAuthCallbackTest(d),
  TestName.realtimeHistory: (d) => RealtimeHistoryTest(d),
  TestName.testHelperFlutterErrorTest: (d) => TestHelperFlutterErrorTest(d),
  TestName.testHelperUnhandledExceptionTest: (d) =>
      TestHelperUnhandledExceptionTest(d),
};
