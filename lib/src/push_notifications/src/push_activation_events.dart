import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED DOCSTRING
/// Contains streams that will be emmit a message whenever events related to
/// push notifications occur, such as device activation, deactivation, or update
/// fails.
/// END EDITED DOCSTRING
abstract class PushActivationEvents {
  /// BEGIN EDITED DOCSTRING
  /// A stream that emmits a message when device completes activation with Ably
  /// for push notifications.
  /// If successful, errorInfo will be null.
  //
  /// Listening to onDeactivate is optional since [Push.activate]
  //  will return when it succeeds, and throw when it fails.
  /// END EDITED DOCSTRING
  Stream<ErrorInfo?> get onActivate;

  /// BEGIN EDITED DOCSTRING
  /// A stream that emmits a message emmits a message when device completes
  /// deactivation with Ably for push notifications. If successful, errorInfo
  /// will be null.
  ///
  /// Listening to onDeactivate is optional since [Push.deactivate]
  /// will return when it succeeds, and throw when it fails.
  /// END EDITED DOCSTRING
  Stream<ErrorInfo?> get onDeactivate;

  /// BEGIN EDITED DOCSTRING
  /// A stream that emmits a message when a device unsuccessfully fails to
  /// update Ably with the latest device details.
  ///
  /// You should listen to onUpdateFailed events, since there is no other
  /// way you will know that a new APNs/FCM token provided by the OS
  /// fails to be sent to Ably.
  /// END EDITED DOCSTRING
  Stream<ErrorInfo> get onUpdateFailed;
}
