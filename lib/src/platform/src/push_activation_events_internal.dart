// ignore_for_file: close_sinks

import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

/// @nodoc
/// package-private implementation of [PushActivationEvents]
/// used internally by [Push] instances
// FIXME: StreamControllers here may leak, we should add a `close()` method
// See: https://github.com/ably/ably-flutter/issues/382
class PushActivationEventsInternal extends PushActivationEvents {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// [StreamController] used to handle onActivate events
  /// END LEGACY DOCSTRING
  StreamController<ErrorInfo?> onActivateStreamController = StreamController();

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// [StreamController] used to handle onDeactivate events
  /// END LEGACY DOCSTRING
  StreamController<ErrorInfo?> onDeactivateStreamController =
      StreamController();

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// [StreamController] used to handle onUpdateFailed events
  /// END LEGACY DOCSTRING
  StreamController<ErrorInfo> onUpdateFailedStreamController =
      StreamController();

  @override
  Stream<ErrorInfo?> get onActivate => onActivateStreamController.stream;

  @override
  Stream<ErrorInfo?> get onDeactivate => onDeactivateStreamController.stream;

  @override
  Stream<ErrorInfo> get onUpdateFailed => onUpdateFailedStreamController.stream;
}
