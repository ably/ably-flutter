import '../factory/reporter.dart';
import '../test/app_key_provision_test.dart';
import '../test/platform_and_ably_version_test.dart';
import '../test/realtime_events_test.dart';
import '../test/realtime_history_test.dart';
import '../test/realtime_presence_enter_update_leave.dart';
import '../test/realtime_presence_get.dart';
import '../test/realtime_presence_history_test.dart';
import '../test/realtime_presence_subscribe.dart';
import '../test/realtime_publish_test.dart';
import '../test/realtime_publish_with_auth_callback_test.dart';
import '../test/realtime_subscribe.dart';
import '../test/rest_history_test.dart';
import '../test/rest_presence_get_test.dart';
import '../test/rest_presence_history_test.dart';
import '../test/rest_publish_test.dart';
import '../test/rest_publish_with_auth_callback_test.dart';
import '../test/test_helper_flutter_error_test.dart';
import '../test/test_helper_unhandled_exception_test.dart';
import 'test_names.dart';

typedef TestFactory = Future<Map<String, dynamic>> Function({
  Reporter reporter,
  Map<String, dynamic> payload,
});

final testFactory = <String, TestFactory>{
  // platform and app key tests
  TestName.platformAndAblyVersion: testPlatformAndAblyVersion,
  TestName.appKeyProvisioning: testAppKeyProvision,
  // rest tests
  TestName.restPublish: testRestPublish,
  TestName.restHistory: testRestHistory,
  TestName.restPublishWithAuthCallback: testRestPublishWithAuthCallback,
  TestName.restPresenceGet: testRestPresenceGet,
  TestName.restPresenceHistory: testRestPresenceHistory,
  // realtime tests
  TestName.realtimePublish: testRealtimePublish,
  TestName.realtimeEvents: testRealtimeEvents,
  TestName.realtimeSubscribe: testRealtimeSubscribe,
  TestName.realtimePublishWithAuthCallback: testRealtimePublishWithAuthCallback,
  TestName.realtimeHistory: testRealtimeHistory,
  TestName.realtimePresenceGet: testRealtimePresenceGet,
  TestName.realtimePresenceHistory: testRealtimePresenceHistory,
  TestName.realtimePresenceEnterUpdateLeave:
      testRealtimePresenceEnterUpdateLeave,
  TestName.realtimePresenceSubscribe: testRealtimePresenceSubscribe,
  // helper tests
  TestName.testHelperFlutterErrorTest: testTestHelperFlutterError,
  TestName.testHelperUnhandledExceptionTest: testTestHelperUnhandledException,
};
