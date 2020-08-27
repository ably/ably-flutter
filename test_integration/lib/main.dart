import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'driver_data_handler.dart';
import 'test_dispatcher.dart';

void main(Map<String, TestFactory> tests) {
  final dataHandler = DriverDataHandler();
  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  final flutterErrorHandler = FlutterErrorHandler();
  FlutterError.onError = flutterErrorHandler.onFlutterError;

  runZonedGuarded(
      () => runApp(TestDispatcher(
            testFactory: tests,
            driverDataHandler: dataHandler,
            flutterErrorHandler: flutterErrorHandler,
          )),
      flutterErrorHandler.onError);
}
