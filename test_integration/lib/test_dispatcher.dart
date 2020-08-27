import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'driver_data_handler.dart';

/// Decodes messages from the driver, invokes the test and returns the result.
class TestDispatcher extends StatefulWidget {
  final DriverDataHandler driverDataHandler;
  final FlutterErrorHandler flutterErrorHandler;
  final Map<String, TestFactory> testFactory;

  const TestDispatcher({
    Key key,
    this.testFactory,
    this.driverDataHandler,
    this.flutterErrorHandler,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TestDispatcherState();
}

class TestDispatcherState extends State<TestDispatcher> {
  TestControlMessage message;
  Completer<TestControlMessage> _completer;

  @override
  void initState() {
    super.initState();

    handleIncomingDriverMessage();

    handleUnhandledExceptionAndFlutterErrors();
  }

  void handleUnhandledExceptionAndFlutterErrors() {
    widget.flutterErrorHandler.callback = (errorMessage) =>
        reportTestCompletion({TestControlMessage.errorKey: errorMessage});
  }

  void handleIncomingDriverMessage() {
    widget.driverDataHandler.callback = (m) async {
      _completer = Completer<TestControlMessage>();

      setState(() => message = m);

      return _completer.future;
    };
  }

  void reportTestCompletion(Map<String, dynamic> data) {
    final response = TestControlMessage(message?.testName ?? 'N/A', data);
    _completer?.complete(response);
    _completer = null;
    message = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget testWidget;
    if (message == null) {
      testWidget = Container();
    }

    if (message == null) {
      testWidget = Container();
    } else {
      if (widget.testFactory.containsKey(message.testName)) {
        testWidget = widget.testFactory[message.testName](this);
      } else {
        reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${message?.testName ?? 'N/A'} is not implemented'
        });
        testWidget = Container();
      }
    }

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Test dispatcher'),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(message?.testName ?? 'N/A'),
                  ),
                  testWidget
                ],
              ),
            )));
  }
}

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class FlutterErrorHandler {
  Null Function(Map<String, String> message) callback;

  void onFlutterError(FlutterErrorDetails details) {
    callback({
      'exceptionType': details.exception.runtimeType.toString(),
      'exception': details.exceptionAsString(),
      'context': details.context.toDescription(),
      'library': details.library,
      'stackTrace': details.stack.toString(),
    });
  }

  void onError(Object error, StackTrace stack) {
    callback({
      'exceptionType': error.runtimeType.toString(),
      'exception': error.toString(),
      'stackTrace': stack.toString(),
    });
  }
}

typedef TestFactory = Widget Function(TestDispatcherState testDispatcher);
