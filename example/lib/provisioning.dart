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
      // The need to use jsonEncode here is a requirement of the Sandbox Test API.
      // The capability map has to be JSON encoded as a string and then appropriately
      // escaped in order for presentation within a string value.
      'capability': jsonEncode(_capabilitySpec),
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

Future<Map> _provisionApp(final String environmentPrefix) async {
  final url = 'https://' + environmentPrefix + 'rest.ably.io/apps';
  final body = jsonEncode(_appSpec);
  final response = await http.post(url, body: body, headers: _requestHeaders);
  if (response.statusCode != HttpStatus.created) {
    throw HttpException('Server didn\'t return success. Status: ' + response.statusCode.toString());
  }
  return jsonDecode(response.body);
}

Future<AppKey> provision(final String environmentPrefix) async {
  final Map result = await _provisionApp(environmentPrefix);
  final Map key = result['keys'][0];
  return AppKey(key['keyName'], key['keySecret'], key['keyStr']);
}

Future<Map> getTokenRequest() async {
  // NOTE: This doesn't work with sandbox. The URL can point to test-harness's
  // tokenRequest express server's `/auth` endpoint
  http.Response r = await http.get("https://www.ably.io/ably-auth/token-request/demos");
  return jsonDecode(r.body) as Map;
}
