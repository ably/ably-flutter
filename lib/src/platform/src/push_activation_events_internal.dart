// ignore_for_file: close_sinks

import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

/// @nodoc
/// Package-private implementation of [PushActivationEvents] used internally by
/// [Push] instances.
// FIXME: StreamControllers here may leak, we should add a `close()` method
// See: https://github.com/ably/ably-flutter/issues/382
class PushActivationEventsInternal extends PushActivationEvents {
  /// @nodoc
  /// [StreamController] used to handle onActivate events.
  StreamController<ErrorInfo?> onActivateStreamController = StreamController();

  /// @nodoc
  /// [StreamController] used to handle onDeactivate events.
  StreamController<ErrorInfo?> onDeactivateStreamController =
      StreamController();

  /// @nodoc
  /// [StreamController] used to handle onUpdateFailed events.
  StreamController<ErrorInfo> onUpdateFailedStreamController =
      StreamController();

  @override
  Stream<ErrorInfo?> get onActivate => onActivateStreamController.stream;

  @override
  Stream<ErrorInfo?> get onDeactivate => onDeactivateStreamController.stream;

  @override
  Stream<ErrorInfo> get onUpdateFailed => onUpdateFailedStreamController.stream;
}
