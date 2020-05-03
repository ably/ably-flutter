import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably.dart';


typedef CodecEncoder<T>(final WriteBuffer buffer, final T value);
typedef T CodecDecoder<T>(ReadBuffer buffer);
class CodecPair<T>{

  final CodecEncoder<T> encoder;
  final CodecDecoder<T> decoder;
  CodecPair(this.encoder, this.decoder);

  encode(final WriteBuffer buffer, final dynamic value){
    if(this.encoder==null) throw AblyException("Codec encoder not defined");
    return this.encoder(buffer, value as T);
  }

  T decode(ReadBuffer buffer){
    if(this.decoder==null) throw AblyException("Codec decoder not defined");
    return this.decoder(buffer);
  }

}


class Codec extends StandardMessageCodec {

  // Custom type values must be over 127. At the time of writing the standard message
  // codec encodes them as an unsigned byte which means the maximum type value is 255.
  // If we get to the point of having more than that number of custom types (i.e. more
  // than 128 [255 - 127]) then we can either roll our own codec from scratch or,
  // perhaps easier, reserve custom type value 255 to indicate that it will be followed
  // by a subtype value - perhaps of a wider type.
  //
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html

  //Ably flutter plugin protocol message
  static const _valueAblyMessage = 128;

  //Other ably objects
  static const _valueClientOptions = 129;
  static const _valueTokenDetails = 130;
  static const _valueErrorInfo = 144;

  // Events
  static const _connectionEvent = 201;
  static const _connectionState = 202;
  static const _connectionStateChange = 203;
  static const _channelEvent = 204;
  static const _channelState = 205;
  static const _channelStateChange = 206;

  Map<int, CodecPair> codecMap;

  Codec():super(){
    this.codecMap = {
      //Ably flutter plugin protocol message
      _valueAblyMessage: CodecPair<AblyMessage>(encodeAblyMessage, decodeAblyMessage),

      //Other ably objects
      _valueClientOptions: CodecPair<ClientOptions>(encodeClientOptions, decodeClientOptions),
      _valueTokenDetails: CodecPair<TokenDetails>(encodeTokenDetails, decodeTokenDetails),
      _valueErrorInfo: CodecPair<ErrorInfo>(null, decodeErrorInfo),

      //Events - Connection
      _connectionEvent: CodecPair<ConnectionEvent>(null, decodeConnectionEvent),
      _connectionState: CodecPair<ConnectionState>(null, decodeConnectionState),
      _connectionStateChange: CodecPair<ConnectionStateChange>(null, decodeConnectionStateChange),

      //Events - Channel
      _channelEvent: CodecPair<ChannelEvent>(null, decodeChannelEvent),
      _channelState: CodecPair<ChannelState>(null, decodeChannelState),
      _channelStateChange: CodecPair<ChannelStateChange>(null, decodeChannelStateChange),
    };
  }

  getCodecType(final dynamic value){
    if (value is ClientOptions) {
      return _valueClientOptions;
    } else if (value is TokenDetails) {
      return _valueTokenDetails;
    } else if (value is ErrorInfo) {
      return _valueErrorInfo;
    } else if (value is AblyMessage) {
      return _valueAblyMessage;
    }
  }

  @override
  void writeValue (final WriteBuffer buffer, final dynamic value) {
    int type = getCodecType(value);
    if(type==null){
      super.writeValue(buffer, value);
    }else {
      buffer.putUint8(type);
      codecMap[type].encode(buffer, value);
    }
  }

  dynamic readValueOfType(int type, ReadBuffer buffer) {
    CodecPair pair = codecMap[type];
    if(pair==null){
      return super.readValueOfType(type, buffer);
    }else{
      return pair.decode(buffer);
    }
  }

  // =========== ENCODERS ===========
  encodeClientOptions(final WriteBuffer buffer, final ClientOptions v){
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
    writeValue(buffer, v.logLevel);
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
  }

  encodeTokenDetails(final WriteBuffer buffer, final TokenDetails v){
    writeValue(buffer, v.token);
    writeValue(buffer, v.expires);
    writeValue(buffer, v.issued);
    writeValue(buffer, v.capability);
    writeValue(buffer, v.clientId);
  }

  encodeAblyMessage(final WriteBuffer buffer, final AblyMessage v){
    writeValue(buffer, v.registrationHandle);
    writeValue(buffer, v.message);
  }


  // =========== DECODERS ===========
  ClientOptions decodeClientOptions(ReadBuffer buffer){
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
    v.logLevel = readValue(buffer) as int;
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
  }

  TokenDetails decodeTokenDetails(ReadBuffer buffer){
    TokenDetails t = TokenDetails(readValue(buffer));
    t.expires = readValue(buffer) as int;
    t.issued = readValue(buffer) as int;
    t.capability = readValue(buffer) as String;
    t.clientId = readValue(buffer) as String;
    return t;
  }

  AblyMessage decodeAblyMessage(ReadBuffer buffer){
    return AblyMessage(
      readValue(buffer) as int,
      readValue(buffer),
    );
  }

  ErrorInfo decodeErrorInfo(ReadBuffer buffer){
    return ErrorInfo(
        code: readValue(buffer) as int,
        message: readValue(buffer) as String,
        statusCode: readValue(buffer) as int,
        href: readValue(buffer) as String,
        requestId: readValue(buffer) as String,
        cause: readValue(buffer) as ErrorInfo
    );
  }

  ConnectionEvent decodeConnectionEvent(ReadBuffer buffer) => ConnectionEvent.values[readValue(buffer) as int];
  ConnectionState decodeConnectionState(ReadBuffer buffer) => ConnectionState.values[readValue(buffer) as int];
  ChannelEvent decodeChannelEvent(ReadBuffer buffer) => ChannelEvent.values[readValue(buffer) as int];
  ChannelState decodeChannelState(ReadBuffer buffer) => ChannelState.values[readValue(buffer) as int];

  ConnectionStateChange decodeConnectionStateChange(ReadBuffer buffer){
    ConnectionState current = readValue(buffer) as ConnectionState;
    ConnectionState previous = readValue(buffer) as ConnectionState;
    ConnectionEvent event = readValue(buffer) as ConnectionEvent;
    int retryIn = readValue(buffer) as int;
    ErrorInfo reason = readValue(buffer) as ErrorInfo;
    return ConnectionStateChange(current, previous, event, retryIn: retryIn, reason: reason);
  }

  ChannelStateChange decodeChannelStateChange(ReadBuffer buffer){
    ChannelState current = readValue(buffer) as ChannelState;
    ChannelState previous = readValue(buffer) as ChannelState;
    ChannelEvent event = readValue(buffer) as ChannelEvent;
    bool resumed = readValue(buffer) as bool;
    ErrorInfo reason = readValue(buffer) as ErrorInfo;
    return ChannelStateChange(current, previous, event, resumed: resumed, reason: reason);
  }

}
