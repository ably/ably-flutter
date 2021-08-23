import 'dart:async';

import '../../error/src/error_info.dart';
import '../../push_notifications/push_notifications.dart';

class PushEventsNative extends PushEvents {
  static PushEventsNative shared = PushEventsNative();

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
