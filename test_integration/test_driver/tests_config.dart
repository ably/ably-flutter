import 'package:flutter_driver/flutter_driver.dart';

import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/push_test.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

enum TestModules { basicTests, helperTests, rest, realtime, pushNotifications }

final _tests =
    <TestModules, Map<String, void Function(FlutterDriver Function())>>{
  TestModules.basicTests: {
    'should return Platform and Ably version': testPlatformAndAblyVersion,
    'should provision AppKey': testDemoDependencies,
  },
  TestModules.helperTests: {
    'should report unhandled exception': testShouldReportUnhandledException,
  },
  TestModules.rest: {
    'should publish': testRestPublish,
    'should retrieve history': testRestHistory,
    'conforms to publish spec': testRestPublishSpec,
    'should publish with AuthCallback': testRestPublishWithAuthCallback,
    'should get Presence Members': testRestPresenceGet,
    'should get Presence History': testRestPresenceHistory,
    'conforms to capabilitySpec': testCapabilityMatrix,
  },
  TestModules.realtime: {
    'realtime#channels#channel#publish': testRealtimePublish,
    'should subscribe to connection and channel': testRealtimeEvents,
    'should subscribe to messages': testRealtimeSubscribe,
    'should retrieve history': testRealtimeHistory,
    'realtime#channels#channel#presence#get': testRealtimePresenceGet,
    'realtime#channels#channel#presence#history': testRealtimePresenceHistory,
    'should enter, update and leave Presence': testRealtimeEnterUpdateLeave,
    'should subscribe to channel presence': testRealtimePresenceSubscription,
  },
  TestModules.pushNotifications: {
    'testPushNotificationActivation': testPushNotificationActivation,
  }
};

Map<TestModules, Map<String, void Function(FlutterDriver Function())>>
    getTestsFor({
  bool all = false,
  Iterable<TestModules>? testModules,
}) {
  assert(testModules != null || all != false);
  late Iterable<TestModules> _testModules;
  if (all) {
    _testModules = _tests.keys.toList();
  } else {
    _testModules = testModules!;
  }
  return Map.from(_tests)
    ..removeWhere((key, value) => !_testModules.contains(key));
}
