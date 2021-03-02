import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testTestHelperUnhandledException({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  // ignore: only_throw_errors
  throw 'Unhandled exception';
}
