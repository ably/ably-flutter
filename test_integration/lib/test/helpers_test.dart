import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testHelperUnhandledException({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  // ignore: only_throw_errors
  throw 'Unhandled exception';
}
