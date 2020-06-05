import 'package:ably_flutter_plugin/src/generated/platformconstants.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably.dart';


typedef CodecEncoder<T>(final T value);
typedef T CodecDecoder<T>(Map<String, dynamic> jsonMap);
class CodecPair<T>{

  final CodecEncoder<T> encoder;
  final CodecDecoder<T> decoder;
  CodecPair(this.encoder, this.decoder);

  Map<String, dynamic> encode(final dynamic value){
    if (this.encoder==null) throw AblyException("Codec encoder not defined");
    if(value==null) return null;
    return this.encoder(value as T);
  }

  T decode(Map<String, dynamic> jsonMap){
    if (this.decoder==null) throw AblyException("Codec decoder not defined");
    if(jsonMap==null) return null;
    return this.decoder(jsonMap);
  }

}


class Codec extends StandardMessageCodec {

  Map<int, CodecPair> codecMap;

  Codec():super(){
    this.codecMap = {
      // Ably flutter plugin protocol message
      CodecTypes.ablyMessage: CodecPair<AblyMessage>(encodeAblyMessage, decodeAblyMessage),

      // Other ably objects
      CodecTypes.clientOptions: CodecPair<ClientOptions>(encodeClientOptions, decodeClientOptions),
      CodecTypes.errorInfo: CodecPair<ErrorInfo>(null, decodeErrorInfo),

      // Events - Connection
      CodecTypes.connectionStateChange: CodecPair<ConnectionStateChange>(null, decodeConnectionStateChange),

      // Events - Channel
      CodecTypes.channelStateChange: CodecPair<ChannelStateChange>(null, decodeChannelStateChange),
    };
  }

  Map<String, dynamic> toJsonMap(Map<dynamic, dynamic> value){
    if(value==null) return null;
    return Map.castFrom<dynamic, dynamic, String, dynamic>(value);
  }

  int getCodecType(final dynamic value){
    if (value is ClientOptions) {
      return CodecTypes.clientOptions;
    } else if (value is ErrorInfo) {
      return CodecTypes.errorInfo;
    } else if (value is AblyMessage) {
      return CodecTypes.ablyMessage;
    }
    return null;
  }

  @override
  void writeValue (final WriteBuffer buffer, final dynamic value) {
    int type = getCodecType(value);
    if (type==null) {
      super.writeValue(buffer, value);
    } else {
      buffer.putUint8(type);
      writeValue(buffer, codecMap[type].encode(value));
    }
  }

  dynamic readValueOfType(int type, ReadBuffer buffer) {
    CodecPair pair = codecMap[type];
    if (pair==null) {
      var x = super.readValueOfType(type, buffer);
      return x;
    } else {
      Map<String, dynamic> map = toJsonMap(readValue(buffer));
      return pair.decode(map);
    }
  }

  // =========== ENCODERS ===========
  writeToJson(Map<String, dynamic> map, key, value){
    if(value==null) return;
    map[key] = value;
  }

  Map<String, dynamic> encodeClientOptions(final ClientOptions v){
    if(v==null) return null;
    Map<String, dynamic> jsonMap = {};
    // AuthOptions (super class of ClientOptions)
    writeToJson(jsonMap, TxClientOptions.authUrl, v.authUrl);
    writeToJson(jsonMap, TxClientOptions.authMethod, v.authMethod);
    writeToJson(jsonMap, TxClientOptions.key, v.key);
    writeToJson(jsonMap, TxClientOptions.tokenDetails, encodeTokenDetails(v.tokenDetails));
    writeToJson(jsonMap, TxClientOptions.authHeaders, v.authHeaders);
    writeToJson(jsonMap, TxClientOptions.authParams, v.authParams);
    writeToJson(jsonMap, TxClientOptions.queryTime, v.queryTime);
    writeToJson(jsonMap, TxClientOptions.useTokenAuth, v.useTokenAuth);

    // ClientOptions
    writeToJson(jsonMap, TxClientOptions.clientId, v.clientId);
    writeToJson(jsonMap, TxClientOptions.logLevel, v.logLevel);
    //TODO handle logHandler
    writeToJson(jsonMap, TxClientOptions.tls, v.tls);
    writeToJson(jsonMap, TxClientOptions.restHost, v.restHost);
    writeToJson(jsonMap, TxClientOptions.realtimeHost, v.realtimeHost);
    writeToJson(jsonMap, TxClientOptions.port, v.port);
    writeToJson(jsonMap, TxClientOptions.tlsPort, v.tlsPort);
    writeToJson(jsonMap, TxClientOptions.autoConnect, v.autoConnect);
    writeToJson(jsonMap, TxClientOptions.useBinaryProtocol, v.useBinaryProtocol);
    writeToJson(jsonMap, TxClientOptions.queueMessages, v.queueMessages);
    writeToJson(jsonMap, TxClientOptions.echoMessages, v.echoMessages);
    writeToJson(jsonMap, TxClientOptions.recover, v.recover);
    writeToJson(jsonMap, TxClientOptions.environment, v.environment);
    writeToJson(jsonMap, TxClientOptions.idempotentRestPublishing, v.idempotentRestPublishing);
    writeToJson(jsonMap, TxClientOptions.httpOpenTimeout, v.httpOpenTimeout);
    writeToJson(jsonMap, TxClientOptions.httpRequestTimeout, v.httpRequestTimeout);
    writeToJson(jsonMap, TxClientOptions.httpMaxRetryCount, v.httpMaxRetryCount);
    writeToJson(jsonMap, TxClientOptions.realtimeRequestTimeout, v.realtimeRequestTimeout);
    writeToJson(jsonMap, TxClientOptions.fallbackHosts, v.fallbackHosts);
    writeToJson(jsonMap, TxClientOptions.fallbackHostsUseDefault, v.fallbackHostsUseDefault);
    writeToJson(jsonMap, TxClientOptions.fallbackRetryTimeout, v.fallbackRetryTimeout);
    writeToJson(jsonMap, TxClientOptions.defaultTokenParams, encodeTokenParams(v.defaultTokenParams));
    writeToJson(jsonMap, TxClientOptions.channelRetryTimeout, v.channelRetryTimeout);
    writeToJson(jsonMap, TxClientOptions.transportParams, v.transportParams);
    return jsonMap;
  }

