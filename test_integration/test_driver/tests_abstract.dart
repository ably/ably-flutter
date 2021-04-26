import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'tests_config.dart';

void runTests({
  bool all = false,
  TestGroup groupName,
  List<TestGroup> groups,
}) {
  final tests = getTestsFor(
    all: all,
    group: groupName,
    groups: groups,
  );

  for (groupName in tests.keys) {
    final name =
        groupName.toString().substring(groupName.toString().indexOf('.') + 1);
    group(name, () {
      FlutterDriver driver;

      // Connect to the Flutter driver before running any tests.
      setUpAll(() async {
        driver = await FlutterDriver.connect(printCommunication: true);
      });

      tearDownAll(() async {
        if (driver != null) {
          final _ = driver.close();
        }
      });

      tests[groupName].forEach((testName, testFunction) {
        test(
          testName,
          () => testFunction(driver),
          timeout: const Timeout(Duration(minutes: 2)),
        );
      });
    });
  }
}
