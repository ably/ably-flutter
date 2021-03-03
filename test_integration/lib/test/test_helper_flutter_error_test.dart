import 'package:flutter/widgets.dart';

import '../factory/reporter.dart';

Future<Map<String, dynamic>> testTestHelperFlutterError({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  FlutterError.reportError(const FlutterErrorDetails(
    exception: 'Should become a FlutterError response',
  ));
  return {};
}
