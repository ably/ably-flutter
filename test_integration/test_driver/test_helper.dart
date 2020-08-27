import 'package:ably_flutter_integration_test/main.dart' as app;
import 'package:ably_flutter_integration_test/test/test_helper_flutter_error_test.dart';
import 'package:ably_flutter_integration_test/test/test_helper_unhandled_exception_test.dart';
import 'package:ably_flutter_integration_test/test_dispatcher.dart';
import 'package:ably_flutter_integration_test/test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.testHelperFlutterErrorTest: (d) => TestHelperFlutterErrorTest(d),
  TestName.testHelperUnhandledExceptionTest: (d) =>
      TestHelperUnhandledExceptionTest(d),
};

void main() => app.main(testFactory);
