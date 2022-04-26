import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

/// package-private implementation of [PushActivationEvents]
/// used internally by [Push] instances
// FIXME: StreamControllers here may leak, we should add a `close()` method
// like [PushNotificationEventsInternal.close()]
class PushActivationEventsInternal extends PushActivationEvents {
  /// [StreamController] used to handle onActivate events
  StreamController<ErrorInfo?> onActivateStreamController = StreamController();

  /// [StreamController] used to handle onDeactivate events
  StreamController<ErrorInfo?> onDeactivateStreamController =
      StreamController();

  /// [StreamController] used to handle onUpdateFailed events
  StreamController<ErrorInfo> onUpdateFailedStreamController =
      StreamController();

  @override
  Stream<ErrorInfo?> get onActivate => onActivateStreamController.stream;

  @override
  Stream<ErrorInfo?> get onDeactivate => onDeactivateStreamController.stream;

  @override
  Stream<ErrorInfo> get onUpdateFailed => onUpdateFailedStreamController.stream;
}
