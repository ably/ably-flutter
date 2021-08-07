import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'tests_config.dart';

void runTests({
  bool all = false,
  List<TestCategory> groups,
}) {
  final tests = getTestsFor(
    all: all,
    groups: groups,
  );

  FlutterDriver driver;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect(printCommunication: true);
  });

  tearDownAll(() async {
    if (driver != null) {
      const message = TestControlMessage(TestName.getFlutterErrors);
      final flutterErrors = await getTestResponse(driver, message);
      print('Flutter errors: ${flutterErrors.payload}');
      final _ = driver.close();
    }
  });

  for (final testCategory in tests.keys) {
    final testCategoryName = EnumToString.convertToString(testCategory);
    tests[testCategory].forEach((
      testGroupName,
      void Function(FlutterDriver) testFunction,
    ) {
      group(
        '$testCategoryName: $testGroupName',
        () => testFunction(driver),
        timeout: const Timeout(Duration(minutes: 2)),
      );
    });
  }
}
