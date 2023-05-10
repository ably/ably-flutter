import 'package:ably_flutter_integration_test/config/test_names.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/test/basic_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_ensure_supported_key_length_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_generate_random_key_test.dart';
import 'package:ably_flutter_integration_test/test/crypto/crypto_get_default_params.dart';
import 'package:ably_flutter_integration_test/test/helpers_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_auth_client_id_test.dart';
import 'package:ably_flutter_integration_test/test/realtime/realtime_auth_url_test.dart';
import 'package:ably_flutter_integration_test/test/realtime'
    '/realtime_authorize_test'
    '.dart';
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
import 'package:ably_flutter_integration_test/test/rest/rest_auth_client_id_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_authorize_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_capability_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_create_token_request_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_encrypted_publish_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_history_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_history_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_presence_get_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_presence_history_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_publish_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_publish_with_auth_callback_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_request_token_test.dart';
import 'package:ably_flutter_integration_test/test/rest/rest_time_test.dart';

typedef TestFactory = Future<Map<String, dynamic>> Function({
  required Reporter reporter,
  Map<String, dynamic>? payload,
});

final testFactory = <String, TestFactory>{
  // platform and app key tests
  TestName.appKeyProvisioning: testAppKeyProvision,
  TestName.platformAndAblyVersion: testPlatformAndAblyVersion,

  // crypto tests
  TestName.cryptoEnsureSupportedKeyLength: testCryptoEnsureSupportedKeyLength,
  TestName.cryptoGenerateRandomKey: testCryptoGenerateRandomKey,
  TestName.cryptoGetDefaultParams: testCryptoGetDefaultParams,

  // realtime tests
  TestName.realtimeEncryptedPublish: testRealtimeEncryptedPublish,
  TestName.realtimeEncryptedPublishSpec: testRealtimeEncryptedPublishSpec,
  TestName.realtimeEvents: testRealtimeEvents,
  TestName.realtimeHistory: testRealtimeHistory,
  TestName.realtimeHistoryWithAuthCallback: testRealtimeHistoryWithAuthCallback,
  TestName.realtimePresenceEnterUpdateLeave:
      testRealtimePresenceEnterUpdateLeave,
  TestName.realtimePresenceGet: testRealtimePresenceGet,
  TestName.realtimePresenceHistory: testRealtimePresenceHistory,
  TestName.realtimePresenceSubscribe: testRealtimePresenceSubscribe,
  TestName.realtimePublish: testRealtimePublish,
  TestName.realtimePublishSpec: testRealtimePublishSpec,
  TestName.realtimePublishWithAuthCallback: testRealtimePublishWithAuthCallback,
  TestName.realtimeSubscribe: testRealtimeSubscribe,
  TestName.realtimeTime: testRealtimeTime,
  TestName.realtimeAuthAuthorize: testRealtimeAuthroize,
  TestName.realtimeAuthClientId: testRealtimeAuthClientId,
  TestName.realtimeWithAuthUrl: testCreateRealtimeWithAuthUrl,

  // rest tests
  TestName.restCapabilities: testRestCapabilities,
  TestName.restEncryptedPublish: testRestEncryptedPublish,
  TestName.restEncryptedPublishSpec: testRestEncryptedPublishSpec,
  TestName.restHistory: testRestHistory,
  TestName.restHistoryWithAuthCallback: testRestHistoryWithAuthCallback,
  TestName.restPresenceGet: testRestPresenceGet,
  TestName.restPresenceHistory: testRestPresenceHistory,
  TestName.restPublish: testRestPublish,
  TestName.restPublishSpec: testRestPublishSpec,
  TestName.restPublishWithAuthCallback: testRestPublishWithAuthCallback,
  TestName.restTime: testRestTime,
  TestName.restAuthAuthorize: testRestAuthorize,
  TestName.restRequestToken: testRestRequestToken,
  TestName.restCreateTokenRequest: testRestCreateTokenRequest,
  TestName.restAuthClientId: testRestAuthClientId,

  // helper tests
  TestName.testHelperUnhandledExceptionTest: testHelperUnhandledException,
};
