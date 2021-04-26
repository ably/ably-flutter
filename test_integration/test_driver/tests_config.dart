import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

enum TestGroup { basicTests, helperTests, rest, realtime }

final _tests = <TestGroup, Map<String, Function>>{
  TestGroup.basicTests: {
    'should return Platform and Ably version': testPlatformAndAblyVersion,
    'should provision AppKey': testDemoDependencies,
  },
  TestGroup.rest: {
    'should publish': testRestPublish,
    'should retrieve history': testRestHistory,
    'should publish with AuthCallback': testRestPublishWithAuthCallback,
    'should get Presence Members': testRestPresenceGet,
    'should get Presence History': testRestPresenceHistory,
  },
  TestGroup.realtime: {
    'should publish': testRealtimePublish,
    'should subscribe to connection and channel': testRealtimeEvents,
    'should subscribe to messages': testRealtimeSubscribe,
    'should retrieve history': testRealtimeHistory,
    'should publish with authCallback': testRealtimePublishWithAuthCallback,
    'should get Presence Members': testRealtimePresenceGet,
    'should get Presence History': testRealtimePresenceHistory,
    'should enter, update and leave Presence': testRealtimeEnterUpdateLeave,
    'should subscribe to channel presence': testRealtimePresenceSubscription,
  },
  TestGroup.helperTests: {
    'should report unhandled exception': testShouldReportUnhandledException,
  }
};

Map<TestGroup, Map<String, Function>> getTestsFor({
  bool all = false,
  TestGroup group,
  List<TestGroup> groups,
}) {
  assert(group != null || groups != null || all != false);
  List<TestGroup> _groups;
  if (all) {
    _groups = _tests.keys.toList();
  } else if (group != null) {
    _groups = [group];
  } else {
    _groups = groups;
  }
  return Map.from(_tests)..removeWhere((key, value) => !_groups.contains(key));
}
