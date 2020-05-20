///
//  Generated code. Do not modify.
//  source: clientoptions.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const HTTPMethods$json = const {
  '1': 'HTTPMethods',
  '2': const [
    const {'1': 'POST', '2': 0},
    const {'1': 'GET', '2': 1},
  ],
};

const ClientOptions$json = const {
  '1': 'ClientOptions',
  '2': const [
    const {'1': 'authUrl', '3': 1, '4': 1, '5': 9, '10': 'authUrl'},
    const {'1': 'authMethod', '3': 2, '4': 1, '5': 14, '6': '.HTTPMethods', '10': 'authMethod'},
    const {'1': 'key', '3': 3, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'tokenDetails', '3': 4, '4': 1, '5': 11, '6': '.TokenDetails', '10': 'tokenDetails'},
    const {'1': 'authHeaders', '3': 5, '4': 3, '5': 11, '6': '.ClientOptions.AuthHeadersEntry', '10': 'authHeaders'},
    const {'1': 'authParams', '3': 6, '4': 3, '5': 11, '6': '.ClientOptions.AuthParamsEntry', '10': 'authParams'},
    const {'1': 'queryTime', '3': 7, '4': 1, '5': 8, '10': 'queryTime'},
    const {'1': 'useTokenAuth', '3': 8, '4': 1, '5': 8, '10': 'useTokenAuth'},
    const {'1': 'clientId', '3': 9, '4': 1, '5': 9, '10': 'clientId'},
    const {'1': 'logLevel', '3': 10, '4': 1, '5': 5, '10': 'logLevel'},
    const {'1': 'tls', '3': 11, '4': 1, '5': 8, '10': 'tls'},
    const {'1': 'restHost', '3': 12, '4': 1, '5': 9, '10': 'restHost'},
    const {'1': 'realtimeHost', '3': 13, '4': 1, '5': 9, '10': 'realtimeHost'},
    const {'1': 'port', '3': 14, '4': 1, '5': 13, '10': 'port'},
    const {'1': 'tlsPort', '3': 15, '4': 1, '5': 13, '10': 'tlsPort'},
    const {'1': 'autoConnect', '3': 16, '4': 1, '5': 8, '10': 'autoConnect'},
    const {'1': 'useBinaryProtocol', '3': 17, '4': 1, '5': 8, '10': 'useBinaryProtocol'},
    const {'1': 'queueMessages', '3': 18, '4': 1, '5': 8, '10': 'queueMessages'},
    const {'1': 'echoMessages', '3': 19, '4': 1, '5': 8, '10': 'echoMessages'},
    const {'1': 'recover', '3': 20, '4': 1, '5': 9, '10': 'recover'},
    const {'1': 'environment', '3': 21, '4': 1, '5': 9, '10': 'environment'},
    const {'1': 'idempotentRestPublishing', '3': 22, '4': 1, '5': 8, '10': 'idempotentRestPublishing'},
    const {'1': 'httpOpenTimeout', '3': 23, '4': 1, '5': 13, '10': 'httpOpenTimeout'},
    const {'1': 'httpRequestTimeout', '3': 24, '4': 1, '5': 13, '10': 'httpRequestTimeout'},
    const {'1': 'httpMaxRetryCount', '3': 25, '4': 1, '5': 13, '10': 'httpMaxRetryCount'},
    const {'1': 'realtimeRequestTimeout', '3': 26, '4': 1, '5': 13, '10': 'realtimeRequestTimeout'},
    const {'1': 'fallbackHosts', '3': 27, '4': 3, '5': 9, '10': 'fallbackHosts'},
    const {'1': 'fallbackHostsUseDefault', '3': 28, '4': 1, '5': 8, '10': 'fallbackHostsUseDefault'},
    const {'1': 'fallbackRetryTimeout', '3': 29, '4': 1, '5': 13, '10': 'fallbackRetryTimeout'},
    const {'1': 'defaultTokenParams', '3': 30, '4': 1, '5': 11, '6': '.TokenParams', '10': 'defaultTokenParams'},
    const {'1': 'channelRetryTimeout', '3': 31, '4': 1, '5': 13, '10': 'channelRetryTimeout'},
    const {'1': 'transportParams', '3': 32, '4': 3, '5': 11, '6': '.ClientOptions.TransportParamsEntry', '10': 'transportParams'},
  ],
  '3': const [ClientOptions_AuthHeadersEntry$json, ClientOptions_AuthParamsEntry$json, ClientOptions_TransportParamsEntry$json],
};

const ClientOptions_AuthHeadersEntry$json = const {
  '1': 'AuthHeadersEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ClientOptions_AuthParamsEntry$json = const {
  '1': 'AuthParamsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ClientOptions_TransportParamsEntry$json = const {
  '1': 'TransportParamsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

