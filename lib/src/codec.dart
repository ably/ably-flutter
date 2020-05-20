import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert' show json;

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' show GeneratedMessage;
import '../gen/protos.dart' as protos;

import '../ably.dart';


typedef P CodecEncoder<T, P>(final WriteBuffer buffer, final T value);
typedef T CodecDecoder<T>(Uint8List buffer);
class CodecPair<T, P extends GeneratedMessage>{

  final CodecEncoder<T, P> encoder;
  final CodecDecoder<T> decoder;
  CodecPair(this.encoder, this.decoder);

  Uint8List encode(final WriteBuffer buffer, final dynamic value){
    if (this.encoder==null) throw AblyException("Codec encoder not defined");
    P message = this.encoder(buffer, value as T);
    return message.writeToBuffer();
  }

  T decode(Uint8List buffer){
    if (this.decoder==null) throw AblyException("Codec decoder not defined");
    return this.decoder(buffer);
  }

}

class CPair<T> extends CodecPair<T, protos.AblyMessage>{
  CPair(a, b):super(a, b);
}


class Codec extends StandardMessageCodec {

  Map<protos.CodecDataType, CodecPair> codecMap;

  Codec():super(){
    this.codecMap = {
      //Ably flutter plugin protocol message
      protos.CodecDataType.ABLY_MESSAGE: CodecPair<AblyMessage, protos.AblyMessage>(ablyMessageToProto, ablyMessageFromProto),

      //Other ably objects
      protos.CodecDataType.CLIENT_OPTIONS: CodecPair<ClientOptions, protos.ClientOptions>(encodeClientOptions, decodeClientOptions),
//      protos.CodecDataType.TOKEN_DETAILS: CodecPair<TokenDetails>(encodeTokenDetails, decodeTokenDetails),
      /*protos.CodecDataType.ERROR_INFO: CPair<ErrorInfo>(null, decodeErrorInfo),

      //Events - Connection
      protos.CodecDataType.CONNECTION_EVENT: CPair<ConnectionEvent>(null, decodeConnectionEvent),
      protos.CodecDataType.CONNECTION_STATE: CPair<ConnectionState>(null, decodeConnectionState),
      protos.CodecDataType.CONNECTION_STATE_CHANGE: CPair<ConnectionStateChange>(null, decodeConnectionStateChange),

      //Events - Channel
      protos.CodecDataType.CHANNEL_EVENT: CPair<ChannelEvent>(null, decodeChannelEvent),
      protos.CodecDataType.CHANNEL_STATE: CPair<ChannelState>(null, decodeChannelState),
      protos.CodecDataType.CHANNEL_STATE_CHANGE: CPair<ChannelStateChange>(null, decodeChannelStateChange),*/
    };
  }

  protos.CodecDataType getCodecType(final dynamic value){
    if (value is ClientOptions) {
      return protos.CodecDataType.CLIENT_OPTIONS;
    } else if (value is TokenDetails) {
      return protos.CodecDataType.TOKEN_DETAILS;
    } else if (value is ErrorInfo) {
      return protos.CodecDataType.ERROR_INFO;
    } else if (value is AblyMessage) {
      return protos.CodecDataType.ABLY_MESSAGE;
    }
    return null;
  }

  @override
  void writeValue(final WriteBuffer buffer, final dynamic value) {
    protos.CodecDataType type = getCodecType(value);
    if (type==null) {
      super.writeValue(buffer, value);
    } else {
      buffer.putUint8(type.value);
      writeValue(buffer, codecMap[type].encode(buffer, value));
    }
  }

  dynamic readValueOfType(int type, ReadBuffer buffer) {
    CodecPair pair = codecMap[protos.CodecDataType.valueOf(type)];
    if (pair==null) {
      return super.readValueOfType(type, buffer);
    } else {
      return pair.decode(readValue(buffer) as Uint8List);
    }
  }

