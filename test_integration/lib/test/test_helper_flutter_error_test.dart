import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testTestHelperFlutterError({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  FlutterError.reportError(const FlutterErrorDetails(
    exception: 'Should become a FlutterError response',
  ));
  return {};
}
