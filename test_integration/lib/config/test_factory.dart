import 'package:ably_flutter_integration_test/config/test_names.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/test/basic_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_ensure_supported_key_length_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_generate_random_key_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_get_default_params.dart';
import 'package:ably_flutter_integration_test/test/helpers_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_encrypted_publish_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_events_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_history_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_history_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_enter_update_leave.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_get.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_history_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_presence_subscribe.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_publish_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_publish_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_subscribe.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_time_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_capability_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_encrypted_publish_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_history_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_history_with_auth_callback_test.dart';
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
  TestName.restEncryptedPublish: testRestEncryptedPublish,
  TestName.restPublishSpec: testRestPublishSpec,
  TestName.restEncryptedPublishSpec: testRestEncryptedPublishSpec,
  TestName.restCapabilities: testRestCapabilities,
  TestName.restHistory: testRestHistory,
  TestName.restHistoryWithAuthCallback: testRestHistoryWithAuthCallback,
  TestName.restTime: testRestTime,
  TestName.restPublishWithAuthCallback: testRestPublishWithAuthCallback,
  TestName.restPresenceGet: testRestPresenceGet,
  TestName.restPresenceHistory: testRestPresenceHistory,
  // realtime tests
  TestName.realtimePublish: testRealtimePublish,
  TestName.realtimeEncryptedPublish: testRealtimeEncryptedPublish,
  TestName.realtimePublishSpec: testRealtimePublishSpec,
  TestName.realtimeEncryptedPublishSpec: testRealtimeEncryptedPublishSpec,
  TestName.realtimeEvents: testRealtimeEvents,
  TestName.realtimeSubscribe: testRealtimeSubscribe,
  TestName.realtimePublishWithAuthCallback: testRealtimePublishWithAuthCallback,
  TestName.realtimeHistory: testRealtimeHistory,
  TestName.realtimeHistoryWithAuthCallback: testRealtimeHistoryWithAuthCallback,
  TestName.realtimeTime: testRealtimeTime,
  TestName.realtimePresenceGet: testRealtimePresenceGet,
  TestName.realtimePresenceHistory: testRealtimePresenceHistory,
  TestName.realtimePresenceEnterUpdateLeave:
      testRealtimePresenceEnterUpdateLeave,
  TestName.realtimePresenceSubscribe: testRealtimePresenceSubscribe,
  // crypto tests
  TestName.cryptoGenerateRandomKey: testCryptoGenerateRandomKey,
  TestName.cryptoEnsureSupportedKeyLength: testCryptoEnsureSupportedKeyLength,
  TestName.cryptoGetDefaultParams: testCryptoGetDefaultParams,
  // helper tests
  TestName.testHelperUnhandledExceptionTest: testHelperUnhandledException,
};
