import 'package:flutter_driver/flutter_driver.dart';

import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

enum TestCategory { basicTests, helperTests, rest, realtime }

final _tests =
    <TestCategory, Map<String, void Function(FlutterDriver driver)>>{
  TestCategory.basicTests: {
    'should return Platform and Ably version': testPlatformAndAblyVersion,
    'should provision AppKey': testDemoDependencies,
  },
  TestCategory.helperTests: {
    'should report unhandled exception': testShouldReportUnhandledException,
  },
  TestCategory.rest: {
    'should publish': testRestPublish,
    'should retrieve history': testRestHistory,
    'conforms to publish spec': testRestPublishSpec,
    'should publish with AuthCallback': testRestPublishWithAuthCallback,
    'should get Presence Members': testRestPresenceGet,
    'should get Presence History': testRestPresenceHistory,
    'conforms to capabilitySpec': testCapabilityMatrix,
  },
  TestCategory.realtime: {
    'realtime#channels#channel#publish': testRealtimePublish,
    'should subscribe to connection and channel': testRealtimeEvents,
    'should subscribe to messages': testRealtimeSubscribe,
    'should retrieve history': testRealtimeHistory,
    'realtime#channels#channel#presence#get': testRealtimePresenceGet,
    'realtime#channels#channel#presence#history': testRealtimePresenceHistory,
    'should enter, update and leave Presence': testRealtimeEnterUpdateLeave,
    'should subscribe to channel presence': testRealtimePresenceSubscription,
  }
};

Map<TestCategory, Map<String, void Function(FlutterDriver)>>
    getTestsFor({
  bool all = false,
  List<TestCategory> groups,
}) {
  assert(groups != null || all != false);
  List<TestCategory> _groups;
  if (all) {
    _groups = _tests.keys.toList();
  } else {
    _groups = groups;
  }
  return Map.from(_tests)..removeWhere((key, value) => !_groups.contains(key));
}
