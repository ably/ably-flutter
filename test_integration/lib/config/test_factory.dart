import 'package:ably_flutter_integration_test/config/test_names.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/test/basic_test.dart';
import 'package:ably_flutter_integration_test/test/helpers_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_events_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_history_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_enter_update_leave.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_get.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_history_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_subscribe.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_publish_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_publish_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_subscribe.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_time_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_capability_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_history_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_presence_get_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_presence_history_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_publish_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_publish_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_time_test.dart';

typedef TestFactory = Future<Map<String, dynamic>> Function({
  required Reporter reporter,
  Map<String, dynamic>? payload,
});

final testFactory = <String, TestFactory>{
  // platform and app key tests
  TestName.platformAndAblyVersion: testPlatformAndAblyVersion,
  TestName.appKeyProvisioning: testAppKeyProvision,
  // rest tests
  TestName.restPublish: testRestPublish,
  TestName.restPublishSpec: testRestPublishSpec,
  TestName.restCapabilities: testRestCapabilities,
  TestName.restHistory: testRestHistory,
  TestName.restTime: testRestTime,
  TestName.restPublishWithAuthCallback: testRestPublishWithAuthCallback,
  TestName.restPresenceGet: testRestPresenceGet,
  TestName.restPresenceHistory: testRestPresenceHistory,
  // realtime tests
  TestName.realtimePublish: testRealtimePublish,
  TestName.realtimeEvents: testRealtimeEvents,
  TestName.realtimeSubscribe: testRealtimeSubscribe,
  TestName.realtimePublishWithAuthCallback: testRealtimePublishWithAuthCallback,
  TestName.realtimeHistory: testRealtimeHistory,
  TestName.realtimeTime: testRealtimeTime,
  TestName.realtimePresenceGet: testRealtimePresenceGet,
  TestName.realtimePresenceHistory: testRealtimePresenceHistory,
  TestName.realtimePresenceEnterUpdateLeave:
      testRealtimePresenceEnterUpdateLeave,
  TestName.realtimePresenceSubscribe: testRealtimePresenceSubscribe,
  // helper tests
  TestName.testHelperUnhandledExceptionTest: testHelperUnhandledException,
};
