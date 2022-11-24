import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

/// Used to provision the app with Ably sandbox environment
/// A copy of this class is also present in example app, to avoid putting
/// it in the base ably_flutter package
class AppProvisioning {
  /// Prefix of REST environment used to provision the app. For example,
  /// with prefix `sandbox-` URL `sandbox-rest.ably.io` will be used
  ///
  /// Defaults to [defaultEnvironmentPrefix]
  String environmentPrefix;

  /// List of capabilities for the provisioned key
  ///
  /// Defaults to [defaultKeyCapabilities]
  Map<String, List<dynamic>> keyCapabilities;

  /// Determines whether the provisioned key will have push capabilities
  ///
  /// Defaults to true
  bool pushEnabled;

  /// Creates instance of [AppProvisioning]
  AppProvisioning({
    this.environmentPrefix = defaultEnvironmentPrefix,
    this.keyCapabilities = defaultKeyCapabilities,
    this.pushEnabled = true,
  });

  /// Default prefix for REST provisioning url
  static const String defaultEnvironmentPrefix = 'sandbox-';

  /// Default list of key capabilities
  /// Enables all capabilities on all channels
  static const Map<String, List<dynamic>> defaultKeyCapabilities = {
    '*': [
      'publish',
      'subscribe',
      'history',
      'presence',
      'push-subscribe',
      'push-admin',
    ],
  };

  /// Internal HTTP client used to make provisioning API requests
  final http.Client _httpRetryClient = RetryClient(
    http.Client(),
    retries: 5,
    delay: (retryCount) => const Duration(seconds: 2),
  );

  /// URL used for app provisioning requests
  String get _provisioningUrl =>
      'https://${environmentPrefix}rest.ably.io/apps';

  /// URL used for getting token request
  String get _tokenRequestAuthUrl =>
      'https://www.ably.io/ably-auth/token-request/demos';

  /// A set of base headers for HTTP requests
  Map<String, String> get _requestHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// App spec used to provision the app
  ///
  /// See: https://docs.ably.com/client-lib-development-guide/test-api
  Map<String, List<dynamic>> get _appSpec => {
        'namespaces': [
          {
            'id': 'pushenabled',
            'pushEnabled': pushEnabled,
          }
        ],
        'keys': [
          {
            // The need to use jsonEncode here is a requirement of the
            // Sandbox Test API. The capability map has to be JSON encoded
            // as a string and then appropriately escaped in order for
            // presentation within a string value.
            'capability': jsonEncode(keyCapabilities),
          },
        ],
      };

  /// Makes request to configured Ably provisioning URL and returns a
  /// new key for test application instance
  Future<String> provisionApp() async {
    final response = await _httpRetryClient.post(
      Uri.parse(_provisioningUrl),
      body: jsonEncode(_appSpec),
      headers: _requestHeaders,
    );

    if (response.statusCode != HttpStatus.created) {
      log("Server didn't return success. ${response.body}");
      throw HttpException("Server didn't return success."
          ' Status: ${response.statusCode} : ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    return responseBody['keys'][0]['keyStr'] as String;
  }

  /// Returns a demo token request that can be used to retrieve token
  /// Result of this method can be used directly to create [TokenRequest]
  /// with [TokenRequest.fromMap(map)] method
  Future<Map<String, dynamic>> getTokenRequest() async {
    final response = await _httpRetryClient.get(
      Uri.parse(_tokenRequestAuthUrl),
    );

    if (response.statusCode != HttpStatus.ok) {
      log("Server didn't return success. ${response.body}");
      throw HttpException("Server didn't return success."
          ' Status: ${response.statusCode} : ${response.body}');
    }

    return Map.castFrom<dynamic, dynamic, String, dynamic>(
      jsonDecode(response.body) as Map,
    );
  }
}
