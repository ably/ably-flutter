import '../../error/error.dart';
import '../push_notifications.dart';

/// Methods that will be called back when events happen related to push
/// notifications, such as device activation, deactivation, update fails.
abstract class PushEvents {
  /// Called when device completes activation with Ably for push notifications.
  /// If successful, errorInfo will be null.
  ///
  /// Listening to onDeactivate is optional since [Push.activate]
  //  will return when it succeeds, and throw when it fails.
  Stream<ErrorInfo?> get onActivate;

  /// Called when device completes deactivation with Ably for push
  /// notifications. If successful, errorInfo will be null.
  ///
  /// Listening to onDeactivate is optional since [Push.deactivate]
  /// will return when it succeeds, and throw when it fails.
  Stream<ErrorInfo?> get onDeactivate;

  /// Called when device unsuccessfully fails to update Ably with the latest
  /// device details.
  ///
  /// You should listen to onUpdateFailed events, since there is no other
  /// way you will know that a new APNs/ FCM token provided by the OS
  /// fails to be sent to Ably.
  Stream<ErrorInfo> get onUpdateFailed;

  // TODO implement message handlers: https://github.com/ably/ably-flutter/issues/141
  // /// Returns a stream which emits a value everytime a message is received
  // /// whilst the app is in the foreground
  // Stream<PushMessage> get onMessage;
  //
  // /// Returns a future which resolves when a message is received whilst
  // /// the application is in the background or terminated.
  // Future<PushMessage> get onBackgroundMessage;
  //
  // /// Immediately returns a future which resolves to a message the app launch
  // /// was the result of tapping a notification.
  // Future<PushMessage> get onNotificationMessageTapLaunchesApp;
  //
  // /// Returns a stream which emits a value when a notification is tapped when
  // /// the app is either in the foreground or background, but not terminated.
  // Stream<PushMessage> get onNotificationMessageTapResumesApp;
}
