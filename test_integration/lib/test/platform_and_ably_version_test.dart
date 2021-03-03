import 'package:ably_flutter/ably_flutter.dart' as ably;
import '../factory/reporter.dart';

Future<Map<String, dynamic>> testPlatformAndAblyVersion({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  final platformVersion = await ably.platformVersion();
  final ablyVersion = await ably.version();

  return {
    'platformVersion': platformVersion,
    'ablyVersion': ablyVersion,
  };
}
