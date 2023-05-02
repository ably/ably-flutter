/// This constants are deliberately put into a file different from
/// `test_factory.dart` so that they are in a file without any Flutter
/// dependencies and can be imported in driver test files.

class TestName {
  // platform and key
  static const String appKeyProvisioning = 'appKeyProvisioning';
  static const String platformAndAblyVersion = 'platformAndAblyVersion';

  // crypto
  static const String cryptoEnsureSupportedKeyLength =
      'cryptoEnsureSupportedKeyLength';
  static const String cryptoGenerateRandomKey = 'cryptoGenerateRandomKey';
  static const String cryptoGetDefaultParams = 'cryptoGetDefaultParams';

  // realtime
  static const String realtimeEncryptedPublish = 'realtimeEncryptedPublish';
  static const String realtimeEncryptedPublishSpec =
      'realtimeEncryptedPublishSpec';
  static const String realtimeEvents = 'realtimeEvents';
  static const String realtimeHistory = 'realtimeHistory';
  static const String realtimeHistoryWithAuthCallback =
      'realtimeHistoryWithAuthCallback';
  static const String realtimePresenceEnterUpdateLeave =
      'realtimePresenceEnterUpdateLeave';
  static const String realtimePresenceGet = 'realtimePresenceGet';
  static const String realtimePresenceHistory = 'realtimePresenceHistory';
  static const String realtimePresenceSubscribe = 'realtimePresenceSubscribe';
  static const String realtimePublish = 'realtimePublish';
  static const String realtimePublishSpec = 'realtimePublishSpec';
  static const String realtimePublishWithAuthCallback =
      'realtimePublishWithAuthCallback';
  static const String realtimeSubscribe = 'realtimeSubscribe';
  static const String realtimeTime = 'realtimeTime';
  static const String realtimeAuthAuthorize = 'realtimeAuthorize';
  static const String realtimeCreateTokenRequest = 'realtimeCreateTokenRequest';
  static const String realtimeRequestToken = 'realtimeRequestToken';
  static const String realtimeAuthClientId = 'realtimeAuthClientId';
  static const String realtimeWithAuthUrl = 'realtimeWithAuthUrl';

  // rest
  static const String restCapabilities = 'restCapabilities';
  static const String restEncryptedPublish = 'restEncryptedPublish';
  static const String restEncryptedPublishSpec = 'restEncryptedPublishSpec';
  static const String restHistory = 'restHistory';
  static const String restHistoryWithAuthCallback =
      'restHistoryWithAuthCallback';
  static const String restPresenceGet = 'restPresenceGet';
  static const String restPresenceHistory = 'restPresenceHistory';
  static const String restPublish = 'restPublish';
  static const String restPublishSpec = 'restPublishSpec';
  static const String restPublishWithAuthCallback =
      'restPublishWithAuthCallback';
  static const String restTime = 'restTime';

  static const String restAuthAuthorize = 'restAuthorize';
  static const String restCreateTokenRequest = 'restCreateTokenRequest';
  static const String restRequestToken = 'restRequestToken';
  static const String restAuthClientId = 'restAuthClientId';

  // helpers
  static const String testHelperFlutterErrorTest = 'testHelperFlutterErrorTest';
  static const String testHelperUnhandledExceptionTest =
      'testHelperUnhandledExceptionTest';

  // This is not a test, but a way to retrieve
  // more information of failures from any of the tests cases
  static const String getFlutterErrors = 'getFlutterErrors';
}
