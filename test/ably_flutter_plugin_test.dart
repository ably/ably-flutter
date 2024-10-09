import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final channel =
      MethodChannel('io.ably.flutter.plugin', StandardMethodCodec(Codec()));

  TestWidgetsFlutterBinding.ensureInitialized();
  var counter = 0;

  //test constants
  const _platformVersion = '42';
  const _nativeLibraryVersion = '1.1.0';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      switch (methodCall.method) {
        case PlatformMethod.resetAblyClients:
          return true;

        case PlatformMethod.getPlatformVersion:
          return _platformVersion;
        case PlatformMethod.getVersion:
          return _nativeLibraryVersion;

        case PlatformMethod.createRest:
        case PlatformMethod.createRealtime:
          return ++counter;

        case PlatformMethod.publish:
        case PlatformMethod.connectRealtime:
        default:
          return null;
      }
    });
    Platform(methodChannel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(PlatformMethod.getPlatformVersion, () async {
    expect(await platformVersion(), _platformVersion);
  });

  test(PlatformMethod.getVersion, () async {
    expect(await version(), _nativeLibraryVersion);
  });

  test(PlatformMethod.createRest, () async {
    const host = 'http://rest.ably.io/';
    final o = ClientOptions(
      restHost: host,
    );
    final rest = Rest(options: o);
    expect(await rest.handle, counter);
    expect(rest.options.restHost, host);
  });

  test('createRestWithToken', () async {
    const key = 'TEST-KEY';
    final rest = Rest.fromKey(key);
    expect(await rest.handle, counter);
    expect(rest.options.tokenDetails!.token, key);
  });

  test('createRestWithKey', () async {
    const key = 'TEST:KEY';
    final rest = Rest.fromKey(key);
    expect(await rest.handle, counter);
    expect(rest.options.key, key);
  });

  test('publishMessage', () async {
    final rest = Rest.fromKey('TEST-KEY');
    await rest.channels.get('test').publish(name: 'name', data: 'data');
    expect(1, 1);
  });
}
