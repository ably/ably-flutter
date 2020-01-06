import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ably_test_flutter_oldskool_plugin/ably_test_flutter_oldskool_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('ably_test_flutter_oldskool_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AblyTestFlutterOldskoolPlugin.platformVersion, '42');
  });
}
