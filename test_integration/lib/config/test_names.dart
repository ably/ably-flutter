/// This constants are deliberately put into a file different from
/// `test_factory.dart` so that they are in a file without any Flutter
/// dependencies and can be imported in driver test files.

class TestName {
  static const String platformAndAblyVersion = 'platformAndAblyVersion';
  static const String appKeyProvisioning = 'appKeyProvisioning';

  static const String testHelperFlutterErrorTest = 'testHelperFlutterErrorTest';
  static const String testHelperUnhandledExceptionTest =
      'testHelperUnhandledExceptionTest';

  static const String restPublish = 'restPublish';
  static const String restPublishSpec = 'restPublishSpec';
  static const String restHistory = 'restHistory';
  static const String restPublishWithAuthCallback =
      'restPublishWithAuthCallback';

  // TODO(tiholic) handle restHistoryWithAuthCallback
  static const String restPresenceGet = 'restPresenceGet';
  static const String restPresenceHistory = 'restPresenceHistory';

  static const String realtimePublish = 'realtimePublish';
  static const String realtimeEvents = 'realtimeEvents';
  static const String realtimeSubscribe = 'realtimeSubscribe';
  static const String realtimeHistory = 'realtimeHistory';
  static const String realtimePublishWithAuthCallback =
      'realtimePublishWithAuthCallback';
  static const String realtimePresenceGet = 'realtimePresenceGet';
  static const String realtimePresenceHistory = 'realtimePresenceHistory';
  static const String realtimePresenceEnterUpdateLeave =
      'realtimePresenceEnterUpdateLeave';
  static const String realtimePresenceSubscribe = 'realtimePresenceSubscribe';
// TODO(tiholic) handle realtimeHistoryWithAuthCallback

  // This is not a test, but a way to retrieve
  // more information of failures from any of the tests cases
  static const String getFlutterErrors = 'getFlutterErrors';
}
