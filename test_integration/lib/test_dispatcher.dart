import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:wakelock/wakelock.dart';

import 'driver_data_handler.dart';
import 'test/test_factory.dart';

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
  TestControlMessage _message;

  Map<String, String> _testResults;

  /// To wait for the response of the test after a received message.
  Completer<TestControlMessage> _responseCompleter;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _testResults = <String, String>{
      for (final key in testFactory.keys) key: '',
    };

    widget.driverDataHandler.callback = _incomingDriverMessageHandler;
    widget.errorHandler.callback =
        _unhandledTestExceptionAndFlutterErrorHandler;
  }

  Future<TestControlMessage> _incomingDriverMessageHandler(
      TestControlMessage m) async {
    if (_responseCompleter != null) {
      _responseCompleter.completeError(
          'New test started while the previous one is still running.');
      _responseCompleter = null;
      _log.clear();
    }
    _responseCompleter = Completer<TestControlMessage>();

    setState(() => _message = m);

    return _responseCompleter.future;
  }

  Null _unhandledTestExceptionAndFlutterErrorHandler(
          Map<String, String> errorMessage) =>
      reportTestCompletion({TestControlMessage.errorKey: errorMessage});

  final _log = <dynamic>[];

  /// Collect log messages.to be sent with the response at the end of the test.
  void reportLog(dynamic log) => _log.add(log);

  /// Create a response to a message from the driver reporting the test result.
  void reportTestCompletion(Map<String, dynamic> data) {
    final msg = TestControlMessage(
      _message?.testName ?? 'N/A',
      payload: data,
      log: _log.toList(),
    );

    _responseCompleter?.complete(msg);
    _log.clear();
    _responseCompleter = null;

    _testResults[msg.testName] = msg.toJsonEncoded();
    setState(() => _message = null);
  }

  /// Configure a timeout in case the test does not complete.
  ///
  /// [duration] is the time to wait before an error is reported.
  /// This method is supposed to be called from test widgets in `initState`
  ///
  ///     widget.dispatcher.timeout(const Duration(seconds: 3));
  ///
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
    if (_noMessageReceivedYet) {
      testWidget = Container();
    } else {
      if (widget.testFactory.containsKey(_message.testName)) {
        testWidget = widget.testFactory[_message.testName](this);
      } else {
        reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${_message?.testName ?? 'N/A'} is not implemented'
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
                    child: Text(_message?.testName ?? 'N/A'),
                  ),
                  testWidget,
                  Expanded(
                    child: ListView.builder(
                      itemCount: _testResults.keys.length,
                      itemBuilder: (context, idx) {
                        final testName = _testResults.keys.toList()[idx];
                        return ListTile(
                          leading: FlatButton(
                            color: Colors.blue,
                            onPressed: _responseCompleter != null
                                ? null
                                : () {
                                    widget.driverDataHandler.call(
                                        TestControlMessage(testName)
                                            .toJsonEncoded());
                                  },
                            child: Text(testName),
                          ),
                          subtitle:
                              Text(_testResults[testName] ?? 'No result yet'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )));
  }

  bool get _noMessageReceivedYet => _message == null;
}

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class ErrorHandler {
  Null Function(Map<String, String> message) callback;

  void onFlutterError(FlutterErrorDetails details) {
    if (callback == null) {
      print(details.exception);
      print(details.stack);
    }

    callback({
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    });
  }

  void onException(Object error, StackTrace stack) {
    if (callback == null) {
      print(error);
      print(stack);
    }

    callback({
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    });
  }
}

typedef TestFactory = Widget Function(TestDispatcherState testDispatcher);
