import 'dart:async';
import 'dart:convert';

import 'package:ably_flutter_integration_test/config/test_factory.dart';
import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:ably_flutter_integration_test/factory/error_handler.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:flutter/material.dart';

enum _TestStatus { success, error, progress }

/// Decodes messages from the driver, invokes the test and returns the result.
class TestDispatcher extends StatefulWidget {
  final Map<String, TestFactory> testFactory;
  final DispatcherController controller;

  const TestDispatcher({
    required this.testFactory,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestDispatcherState();
}

class _TestDispatcherState extends State<TestDispatcher> {
  /// A map of active test names vs reporters
  final _reporters = <String, Reporter>{};

  late Map<String, String> _testResults;

  /// stores whether a test is success/failed/pending
  /// {'restPublish': true} => basic test passed,
  /// {'restPublish': false} => failed
  /// {} i.e., missing 'restPublish' key => test is still pending
  final _testStatuses = <String, _TestStatus>{};

  @override
  void initState() {
    super.initState();
    widget.controller.setDispatcher(this);
    _testResults = <String, String>{
      for (final key in testFactory.keys) key: '',
    };
  }

  Future<TestControlResponseMessage> handleDriverMessage(
    TestControlMessage message,
  ) {
    final reporter = Reporter(message, widget.controller);

    Future<void>.delayed(Duration.zero, () async {
      // check if a test is running and throw error
      if (_reporters.containsKey(reporter.testName)) {
        reporter.reportTestError(
          'Test started while the previous one is still running.',
        );
      }

      if (widget.testFactory.containsKey(reporter.testName)) {
        // check if a test exists with that name
        if (widget.testFactory.containsKey(reporter.testName)) {
          setState(() {
            _testStatuses[reporter.testName] = _TestStatus.progress;
          });
          final testFunction = widget.testFactory[reporter.testName]!;
          await testFunction(
            reporter: reporter,
            payload: reporter.message.payload,
          ).then(reporter.reportTestCompletion).catchError(
                (Object error, StackTrace stack) =>
                    reporter.reportTestCompletion({
                  TestControlMessage.errorKey:
                      ErrorHandler.encodeException(error, stack),
                }),
              );
        }
      } else if (reporter.testName == TestName.getFlutterErrors) {
        reporter.reportTestCompletion({'logs': _flutterErrorLogs});
        _flutterErrorLogs.clear();
      } else {
        // report error otherwise
        reporter.reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${reporter.testName} is not implemented'
        });
      }
      setState(() {});
    });

    return reporter.response.future;
  }

  final List<Map<String, String?>> _flutterErrorLogs = <Map<String, String>>[];

  void logFlutterErrors(FlutterErrorDetails details) =>
      _flutterErrorLogs.add(ErrorHandler.encodeFlutterError(details));

  Color _getColor(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return Colors.green;
      case _TestStatus.error:
        return Colors.red;
      case _TestStatus.progress:
        return Colors.blue;
      case null:
        return Colors.white;
    }
  }

  Widget _getAction(String testName) {
    final playIcon = IconButton(
      icon: const Icon(Icons.play_arrow),
      color: Colors.white,
      onPressed: () {
        handleDriverMessage(TestControlMessage(testName)).then((_) {
          setState(() {});
        });
        setState(() {});
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
      case null:
        return playIcon;
    }
  }

  Widget _getStatus(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return const Icon(Icons.check);
      case _TestStatus.error:
        return const Icon(Icons.warning_amber_rounded);
      case _TestStatus.progress:
        return Container();
      case null:
        return Container();
    }
  }

  Widget getTestRow(BuildContext context, String testName) => Row(
        children: [
          Expanded(
            child: Text(
              testName,
              style: TextStyle(color: _getColor(testName), fontSize: 16),
            ),
          ),
          _getAction(testName),
          _getStatus(testName),
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            color: Colors.white,
            onPressed: () {
              showDialog<void>(
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
  Widget build(BuildContext context) => MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test dispatcher'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                  _reporters.isEmpty
                      ? '-'
                      : 'running ${_reporters.length}'
                          ' (${_reporters.keys.toList().toString()}) tests',
                  style: const TextStyle(color: Colors.white)),
            ),
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

  void renderResponse(TestControlResponseMessage message) {
    final testName = message.testName;
    _testResults[testName] = message.toPrettyJson();
    setState(() {
      _reporters.remove(testName);
      _testStatuses[testName] =
          message.payload.containsKey(TestControlMessage.errorKey)
              ? _TestStatus.error
              : _TestStatus.success;
    });
  }
}

class DispatcherController {
  late _TestDispatcherState _dispatcher;

  // ignore: use_setters_to_change_properties
  void setDispatcher(_TestDispatcherState dispatcher) {
    _dispatcher = dispatcher;
    // more stuff
  }

  Future<String> driveHandler(String? encodedMessage) async {
    final response = await _dispatcher.handleDriverMessage(
      TestControlMessage.fromJson(
        json.decode(encodedMessage!) as Map<String, dynamic>,
      ),
    );
    return json.encode(response);
  }

  void logFlutterErrors(FlutterErrorDetails details) {
    _dispatcher.logFlutterErrors(details);
  }

  void setResponse(TestControlResponseMessage message) {
    _dispatcher.renderResponse(message);
  }
}
