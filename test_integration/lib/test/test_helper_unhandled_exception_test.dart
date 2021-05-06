import '../factory/reporter.dart';

Future<Map<String, dynamic>> testTestHelperUnhandledException({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  // ignore: only_throw_errors
  throw 'Unhandled exception';
}