  Map<String, dynamic> encodeTokenDetails(final TokenDetails v){
    if(v==null) return null;
    return {
      TxTokenDetails.token:  v.token,
      TxTokenDetails.expires:  v.expires,
      TxTokenDetails.issued:  v.issued,
      TxTokenDetails.capability:  v.capability,
      TxTokenDetails.clientId:  v.clientId,
    };
  }

  Map<String, dynamic> encodeTokenParams(final TokenParams v){
    if(v==null) return null;
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxTokenParams.capability, v.capability);
    writeToJson(jsonMap, TxTokenParams.clientId, v.clientId);
    writeToJson(jsonMap, TxTokenParams.nonce, v.nonce);
    writeToJson(jsonMap, TxTokenParams.timestamp, v.timestamp);
    writeToJson(jsonMap, TxTokenParams.ttl, v.ttl);
    return jsonMap;
  }

  Map<String, dynamic> encodeAblyMessage(final AblyMessage v){
    if(v==null) return null;
    int codecType = getCodecType(v.message);
    dynamic message = (v.message==null)?null:(codecType == null)?v.message:codecMap[codecType].encode(v.message);
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxAblyMessage.registrationHandle, v.registrationHandle);
    writeToJson(jsonMap, TxAblyMessage.type, codecType);
    writeToJson(jsonMap, TxAblyMessage.message, message);
    return jsonMap;
  }


  // =========== DECODERS ===========
  T readFromJson<T>(Map<String, dynamic> jsonMap, String key){
    dynamic value = jsonMap[key];
    if(value==null) return null;
    return value as T;
  }
  
  ClientOptions decodeClientOptions(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;

    final ClientOptions v = ClientOptions();
    // AuthOptions (super class of ClientOptions)
    v.authUrl = readFromJson<String>(jsonMap, TxClientOptions.authUrl);
    v.authMethod = readFromJson<HTTPMethods>(jsonMap, TxClientOptions.authMethod);
    v.key = readFromJson<String>(jsonMap, TxClientOptions.key);
    v.tokenDetails = decodeTokenDetails(toJsonMap(jsonMap[TxClientOptions.tokenDetails]));
    v.authHeaders = readFromJson<Map<String, String>>(jsonMap, TxClientOptions.authHeaders);
    v.authParams = readFromJson<Map<String, String>>(jsonMap, TxClientOptions.authParams);
    v.queryTime = readFromJson<bool>(jsonMap, TxClientOptions.queryTime);
    v.useTokenAuth = readFromJson<bool>(jsonMap, TxClientOptions.useTokenAuth);

    // ClientOptions
    v.clientId = readFromJson<String>(jsonMap, TxClientOptions.clientId);
    v.logLevel = readFromJson<int>(jsonMap, TxClientOptions.logLevel);
    //TODO handle logHandler
    v.tls = readFromJson<bool>(jsonMap, TxClientOptions.tls);
    v.restHost = readFromJson<String>(jsonMap, TxClientOptions.restHost);
    v.realtimeHost = readFromJson<String>(jsonMap, TxClientOptions.realtimeHost);
    v.port = readFromJson<int>(jsonMap, TxClientOptions.port);
    v.tlsPort = readFromJson<int>(jsonMap, TxClientOptions.tlsPort);
    v.autoConnect = readFromJson<bool>(jsonMap, TxClientOptions.autoConnect);
    v.useBinaryProtocol = readFromJson<bool>(jsonMap, TxClientOptions.useBinaryProtocol);
    v.queueMessages = readFromJson<bool>(jsonMap, TxClientOptions.queueMessages);
    v.echoMessages = readFromJson<bool>(jsonMap, TxClientOptions.echoMessages);
    v.recover = readFromJson<String>(jsonMap, TxClientOptions.recover);
    v.environment = readFromJson<String>(jsonMap, TxClientOptions.environment);
    v.idempotentRestPublishing = readFromJson<bool>(jsonMap, TxClientOptions.idempotentRestPublishing);
    v.httpOpenTimeout = readFromJson<int>(jsonMap, TxClientOptions.httpOpenTimeout);
    v.httpRequestTimeout = readFromJson<int>(jsonMap, TxClientOptions.httpRequestTimeout);
    v.httpMaxRetryCount = readFromJson<int>(jsonMap, TxClientOptions.httpMaxRetryCount);
    v.realtimeRequestTimeout = readFromJson<int>(jsonMap, TxClientOptions.realtimeRequestTimeout);
    v.fallbackHosts = readFromJson<List<String>>(jsonMap, TxClientOptions.fallbackHosts);
    v.fallbackHostsUseDefault = readFromJson<bool>(jsonMap, TxClientOptions.fallbackHostsUseDefault);
    v.fallbackRetryTimeout = readFromJson<int>(jsonMap, TxClientOptions.fallbackRetryTimeout);
    v.defaultTokenParams = decodeTokenParams(toJsonMap(jsonMap[TxClientOptions.defaultTokenParams]));
    v.channelRetryTimeout = readFromJson<int>(jsonMap, TxClientOptions.channelRetryTimeout);
    v.transportParams = readFromJson<Map<String, String>>(jsonMap, TxClientOptions.transportParams);
    return v;
  }

  TokenDetails decodeTokenDetails(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    TokenDetails v = TokenDetails(jsonMap[TxTokenDetails.token]);
    v.expires = readFromJson<int>(jsonMap, TxTokenDetails.expires);
    v.issued = readFromJson<int>(jsonMap, TxTokenDetails.issued);
    v.capability = readFromJson<String>(jsonMap, TxTokenDetails.capability);
    v.clientId = readFromJson<String>(jsonMap, TxTokenDetails.clientId);
    return v;
  }

  TokenParams decodeTokenParams(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    TokenParams v = TokenParams();
    v.capability = readFromJson<String>(jsonMap, TxTokenParams.capability);
    v.clientId = readFromJson<String>(jsonMap, TxTokenParams.clientId);
    v.nonce = readFromJson<String>(jsonMap, TxTokenParams.nonce);
    v.timestamp = readFromJson<DateTime>(jsonMap, TxTokenParams.timestamp);
    v.ttl = readFromJson<int>(jsonMap, TxTokenParams.ttl);
    return v;
  }

  AblyMessage decodeAblyMessage(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    int type = readFromJson<int>(jsonMap, TxAblyMessage.type);
    dynamic message = jsonMap[TxAblyMessage.message];
    if(type!=null){
      message = codecMap[type].decode(toJsonMap(jsonMap[TxAblyMessage.message]));
    }
    return AblyMessage(
        jsonMap[TxAblyMessage.registrationHandle] as int,
        message,
        type: type
    );
  }

  ErrorInfo decodeErrorInfo(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    return ErrorInfo(
        code: jsonMap[TxErrorInfo.code] as int,
        message: jsonMap[TxErrorInfo.message] as String,
        statusCode: jsonMap[TxErrorInfo.statusCode] as int,
        href: jsonMap[TxErrorInfo.href] as String,
        requestId: jsonMap[TxErrorInfo.requestId] as String,
        cause: jsonMap[TxErrorInfo.cause] as ErrorInfo
    );
  }

  ConnectionEvent decodeConnectionEvent(int index) => (index==null)?null:ConnectionEvent.values[index];
  ConnectionState decodeConnectionState(int index) => (index==null)?null:ConnectionState.values[index];
  ChannelEvent decodeChannelEvent(int index) => (index==null)?null:ChannelEvent.values[index];
  ChannelState decodeChannelState(int index) => (index==null)?null:ChannelState.values[index];

  ConnectionStateChange decodeConnectionStateChange(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    ConnectionState current = decodeConnectionState(readFromJson<int>(jsonMap, TxConnectionStateChange.current));
    ConnectionState previous = decodeConnectionState(readFromJson<int>(jsonMap, TxConnectionStateChange.previous));
    ConnectionEvent event = decodeConnectionEvent(readFromJson<int>(jsonMap, TxConnectionStateChange.event));
    int retryIn = readFromJson<int>(jsonMap, TxConnectionStateChange.retryIn);
    ErrorInfo reason = decodeErrorInfo(toJsonMap(jsonMap[TxConnectionStateChange.reason]));
    return ConnectionStateChange(current, previous, event, retryIn: retryIn, reason: reason);
  }

  ChannelStateChange decodeChannelStateChange(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    ChannelState current = decodeChannelState(readFromJson<int>(jsonMap, TxChannelStateChange.current));
    ChannelState previous = decodeChannelState(readFromJson<int>(jsonMap, TxChannelStateChange.previous));
    ChannelEvent event = decodeChannelEvent(readFromJson<int>(jsonMap, TxChannelStateChange.event));
    bool resumed = readFromJson<bool>(jsonMap, TxChannelStateChange.resumed);
    ErrorInfo reason = decodeErrorInfo(jsonMap[TxChannelStateChange.reason]);
    return ChannelStateChange(current, previous, event, resumed: resumed, reason: reason);
  }

}
