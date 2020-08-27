import 'package:ably_flutter_integration_test/main.dart' as app;
import 'package:ably_flutter_integration_test/test/rest_publish_test.dart';
import 'package:ably_flutter_integration_test/test_dispatcher.dart';
import 'package:ably_flutter_integration_test/test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.restPublish: (d) => RestPublishTest(d),
};

void main() => app.main(testFactory);
