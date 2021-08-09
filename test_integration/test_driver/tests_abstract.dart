import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'tests_config.dart';

void runTests({
  bool all = false,
  TestGroup? groupName,
  List<TestGroup>? groups,
}) {
  final tests = getTestsFor(
    all: all,
    group: groupName,
    groups: groups,
  );

  late FlutterDriver driver;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect(printCommunication: true);
  });

  tearDownAll(() async {
    const message = TestControlMessage(TestName.getFlutterErrors);
    final flutterErrors = await getTestResponse(driver, message);
    print('Flutter errors: ${flutterErrors.payload}');
    final _ = driver.close();
  });

  FlutterDriver getDriver() => driver;

  for (groupName in tests.keys) {
    final name =
        groupName.toString().substring(groupName.toString().indexOf('.') + 1);
    tests[groupName]!.forEach((
      testName,
      void Function(FlutterDriver Function()) testFunction,
    ) {
      group(
        '$name $testName',
        () => testFunction(getDriver),
        timeout: const Timeout(Duration(minutes: 2)),
      );
    });
  }
}
