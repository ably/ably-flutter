import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'driver_data_handler.dart';
import 'test/provision_test.dart';
import 'test/version_test.dart';

class TestDispatcher extends StatefulWidget {
  final DriverDataHandler driverDataHandler;

  const TestDispatcher({
    Key key,
    this.driverDataHandler,
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
    widget.driverDataHandler.callback = (m) async {
      _completer = Completer<TestControlMessage>();

      setState(() => message = m);

      return _completer.future;
    };
  }

  void completeTest(Map<String, dynamic> data) {
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
      switch (message.testName) {
        case 'version':
          testWidget = VersionTest(this);
          break;
        case 'provision':
          testWidget = ProvisionTest(this);
          break;
          break;
        default:
          completeTest({
            'error': 'Test ${message?.testName ?? 'N/A'} is not implemented'
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
