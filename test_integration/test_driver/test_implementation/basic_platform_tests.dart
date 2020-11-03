import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


Future testPlatformAndAblyVersion(FlutterDriver driver) async {
  final data = {'message': 'foo'};
  final message =
  TestControlMessage(TestName.platformAndAblyVersion, payload: data);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['platformVersion'], isA<String>());
  expect(response.payload['platformVersion'], isNot(isEmpty));
  expect(response.payload['ablyVersion'], isA<String>());
  expect(response.payload['ablyVersion'], isNot(isEmpty));
}

Future testDemoDependencies(FlutterDriver driver) async {
  final data = {'message': 'foo'};
  final message =
  TestControlMessage(TestName.appKeyProvisioning, payload: data);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['appKey'], isA<String>());
  expect(response.payload['appKey'], isNotEmpty);


  print('response.payload:: ${response.payload}');


  var tokenRequest = response.payload['tokenRequest'];

  expect(tokenRequest['keyName'], isA<String>());
  expect(tokenRequest['keyName'], isNotEmpty);

  expect(tokenRequest['nonce'], isA<String>());
  expect(tokenRequest['nonce'], isNotEmpty);

  expect(tokenRequest['mac'], isA<String>());
  expect(tokenRequest['mac'], isNotEmpty);

  expect(tokenRequest['clientId'], isA<String>());
  expect(tokenRequest['clientId'], isNotEmpty);

  expect(tokenRequest['timestamp'], isA<int>());;

  expect(tokenRequest['ttl'], isA<int>());
}
