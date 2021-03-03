import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'config/test_factory.dart';
import 'factory/error_handler.dart';
import 'test_dispatcher.dart';

void main() {
  final testDispatcherController = DispatcherController();

  // enable driver extension
  enableFlutterDriverExtension(handler: testDispatcherController.driveHandler);

  final flutterErrorHandler =
      ErrorHandler(testDispatcherController.errorHandler);
  FlutterError.onError = flutterErrorHandler.onFlutterError;

  runZoned(
    () => runApp(
      TestDispatcher(
        testFactory: testFactory,
        errorHandler: flutterErrorHandler,
        controller: testDispatcherController,
      ),
    ),
  );
}
