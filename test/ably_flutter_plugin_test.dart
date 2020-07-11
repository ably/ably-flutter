import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/rest/rest.dart';
import 'package:ably_flutter_plugin/src/info.dart';
import 'package:ably_flutter_plugin/src/platform.dart' as platform;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';


///Extension to extract string name from PlatformMethod
extension on PlatformMethod {

  /// ref: https://stackoverflow.com/a/59308734/392847
  String toName() => this.toString().split('.').last;

}

void main() {

  MethodChannel channel = platform.methodChannel;

  TestWidgetsFlutterBinding.ensureInitialized();
  int counter = 0;

  //test constants
  String _platformVersion = '42';
  String _nativeLibraryVersion = '1.1.0';

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch(methodCall.method){
        case PlatformMethod.registerAbly:
          return true;

        case PlatformMethod.getPlatformVersion:
          return _platformVersion;
        case PlatformMethod.getVersion:
          return _nativeLibraryVersion;

        case "createrestWithKey":
        case PlatformMethod.createRestWithOptions:
        case PlatformMethod.createRealtimeWithOptions:
          return ++counter;

        case PlatformMethod.publish:
        case PlatformMethod.connectRealtime:
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test(PlatformMethod.getPlatformVersion, () async {
    expect(await platformVersion(), _platformVersion);
  });

  test(PlatformMethod.getVersion, () async {
    expect(await version(), _nativeLibraryVersion);
  });

  test(PlatformMethod.createRestWithOptions, () async {
    ClientOptions o = ClientOptions();
    String host = "http://rest.ably.io/";
    o.restHost = host;
    Rest rest = Rest(options: o);
    expect(await rest.handle, counter);
    expect(rest.options.restHost, host);
  });

  test("createRestWithToken", () async {
    String key = 'TEST-KEY';
    Rest rest = Rest(key: key);
    expect(await rest.handle, counter);
    expect(rest.options.tokenDetails.token, key);
  });

  test("createRestWithKey", () async {
    String key = 'TEST:KEY';
    Rest rest = Rest(key: key);
    expect(await rest.handle, counter);
    expect(rest.options.key, key);
  });

  test("publishMessage", () async {
    Rest rest = Rest(key: 'TEST-KEY');
    await rest.channels.get('test').publish(name: 'name', data: 'data');
    expect(1, 1);
  });

}
