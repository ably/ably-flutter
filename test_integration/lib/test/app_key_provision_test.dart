import 'package:ably_flutter_example/provisioning.dart';

import '../factory/reporter.dart';

Future<Map<String, dynamic>> testAppKeyProvision({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async =>
    {
      'appKey': (await provision('sandbox-')).toString(),
      'tokenRequest': await getTokenRequest(),
    };
