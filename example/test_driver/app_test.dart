// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Ably Test App', () {

    print(find.byType("MaterialApp"));

    final executeButtonFinder = find.byValueKey('execute');
    final int testCount = 3;

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    // Initially check if all tests show status "fail"
    test('Setup', () async {
      for(int i=1; i<=testCount; i++){
        expect(await driver.getText(find.byValueKey('result-$i')), "fail");
      }
    });

    // Execute and check if all tests show status "ok"
    test('Execute', () async {
      // First, tap the button.
      await driver.tap(executeButtonFinder);
      while(await driver.getText(executeButtonFinder) != "done"){
        await Future.delayed(Duration(seconds: 5));
      }
      for(int i=1; i<=testCount; i++){
        expect(await driver.getText(find.byValueKey('result-$i')), "ok");
      }
    });
  });
}
