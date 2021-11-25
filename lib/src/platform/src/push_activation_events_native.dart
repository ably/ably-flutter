import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

class PushActivationEventsInternal extends PushActivationEvents {
  StreamController<ErrorInfo?> onActivateStreamController = StreamController();
  StreamController<ErrorInfo?> onDeactivateStreamController =
      StreamController();
  StreamController<ErrorInfo> onUpdateFailedStreamController =
      StreamController();

  @override
  Stream<ErrorInfo?> get onActivate => onActivateStreamController.stream;

  @override
  Stream<ErrorInfo?> get onDeactivate => onDeactivateStreamController.stream;

  @override
  Stream<ErrorInfo> get onUpdateFailed => onUpdateFailedStreamController.stream;

  void _close() {
    onActivateStreamController.close();
    onDeactivateStreamController.close();
    onUpdateFailedStreamController.close();
  }
}
