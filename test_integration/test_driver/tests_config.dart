import 'package:flutter_driver/flutter_driver.dart';

import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

enum TestGroup { basicTests, helperTests, rest, realtime }

final _tests =
    <TestGroup, Map<String, void Function(FlutterDriver Function())>>{
  TestGroup.basicTests: {
    'should return Platform and Ably version': testPlatformAndAblyVersion,
    'should provision AppKey': testDemoDependencies,
  },
  TestGroup.helperTests: {
    'should report unhandled exception': testShouldReportUnhandledException,
  },
  TestGroup.rest: {
    'should publish': testRestPublish,
    'should retrieve history': testRestHistory,
    'conforms to publish spec': testRestPublishSpec,
    'should publish with AuthCallback': testRestPublishWithAuthCallback,
    'should get Presence Members': testRestPresenceGet,
    'should get Presence History': testRestPresenceHistory,
    'conforms to capabilitySpec': testCapabilityMatrix,
  },
  TestGroup.realtime: {
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

Map<TestGroup, Map<String, void Function(FlutterDriver Function())>>
    getTestsFor({
  bool all = false,
  TestGroup? group,
  List<TestGroup>? groups,
}) {
  assert(group != null || groups != null || all != false);
  late List<TestGroup> _groups;
  if (all) {
    _groups = _tests.keys.toList();
  } else if (group != null) {
    _groups = [group];
  } else {
    _groups = groups!;
  }
  return Map.from(_tests)..removeWhere((key, value) => !_groups.contains(key));
}