  // =========== ENCODERS ===========
  protos.ClientOptions encodeClientOptions(final WriteBuffer buffer, final ClientOptions v){
    if(v==null) return null;
    protos.ClientOptions options = protos.ClientOptions();

    // AuthOptions (super class of ClientOptions)
    if(v.authUrl!=null) options.authUrl = v.authUrl;
    if(v.authMethod!=null) options.authMethod = protos.HTTPMethods.valueOf(v.authMethod.index);
    if(v.key!=null) options.key = v.key;
    if(v.tokenDetails!=null) options.tokenDetails = tokenDetailsToProto(v.tokenDetails);
    if(v.authHeaders!=null) options.authHeaders.addAll(v.authHeaders);
    if(v.authParams!=null) options.authParams.addAll(v.authParams);
    if(v.queryTime!=null) options.queryTime = v.queryTime;
    if(v.useTokenAuth!=null) options.useTokenAuth = v.useTokenAuth;

    // ClientOptions
    if(v.clientId!=null) options.clientId = v.clientId;
    if(v.logLevel!=null) options.logLevel = v.logLevel;
    //TODO handle logHandler
    if(v.tls!=null) options.tls = v.tls;
    if(v.restHost!=null) options.restHost = v.restHost;
    if(v.realtimeHost!=null) options.realtimeHost = v.realtimeHost;
    if(v.port!=null) options.port = v.port;
    if(v.tlsPort!=null) options.tlsPort = v.tlsPort;
    if(v.autoConnect!=null) options.autoConnect = v.autoConnect;
    if(v.useBinaryProtocol!=null) options.useBinaryProtocol = v.useBinaryProtocol;
    if(v.queueMessages!=null) options.queueMessages = v.queueMessages;
    if(v.echoMessages!=null) options.echoMessages = v.echoMessages;
    if(v.recover!=null) options.recover = v.recover;
    if(v.environment!=null) options.environment = v.environment;
    if(v.idempotentRestPublishing!=null) options.idempotentRestPublishing = v.idempotentRestPublishing;
    if(v.httpOpenTimeout!=null) options.httpOpenTimeout = v.httpOpenTimeout;
    if(v.httpRequestTimeout!=null) options.httpRequestTimeout = v.httpRequestTimeout;
    if(v.httpMaxRetryCount!=null) options.httpMaxRetryCount = v.httpMaxRetryCount;
    if(v.realtimeRequestTimeout!=null) options.realtimeRequestTimeout = v.realtimeRequestTimeout;
    if(v.fallbackHosts!=null) options.fallbackHosts.addAll(v.fallbackHosts);
    if(v.fallbackHostsUseDefault!=null) options.fallbackHostsUseDefault = v.fallbackHostsUseDefault;
    if(v.fallbackRetryTimeout!=null) options.fallbackRetryTimeout = v.fallbackRetryTimeout;
    if(v.defaultTokenParams!=null) options.defaultTokenParams = tokenParamsToProto(v.defaultTokenParams);
    if(v.channelRetryTimeout!=null) options.channelRetryTimeout = v.channelRetryTimeout;
    if(v.transportParams!=null) options.transportParams.addAll(v.transportParams);
    return options;
  }

  protos.TokenDetails tokenDetailsToProto(final TokenDetails v){
    protos.TokenDetails details = protos.TokenDetails();
    if(v.token!=null) details.token = v.token;
    if(v.expires!=null) details.expires = v.expires;
    if(v.issued!=null) details.issued = v.issued;
    if(v.capability!=null) details.capability = v.capability;
    if(v.clientId!=null) details.clientId = v.clientId;
    return details;
  }

  protos.TokenParams tokenParamsToProto(final TokenParams v){
    protos.TokenParams params = protos.TokenParams();
    if(v.capability!=null) params.capability = v.capability;
    if(v.clientId!=null) params.clientId = v.clientId;
    if(v.nonce!=null) params.nonce = v.nonce;
    if(v.timestamp!=null) params.timestamp = protos.Timestamp.fromDateTime(v.timestamp);
    if(v.ttl!=null) params.ttl = v.ttl;
    return params;
  }

