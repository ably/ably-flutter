import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably.dart';


class Codec extends StandardMessageCodec {

  const Codec();

  // Custom type values must be over 127. At the time of writing the standard message
  // codec encodes them as an unsigned byte which means the maximum type value is 255.
  // If we get to the point of having more than that number of custom types (i.e. more
  // than 128 [255 - 127]) then we can either roll our own codec from scratch or,
  // perhaps easier, reserve custom type value 255 to indicate that it will be followed
  // by a subtype value - perhaps of a wider type.
  //
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
  static const _valueClientOptions = 128;
  static const _valueTokenDetails = 129;
  static const _valueAblyMessage = 255;

  @override
  void writeValue (final WriteBuffer buffer, final dynamic value) {
    if (value is ClientOptions) {
      buffer.putUint8(_valueClientOptions);
      final ClientOptions v = value;

      // AuthOptions (super class of ClientOptions)
      writeValue(buffer, v.authUrl);
      writeValue(buffer, v.authMethod);
      writeValue(buffer, v.key);
      writeValue(buffer, v.tokenDetails);
      writeValue(buffer, v.authHeaders);
      writeValue(buffer, v.authParams);
      writeValue(buffer, v.queryTime);
      writeValue(buffer, v.useTokenAuth);

      // ClientOptions
      writeValue(buffer, v.clientId);
      writeValue(buffer, v.logLevel.index);
      //TODO handle logHandler
      writeValue(buffer, v.tls);
      writeValue(buffer, v.restHost);
      writeValue(buffer, v.realtimeHost);
      writeValue(buffer, v.port);
      writeValue(buffer, v.tlsPort);
      writeValue(buffer, v.autoConnect);
      writeValue(buffer, v.useBinaryProtocol);
      writeValue(buffer, v.queueMessages);
      writeValue(buffer, v.echoMessages);
      writeValue(buffer, v.recover);
      writeValue(buffer, v.environment);
      writeValue(buffer, v.idempotentRestPublishing);
      writeValue(buffer, v.httpOpenTimeout);
      writeValue(buffer, v.httpRequestTimeout);
      writeValue(buffer, v.httpMaxRetryCount);
      writeValue(buffer, v.realtimeRequestTimeout);
      writeValue(buffer, v.fallbackHosts);
      writeValue(buffer, v.fallbackHostsUseDefault);
      writeValue(buffer, v.fallbackRetryTimeout);
      writeValue(buffer, v.defaultTokenParams);
      writeValue(buffer, v.channelRetryTimeout);
      writeValue(buffer, v.transportParams);
    } else if (value is TokenDetails) {
      buffer.putUint8(_valueTokenDetails);
      final TokenDetails v = value;
      writeValue(buffer, v.token);
      writeValue(buffer, v.expires);
      writeValue(buffer, v.issued);
      writeValue(buffer, v.capability);
      writeValue(buffer, v.clientId);
    } else if (value is AblyMessage) {
      buffer.putUint8(_valueAblyMessage);
      final AblyMessage v = value;
      writeValue(buffer, v.registrationHandle);
      writeValue(buffer, v.message);
    } else {
      super.writeValue(buffer, value);
    }
  }

  dynamic readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case _valueClientOptions:
        final ClientOptions v = ClientOptions();

        // AuthOptions (super class of ClientOptions)
        v.authUrl = readValue(buffer) as String;
        v.authMethod = readValue(buffer) as HTTPMethods;
        v.key = readValue(buffer) as String;
        v.tokenDetails = readValue(buffer) as TokenDetails;
        v.authHeaders = readValue(buffer) as Map<String, String>;
        v.authParams = readValue(buffer) as Map<String, String>;
        v.queryTime = readValue(buffer) as bool;
        v.useTokenAuth = readValue(buffer) as bool;

        // ClientOptions
        v.clientId = readValue(buffer) as String;
        v.logLevel = LogLevel.values[readValue(buffer) as int];
        //TODO handle logHandler
        v.tls = readValue(buffer) as bool;
        v.restHost = readValue(buffer) as String;
        v.realtimeHost = readValue(buffer) as String;
        v.port = readValue(buffer) as int;
        v.tlsPort = readValue(buffer) as int;
        v.autoConnect = readValue(buffer) as bool;
        v.useBinaryProtocol = readValue(buffer) as bool;
        v.queueMessages = readValue(buffer) as bool;
        v.echoMessages = readValue(buffer) as bool;
        v.recover = readValue(buffer) as String;
        v.environment = readValue(buffer) as String;
        v.idempotentRestPublishing = readValue(buffer) as bool;
        v.httpOpenTimeout = readValue(buffer) as int;
        v.httpRequestTimeout = readValue(buffer) as int;
        v.httpMaxRetryCount = readValue(buffer) as int;
        v.realtimeRequestTimeout = readValue(buffer) as int;
        v.fallbackHosts = readValue(buffer) as List<String>;
        v.fallbackHostsUseDefault = readValue(buffer) as bool;
        v.fallbackRetryTimeout = readValue(buffer) as int;
        v.defaultTokenParams = readValue(buffer) as TokenParams;
        v.channelRetryTimeout = readValue(buffer) as int;
        v.transportParams = readValue(buffer) as Map<String, String>;
        return v;

      case _valueTokenDetails:
        TokenDetails t = TokenDetails(readValue(buffer));
        t.expires = readValue(buffer) as int;
        t.issued = readValue(buffer) as int;
        t.capability = readValue(buffer) as String;
        t.clientId = readValue(buffer) as String;
        return t;
      case _valueAblyMessage:
        return AblyMessage(
          readValue(buffer) as int,
          readValue(buffer),
        );
      default:
        return super.readValueOfType(type, buffer);
    }
  }

}
