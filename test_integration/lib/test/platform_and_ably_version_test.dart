import 'package:ably_flutter/ably_flutter.dart' as ably;
import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testPlatformAndAblyVersion({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  final platformVersion = await ably.platformVersion();
  final ablyVersion = await ably.version();

  return {
    'platformVersion': platformVersion,
    'ablyVersion': ablyVersion,
  };
}