  protos.AblyMessage ablyMessageToProto(final WriteBuffer buffer, final AblyMessage v){
    protos.AblyMessage message = protos.AblyMessage();
    message.registrationHandle = Int64.parseInt(v.registrationHandle.toString());
    if(v.message!=null) {
      protos.CodecDataType type = getCodecType(v.message);
      if (type == null) {
        message.message = message.message.toBuilder()..mergeFromJsonMap(v.message as Map<String, dynamic>, null);
      } else {
        message.messageType = type;
        message.message = message.message.toBuilder()
          ..mergeFromBuffer(this.codecMap[type].encode(buffer, v.message));
      }
    }
    return message;
  }

  // =========== DECODERS ===========
  ClientOptions decodeClientOptions(Uint8List buffer){

    final protos.ClientOptions options = protos.ClientOptions.fromBuffer(buffer);

    final ClientOptions v = ClientOptions();
    // AuthOptions (super class of ClientOptions)
    v.authUrl = options.authUrl;

    v.authMethod = HTTPMethods.values[options.authMethod.value];
    v.key = options.key;
    v.tokenDetails = decodeTokenDetails(options.tokenDetails);
    v.authHeaders = options.authHeaders;
    v.authParams = options.authParams;
    v.queryTime = options.queryTime;
    v.useTokenAuth = options.useTokenAuth;

    // ClientOptions
    v.clientId = options.clientId;
    v.logLevel = options.logLevel;
    //TODO handle logHandler
    v.tls = options.tls;
    v.restHost = options.restHost;
    v.realtimeHost = options.realtimeHost;
    v.port = options.port;
    v.tlsPort = options.tlsPort;
    v.autoConnect = options.autoConnect;
    v.useBinaryProtocol = options.useBinaryProtocol;
    v.queueMessages = options.queueMessages;
    v.echoMessages = options.echoMessages;
    v.recover = options.recover;
    v.environment = options.environment;
    v.idempotentRestPublishing = options.idempotentRestPublishing;
    v.httpOpenTimeout = options.httpOpenTimeout;
    v.httpRequestTimeout = options.httpRequestTimeout;
    v.httpMaxRetryCount = options.httpMaxRetryCount;
    v.realtimeRequestTimeout = options.realtimeRequestTimeout;
    v.fallbackHosts = options.fallbackHosts;
    v.fallbackHostsUseDefault = options.fallbackHostsUseDefault;
    v.fallbackRetryTimeout = options.fallbackRetryTimeout;
    v.defaultTokenParams = decodeTokenParams(options.defaultTokenParams);
    v.channelRetryTimeout = options.channelRetryTimeout;
    v.transportParams = options.transportParams;
    return v;
  }

  TokenDetails decodeTokenDetails(protos.TokenDetails details){
    TokenDetails t = TokenDetails(details.token);
    t.expires = details.expires;
    t.issued = details.issued;
    t.capability = details.capability;
    t.clientId = details.clientId;
    return t;
  }

  TokenParams decodeTokenParams(protos.TokenParams params){
    TokenParams p = TokenParams();
    p.capability = params.capability;
    p.clientId = params.clientId;
    p.nonce = params.nonce;
    p.timestamp = params.timestamp.toDateTime();
    p.ttl = params.ttl;
    return p;
  }

  AblyMessage ablyMessageFromProto(Uint8List buffer){
    final protos.AblyMessage message = protos.AblyMessage.fromBuffer(buffer);
    dynamic data;
    if(message.messageType!=null && codecMap.containsKey(message.messageType)){
      data = codecMap[message.messageType].decode(message.message.writeToBuffer());
    }else{
      data = message.message.writeToJsonMap();
    }
    return AblyMessage(
      int.parse(message.registrationHandle.toString()),
      data
    );
  }

  ErrorInfo decodeErrorInfo(Uint8List buffer){
    return ErrorInfo();
//    return ErrorInfo(
//        code: readValue(buffer) as int,
//        message: readValue(buffer) as String,
//        statusCode: readValue(buffer) as int,
//        href: readValue(buffer) as String,
//        requestId: readValue(buffer) as String,
//        cause: readValue(buffer) as ErrorInfo
//    );
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
