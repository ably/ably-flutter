import 'package:ably_flutter_example/provisioning.dart';

import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testAppKeyProvision({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async =>
    {
      'appKey': (await provision('sandbox-')).toString(),
      'tokenRequest': await getTokenRequest(),
    };
