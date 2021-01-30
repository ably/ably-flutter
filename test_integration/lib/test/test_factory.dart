import '../test_dispatcher.dart';
import 'app_key_provision_test.dart';
import 'platform_and_ably_version_test.dart';
import 'realtime_events_test.dart';
import 'realtime_history_test.dart';
import 'realtime_presence_enter_update_leave.dart';
import 'realtime_presence_get.dart';
import 'realtime_presence_history_test.dart';
import 'realtime_presence_subscribe.dart';
import 'realtime_publish_test.dart';
import 'realtime_publish_with_auth_callback_test.dart';
import 'realtime_subscribe.dart';
import 'rest_history_test.dart';
import 'rest_presence_get_test.dart';
import 'rest_presence_history_test.dart';
import 'rest_publish_test.dart';
import 'rest_publish_with_auth_callback_test.dart';
import 'test_helper_flutter_error_test.dart';
import 'test_helper_unhandled_exception_test.dart';
import 'test_names.dart';

final testFactory = <String, TestFactory>{
  // platform and app key tests
  TestName.platformAndAblyVersion: (d) => PlatformAndAblyVersionTest(d),
  TestName.appKeyProvisioning: (d) => AppKeyProvisionTest(d),
  // rest tests
  TestName.restPublish: (d) => RestPublishTest(d),
  TestName.restHistory: (d) => RestHistoryTest(d),
  TestName.restPresenceGet: (d) => RestPresenceGetTest(d),
  TestName.restPresenceHistory: (d) => RestPresenceHistoryTest(d),
  TestName.restPublishWithAuthCallback: (d) =>
      RestPublishWithAuthCallbackTest(d),
  // realtime tests
  TestName.realtimePublish: (d) => RealtimePublishTest(d),
  TestName.realtimeEvents: (d) => RealtimeEventsTest(d),
  TestName.realtimeSubscribe: (d) => RealtimeSubscribeTest(d),
  TestName.realtimePublishWithAuthCallback: (d) =>
      RealtimePublishWithAuthCallbackTest(d),
  TestName.realtimeHistory: (d) => RealtimeHistoryTest(d),
  TestName.realtimePresenceGet: (d) => RealtimePresenceGetTest(d),
  TestName.realtimePresenceHistory: (d) => RealtimePresenceHistoryTest(d),
  TestName.realtimePresenceEnterUpdateLeave: (d) =>
      RealtimePresenceEnterUpdateLeaveTest(d),
  TestName.realtimePresenceSubscribe: (d) => RealtimePresenceSubscribeTest(d),
  // helper tests
  TestName.testHelperFlutterErrorTest: (d) => TestHelperFlutterErrorTest(d),
  TestName.testHelperUnhandledExceptionTest: (d) =>
      TestHelperUnhandledExceptionTest(d),
};
