import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'tests_config.dart';

void runTests({
  bool all = false,
  Iterable<TestModules>? testModules,
}) {
  final tests = getTestsFor(
    all: all,
    testModules: testModules,
  );

  late FlutterDriver driver;

  // Connect this driver to the application before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect(printCommunication: true);
  });

  FlutterDriver getDriver() => driver;

  tearDownAll(() async {
    const message = TestControlMessage(TestName.getFlutterErrors);
    final flutterErrors = await requestDataForTest(getDriver(), message);
    print('Flutter errors: ${flutterErrors.payload}');
    final _ = driver.close();
  });

  for (final testModule in tests.keys) {
    final testModuleName = EnumToString.convertToString(testModule);
    tests[testModule]!.forEach((
        testGroupName,
        testFunction,
        ) {
      group(
        'Module: $testModuleName. Group: $testGroupName',
            () => testFunction(getDriver),
        timeout: const Timeout(Duration(minutes: 2)),
      );
    });
  }
}
