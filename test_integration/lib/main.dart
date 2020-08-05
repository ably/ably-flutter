import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'driver_data_handler.dart';
import 'test_dispatcher.dart';

/// See
/// https://medium.com/flutter-community/hot-reload-for-flutter-integration-tests-e0478b63bd54
/// for how to improve developement performance by utilizing Hot Reload/Restart
/// for Driver tests
void main() {
  final dataHandler = DriverDataHandler();
  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  runApp(TestDispatcher(driverDataHandler: dataHandler));
}
