import 'dart:async';

import 'package:flutter/material.dart';

import 'tests.dart';

void main() => runApp(AblyIntegrationTestApp());

class AblyIntegrationTestApp extends StatefulWidget {

  AblyIntegrationTestApp({Key key}) : super(key: key);

  @override
  _AblyIntegrationTestAppState createState() => _AblyIntegrationTestAppState();
}

class _AblyIntegrationTestAppState extends State<AblyIntegrationTestApp> {
  TestFlow testFlow = TestFlow();

  List<AblyIntegrationTest> tests;
  String status = "execute";

  @override
  initState() {
    super.initState();
    tests = [
      AblyIntegrationTest("Provision API Key", testFlow.provisionAppKey, 1,
        children: [
          AblyIntegrationTest("Get platform version", testFlow.getPlatformVersion, 2),
          AblyIntegrationTest("Get ably version", testFlow.getAblyVersion, 3),
        ]
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Center(
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 48.0, horizontal: 36.0),
                children: tests.map((_) => _.widget()).toList()
              ),
              RaisedButton(
                child: Text(status, key:  Key('execute'),),
                onPressed: () async {
                  setState(() { status = "executing"; });
                  for(AblyIntegrationTest test in tests){
                    await test.execute((){
                      this.setState(() {});
                    });
                  }
                  setState(() { status = "done"; });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

typedef Future<bool> AblyIntegrationTestExecutor();

class AblyIntegrationTest {

  final String name;
  final Function fn;
  bool status;
  final int index;
  List<AblyIntegrationTest> children;

  AblyIntegrationTest(this.name, this.fn, this.index, {
    this.status = false,
    this.children
  });

  void execute(Function on_update) async {
    bool returnValue = await fn();
    this.status = returnValue;
    on_update();
    if(this.children!=null){
      for(AblyIntegrationTest test in children){
        await test.execute(on_update);
      }
    }
  }

  Widget widget(){
    return Container(
      child: Column(
        children: [
          testRow(name, status, index),
          ...(children?.isNotEmpty==true)?[Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
              children: children.map((_) => _.widget()).toList()
            ),
          ),]:[]
        ],
      ),
    );
  }

}

Widget testRow(String name, bool status, int value){
  return Container(
    child: Row(
      children: [
        Expanded(
          child: Text(name),
        ),
        Text(status?"ok":"fail", key: Key('result-$value'),)
      ],
    ),
  );
}
