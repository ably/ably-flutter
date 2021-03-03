import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'config/test_factory.dart';
import 'driver_data_handler.dart';

enum _TestStatus { success, error, progress }

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

  /// stores whether a test is success/failed/pending
  /// {'restPublish': true} => basic test passed,
  /// {'restPublish': false} => failed
  /// {} i.e., missing 'restPublish' key => test is still pending
  final _testStatuses = <String, _TestStatus>{};

  /// To wait for the response of the test after a received message.
  Completer<TestControlMessage> _responseCompleter;

  @override
  void initState() {
    super.initState();
    _testResults = <String, String>{
      for (final key in testFactory.keys) key: '',
    };

    widget.driverDataHandler.callback = _incomingDriverMessageHandler;
    widget.errorHandler.callback =
        _unhandledTestExceptionAndFlutterErrorHandler;
  }

  Future<TestControlMessage> _incomingDriverMessageHandler(
    TestControlMessage m,
  ) async {
    if (_responseCompleter != null) {
      _responseCompleter.completeError(
        'New test started while the previous one is still running.',
      );
      _responseCompleter = null;
      _log.clear();
    }
    _responseCompleter = Completer<TestControlMessage>();

    setState(() => _message = m);

    return _responseCompleter.future;
  }

  void _unhandledTestExceptionAndFlutterErrorHandler(
    Map<String, String> errorMessage,
  ) =>
      reportTestCompletion({TestControlMessage.errorKey: errorMessage});

  final _log = <dynamic>[];

  /// Collect log messages.to be sent with the response at the end of the test.
  void reportLog(Object log) => _log.add(log);

  /// Create a response to a message from the driver reporting the test result.
  void reportTestCompletion(Map<String, dynamic> data) {
    final testName = _message?.testName ?? 'N/A';
    final msg = TestControlMessage(
      testName,
      payload: data,
      log: _log.toList(),
    );
    _responseCompleter?.complete(msg);
    _log.clear();
    _responseCompleter = null;

    _testResults[msg.testName] = msg.toPrettyJson();
    setState(() {
      _message = null;
      _testStatuses[testName] = data.containsKey(TestControlMessage.errorKey)
          ? _TestStatus.error
          : _TestStatus.success;
    });
  }

  Color _getColor(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return Colors.green;
      case _TestStatus.error:
        return Colors.red;
      case _TestStatus.progress:
        return Colors.blue;
    }
    return Colors.grey;
  }

  Widget _getAction(String testName) {
    final playIcon = IconButton(
      icon: const Icon(Icons.play_arrow),
      onPressed: _responseCompleter != null
          ? null
          : () {
              widget.driverDataHandler.call(
                TestControlMessage(testName).toJsonEncoded(),
              );
            },
    );
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return playIcon;
      case _TestStatus.error:
        return playIcon;
      case _TestStatus.progress:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(),
        );
    }
    return playIcon;
  }

  Widget _getStatus(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return const Icon(Icons.check);
      case _TestStatus.error:
        return const Icon(Icons.close);
      case _TestStatus.progress:
        return Container();
    }
    return Container();
  }

  Widget getTestRow(BuildContext context, String testName) => Row(
        children: [
          Expanded(
            child: Text(
              testName,
              style: TextStyle(color: _getColor(testName)),
            ),
          ),
          _getAction(testName),
          _getStatus(testName),
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: const EdgeInsets.all(4),
                  insetPadding: const EdgeInsets.symmetric(vertical: 24),
                  content: SingleChildScrollView(
                    child: Text(
                      _testResults[testName] ?? 'No result yet',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    Widget testWidget;
    testWidget = Container();
    final testName = _message?.testName ?? 'N/A';
    if (!_noMessageReceivedYet) {
      if (widget.testFactory.containsKey(testName)) {
        _testStatuses[testName] = _TestStatus.progress;
        setState(() {});
        widget.testFactory[_message.testName](
          dispatcher: this,
          payload: _message.payload,
        )
            .then(reportTestCompletion);
      } else {
        reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${_message?.testName ?? 'N/A'} is not implemented'
        });
      }
    }

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Test dispatcher'),
      ),
      body: Column(
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
                return ListTile(subtitle: getTestRow(context, testName));
              },
            ),
          ),
        ],
      ),
    ));
  }

  bool get _noMessageReceivedYet => _message == null;
}

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class ErrorHandler {
  void Function(Map<String, String> message) callback;

  void onFlutterError(FlutterErrorDetails details) {
    print(details.exception);
    print(details.stack);

    callback({
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    });
  }

  void onException(Object error, StackTrace stack) {
    print(error);
    print(stack);

    callback({
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    });
  }
}

typedef TestFactory = Future<Map<String, dynamic>> Function({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
});
