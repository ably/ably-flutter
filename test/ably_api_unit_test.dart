import 'package:test/test.dart';
import 'package:ably_flutter_plugin/ably.dart';

void main() {
  /// We are leaving it up to the platform client library SDK to supply defaults.
  /// This test ensures that the default ClientOptions created on Dart side has
  /// null for all properties so that this works.
  test('Default ClientOptions', () { 
    final clientOptions = ClientOptions();
    expect(clientOptions.clientId, isNull);
    expect(clientOptions.logLevel, LogLevel.info);
    expect(clientOptions.logHandler, isNull);
    expect(clientOptions.tls, isNull);
    expect(clientOptions.restHost, isNull);
    expect(clientOptions.realtimeHost, isNull);
    expect(clientOptions.port, isNull);
    expect(clientOptions.tlsPort, isNull);
    expect(clientOptions.autoConnect, isNull);
    expect(clientOptions.useBinaryProtocol, isNull);
    expect(clientOptions.queueMessages, isNull);
    expect(clientOptions.echoMessages, isNull);
    expect(clientOptions.recover, isNull);
    expect(clientOptions.proxy, isNull);
    expect(clientOptions.environment, isNull);
    expect(clientOptions.idempotentRestPublishing, isNull);
    expect(clientOptions.httpOpenTimeout, isNull);
    expect(clientOptions.httpRequestTimeout, isNull);
    expect(clientOptions.httpMaxRetryCount, isNull);
    expect(clientOptions.realtimeRequestTimeout, isNull);
    expect(clientOptions.fallbackHosts, isNull);
    expect(clientOptions.fallbackHostsUseDefault, isNull);
    expect(clientOptions.fallbackRetryTimeout, isNull);
    expect(clientOptions.defaultTokenParams, isNull);
    expect(clientOptions.channelRetryTimeout, isNull);
    expect(clientOptions.transportParams, isNull);
    expect(clientOptions.asyncHttpThreadpoolSize, isNull);
    expect(clientOptions.pushFullWait, isNull);
  });
}
