import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Methods that will be called back when events happen related to push
/// notifications, such as device activation, deactivation, update fails.
/// END LEGACY DOCSTRING
abstract class PushActivationEvents {
  /// BEGIN LEGACY DOCSTRING
  /// Called when device completes activation with Ably for push notifications.
  /// If successful, errorInfo will be null.
  //
  /// Listening to onDeactivate is optional since [Push.activate]
  //  will return when it succeeds, and throw when it fails.
  /// END LEGACY DOCSTRING 
  Stream<ErrorInfo?> get onActivate;

  /// BEGIN LEGACY DOCSTRING
  /// Called when device completes deactivation with Ably for push
  /// notifications. If successful, errorInfo will be null.
  ///
  /// Listening to onDeactivate is optional since [Push.deactivate]
  /// will return when it succeeds, and throw when it fails.
  /// END LEGACY DOCSTRING
  Stream<ErrorInfo?> get onDeactivate;

  /// BEGIN LEGACY DOCSTRING
  /// Called when device unsuccessfully fails to update Ably with the latest
  /// device details.
  ///
  /// You should listen to onUpdateFailed events, since there is no other
  /// way you will know that a new APNs/ FCM token provided by the OS
  /// fails to be sent to Ably.
  /// END LEGACY DOCSTRING
  Stream<ErrorInfo> get onUpdateFailed;
}
