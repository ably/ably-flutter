import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _capabilitySpec = {
  // Allow us to publish and subscribe to any channel.
  '*': ['publish', 'subscribe'],
};

// per: https://docs.ably.io/client-lib-development-guide/test-api/
final _appSpec = Map.unmodifiable({
  // API Keys & Capabilities.
  'keys': [
    {
      // The need to use jsonEncode here is a requirement of the Sandbox Test
      // API.  The capability map has to be JSON encoded as a string and then
      // appropriately escaped in order for presentation within a string value.
      'capability': json.encode(_capabilitySpec),
    },
  ],
});

const _requestHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

class AppKey {
  final String name;
  final String secret;
  final String _keyStr;

  AppKey(this.name, this.secret, this._keyStr);

  @override
  String toString() => _keyStr;
}

Future<AppKey> provision(final String environmentPrefix) async {
  final url = 'https://${environmentPrefix}rest.ably.io/apps';
  final body = json.encode(_appSpec);
  final response = await http.post(url, body: body, headers: _requestHeaders);
  if (response.statusCode != HttpStatus.created) {
    throw HttpException(
        "Server didn't return success. Status: ${response.statusCode}");
  }

  // Cherry pick the pieces from the JSON response that we need.
  final result = json.decode(response.body) as Map<String, dynamic>;
  final keys = result['keys'] as List<dynamic>;
  final key = keys[0] as Map<String, dynamic>;
  return AppKey(key['keyName'] as String, key['keySecret'] as String,
      key['keyStr'] as String);
}
