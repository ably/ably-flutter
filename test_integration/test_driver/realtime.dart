import 'package:ably_flutter_integration_test/main.dart' as app;
import 'package:ably_flutter_integration_test/test/realtime_publish_test.dart';
import 'package:ably_flutter_integration_test/test/realtime_events_test.dart';
import 'package:ably_flutter_integration_test/test_dispatcher.dart';
import 'package:ably_flutter_integration_test/test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.realtimePublish: (d) => RealtimePublishTest(d),
  TestName.realtimeEvents: (d) => RealtimeEventsTest(d),
};

void main() => app.main(testFactory);
