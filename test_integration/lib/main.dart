import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'driver_data_handler.dart';
import 'test_dispatcher.dart';

void main() {
  final dataHandler = DriverDataHandler();
  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  runApp(TestDispatcher(driverDataHandler: dataHandler));
}
