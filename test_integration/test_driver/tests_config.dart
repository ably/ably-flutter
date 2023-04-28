import 'package:flutter_driver/flutter_driver.dart';
import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/crypto_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

enum TestModules { basicTests, helperTests, rest, realtime, crypto }

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
    'should publish with tokenRequest': testRestRequestTokenPublish,
    'should publish encrypted': testRestEncryptedPublish,
    'should retrieve history': testRestHistory,
    'should retrieve history with auth callback':
        testRestHistoryWithAuthCallback,
    'should retrieve time': testRestTime,
    'conforms to publish spec': testRestPublishSpec,
    'conforms to publish spec when encrypted': testRestEncryptedPublishSpec,
    'should publish with AuthCallback': testRestPublishWithAuthCallback,
    'should get Presence Members': testRestPresenceGet,
    'should get Presence History': testRestPresenceHistory,
    'conforms to capabilitySpec': testCapabilityMatrix,
  },
  TestModules.realtime: {
    'should publish': testRealtimePublish,
    'should publish encrypted': testRealtimeEncryptedPublish,
    'conforms to publish spec': testRealtimePublishSpec,
    'conforms to publish spec when encrypted': testRealtimeEncryptedPublishSpec,
    'should subscribe to connection and channel': testRealtimeEvents,
    'should subscribe to messages': testRealtimeSubscribe,
    'should retrieve history': testRealtimeHistory,
    'should retrieve history with auth callback':
        testRealtimeHistoryWithAuthCallback,
    'should retrieve time': testRealtimeTime,
    'realtime#channels#channel#presence#get': testRealtimePresenceGet,
    'realtime#channels#channel#presence#history': testRealtimePresenceHistory,
    'should enter, update and leave Presence': testRealtimeEnterUpdateLeave,
    'should subscribe to channel presence': testRealtimePresenceSubscription,
  },
  TestModules.crypto: {
    'should generate random crypto key': testCryptoGenerateRandomKey,
    'should validate supported key lengths': testCryptoEnsureSupportedKeyLength,
    'should get default params': testCryptoGetDefaultParams,
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
