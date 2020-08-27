import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

import 'driver_data_handler.dart';

/// Decodes messages from the driver, invokes the test and returns the result.
class TestDispatcher extends StatefulWidget {
  final DriverDataHandler driverDataHandler;
  final ErrorHandler errorHandler;
  final Map<String, TestFactory> testFactory;

  const TestDispatcher({
    Key key,
    this.testFactory,
    this.driverDataHandler,
    this.errorHandler,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TestDispatcherState();
}

class TestDispatcherState extends State<TestDispatcher> {
  /// The last message received from the driver.
  TestControlMessage message;

  /// To wait for the reponse of the test after a received message.
  Completer<TestControlMessage> _responseCompleter;

  @override
  void initState() {
    super.initState();

    _registerIncomingDriverMessageHandler();

    _registerUnhandledExceptionAndFlutterErrorsHandler();
  }

  void _registerUnhandledExceptionAndFlutterErrorsHandler() {
    widget.errorHandler.callback = (errorMessage) =>
        reportTestCompletion({TestControlMessage.errorKey: errorMessage});
  }

  void _registerIncomingDriverMessageHandler() {
    widget.driverDataHandler.callback = (m) async {
      if (_responseCompleter != null) {
        _responseCompleter.completeError(
            'New test started while the previous one is still running.');
        _responseCompleter = null;
        _log.clear();
      }
      _responseCompleter = Completer<TestControlMessage>();

      setState(() => message = m);

      return _responseCompleter.future;
    };
  }

  final _log = <dynamic>[];

  /// Collect log messages.to be sent with the response at the end of the test.
  void reportLog(dynamic log) => _log.add(log);

  /// Create a response to a message from the driver reporting the test result.
  void reportTestCompletion(Map<String, dynamic> data) {
    _responseCompleter?.complete(TestControlMessage(
        message?.testName ?? 'N/A', data,
        log: _log.toList()));
    _log.clear();
    _responseCompleter = null;
    setState(() => message = null);
  }

  /// Respond to the driver if the test does not succeed within [duration].
  void timeout(Duration duration) async {
    unawaited(_responseCompleter.future.timeout(duration, onTimeout: () {
      reportTestCompletion(
          {TestControlMessage.errorKey: 'Timed out after $duration'});
      return null;
    }));
  }

  @override
  Widget build(BuildContext context) {
    Widget testWidget;
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
class ErrorHandler {
  Null Function(Map<String, String> message) callback;

  void onFlutterError(FlutterErrorDetails details) {
    callback({
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    });
  }

  void onException(Object error, StackTrace stack) {
    callback({
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    });
  }
}

typedef TestFactory = Widget Function(TestDispatcherState testDispatcher);
