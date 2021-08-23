import 'dart:async';

import '../../error/src/error_info.dart';
import '../../push_notifications/push_notifications.dart';

class PushEventsNative extends PushEvents {
  static PushEventsNative shared = PushEventsNative();

  StreamController<ErrorInfo?> activateStreamController = StreamController();
  StreamController<ErrorInfo?> deactivateStreamController = StreamController();
  StreamController<ErrorInfo> updateFailedStreamController = StreamController();

  @override
  Stream<ErrorInfo?> get onActivate => activateStreamController.stream;

  @override
  Stream<ErrorInfo?> get onDeactivate => deactivateStreamController.stream;

  @override
  Stream<ErrorInfo> get onUpdateFailed => updateFailedStreamController.stream;

  void _close() {
    activateStreamController.close();
    deactivateStreamController.close();
    updateFailedStreamController.close();
  }
}
