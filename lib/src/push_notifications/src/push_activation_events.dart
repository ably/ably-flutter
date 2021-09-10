import '../../error/error.dart';
import '../push_notifications.dart';

/// Methods that will be called back when events happen related to push
/// notifications, such as device activation, deactivation, update fails.
abstract class PushActivationEvents {
  /// Called when device completes activation with Ably for push notifications.
  /// If successful, errorInfo will be null.
  //
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
}
