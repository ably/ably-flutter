import 'package:ably_flutter_plugin/src/gen/platformconstants.dart';
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
      //Ably flutter plugin protocol message
      CodecTypes.ablyMessage: CodecPair<AblyMessage>(encodeAblyMessage, decodeAblyMessage),

      //Other ably objects
      CodecTypes.clientOptions: CodecPair<ClientOptions>(encodeClientOptions, decodeClientOptions),
      CodecTypes.errorInfo: CodecPair<ErrorInfo>(null, decodeErrorInfo),

      //Events - Connection
      CodecTypes.connectionStateChange: CodecPair<ConnectionStateChange>(null, decodeConnectionStateChange),

      //Events - Channel
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
    } else if (value is TokenDetails) {
      return CodecTypes.tokenDetails;
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
    writeToJson(jsonMap, "authUrl", v.authUrl);
    writeToJson(jsonMap, "authMethod", v.authMethod);
    writeToJson(jsonMap, "key", v.key);
    writeToJson(jsonMap, "tokenDetails", encodeTokenDetails(v.tokenDetails));
    writeToJson(jsonMap, "authHeaders", v.authHeaders);
    writeToJson(jsonMap, "authParams", v.authParams);
    writeToJson(jsonMap, "queryTime", v.queryTime);
    writeToJson(jsonMap, "useTokenAuth", v.useTokenAuth);

    // ClientOptions
    writeToJson(jsonMap, "clientId", v.clientId);
    writeToJson(jsonMap, "logLevel", v.logLevel);
    //TODO handle logHandler
    writeToJson(jsonMap, "tls", v.tls);
    writeToJson(jsonMap, "restHost", v.restHost);
    writeToJson(jsonMap, "realtimeHost", v.realtimeHost);
    writeToJson(jsonMap, "port", v.port);
    writeToJson(jsonMap, "tlsPort", v.tlsPort);
    writeToJson(jsonMap, "autoConnect", v.autoConnect);
    writeToJson(jsonMap, "useBinaryProtocol", v.useBinaryProtocol);
    writeToJson(jsonMap, "queueMessages", v.queueMessages);
    writeToJson(jsonMap, "echoMessages", v.echoMessages);
    writeToJson(jsonMap, "recover", v.recover);
    writeToJson(jsonMap, "environment", v.environment);
    writeToJson(jsonMap, "idempotentRestPublishing", v.idempotentRestPublishing);
    writeToJson(jsonMap, "httpOpenTimeout", v.httpOpenTimeout);
    writeToJson(jsonMap, "httpRequestTimeout", v.httpRequestTimeout);
    writeToJson(jsonMap, "httpMaxRetryCount", v.httpMaxRetryCount);
    writeToJson(jsonMap, "realtimeRequestTimeout", v.realtimeRequestTimeout);
    writeToJson(jsonMap, "fallbackHosts", v.fallbackHosts);
    writeToJson(jsonMap, "fallbackHostsUseDefault", v.fallbackHostsUseDefault);
    writeToJson(jsonMap, "fallbackRetryTimeout", v.fallbackRetryTimeout);
    writeToJson(jsonMap, "defaultTokenParams", encodeTokenParams(v.defaultTokenParams));
    writeToJson(jsonMap, "channelRetryTimeout", v.channelRetryTimeout);
    writeToJson(jsonMap, "transportParams", v.transportParams);
    return jsonMap;
  }

  Map<String, dynamic> encodeTokenDetails(final TokenDetails v){
    if(v==null) return null;
    return {
      "token":  v.token,
      "expires":  v.expires,
      "issued":  v.issued,
      "capability":  v.capability,
      "clientId":  v.clientId,
    };
  }

  Map<String, dynamic> encodeTokenParams(final TokenParams v){
    if(v==null) return null;
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, "capability", v.capability);
    writeToJson(jsonMap, "clientId", v.clientId);
    writeToJson(jsonMap, "nonce", v.nonce);
    writeToJson(jsonMap, "timestamp", v.timestamp);
    writeToJson(jsonMap, "ttl", v.ttl);
    return jsonMap;
  }

  Map<String, dynamic> encodeAblyMessage(final AblyMessage v){
    if(v==null) return null;
    int codecType = getCodecType(v.message);
    dynamic message = (v.message==null)?null:(codecType == null)?v.message:codecMap[codecType].encode(v.message);
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, "registrationHandle", v.registrationHandle);
    writeToJson(jsonMap, "type", codecType);
    writeToJson(jsonMap, "message", message);
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
    v.authUrl = readFromJson<String>(jsonMap, "authUrl");
    v.authMethod = readFromJson<HTTPMethods>(jsonMap, "authMethod");
    v.key = readFromJson<String>(jsonMap, "key");
    v.tokenDetails = decodeTokenDetails(toJsonMap(jsonMap["tokenDetails"]));
    v.authHeaders = readFromJson<Map<String, String>>(jsonMap, "authHeaders");
    v.authParams = readFromJson<Map<String, String>>(jsonMap, "authParams");
    v.queryTime = readFromJson<bool>(jsonMap, "queryTime");
    v.useTokenAuth = readFromJson<bool>(jsonMap, "useTokenAuth");

    // ClientOptions
    v.clientId = readFromJson<String>(jsonMap, "clientId");
    v.logLevel = readFromJson<int>(jsonMap, "logLevel");
    //TODO handle logHandler
    v.tls = readFromJson<bool>(jsonMap, "tls");
    v.restHost = readFromJson<String>(jsonMap, "restHost");
    v.realtimeHost = readFromJson<String>(jsonMap, "realtimeHost");
    v.port = readFromJson<int>(jsonMap, "port");
    v.tlsPort = readFromJson<int>(jsonMap, "tlsPort");
    v.autoConnect = readFromJson<bool>(jsonMap, "autoConnect");
    v.useBinaryProtocol = readFromJson<bool>(jsonMap, "useBinaryProtocol");
    v.queueMessages = readFromJson<bool>(jsonMap, "queueMessages");
    v.echoMessages = readFromJson<bool>(jsonMap, "echoMessages");
    v.recover = readFromJson<String>(jsonMap, "recover");
    v.environment = readFromJson<String>(jsonMap, "environment");
    v.idempotentRestPublishing = readFromJson<bool>(jsonMap, "idempotentRestPublishing");
    v.httpOpenTimeout = readFromJson<int>(jsonMap, "httpOpenTimeout");
    v.httpRequestTimeout = readFromJson<int>(jsonMap, "httpRequestTimeout");
    v.httpMaxRetryCount = readFromJson<int>(jsonMap, "httpMaxRetryCount");
    v.realtimeRequestTimeout = readFromJson<int>(jsonMap, "realtimeRequestTimeout");
    v.fallbackHosts = readFromJson<List<String>>(jsonMap, "fallbackHosts");
    v.fallbackHostsUseDefault = readFromJson<bool>(jsonMap, "fallbackHostsUseDefault");
    v.fallbackRetryTimeout = readFromJson<int>(jsonMap, "fallbackRetryTimeout");
    v.defaultTokenParams = decodeTokenParams(toJsonMap(jsonMap["defaultTokenParams"]));
    v.channelRetryTimeout = readFromJson<int>(jsonMap, "channelRetryTimeout");
    v.transportParams = readFromJson<Map<String, String>>(jsonMap, "transportParams");
    return v;
  }

  TokenDetails decodeTokenDetails(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    TokenDetails v = TokenDetails(jsonMap["token"]);
    v.expires = readFromJson<int>(jsonMap, "expires");
    v.issued = readFromJson<int>(jsonMap, "issued");
    v.capability = readFromJson<String>(jsonMap, "capability");
    v.clientId = readFromJson<String>(jsonMap, "clientId");
    return v;
  }

  TokenParams decodeTokenParams(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    TokenParams v = TokenParams();
    v.capability = readFromJson<String>(jsonMap, "capability");
    v.clientId = readFromJson<String>(jsonMap, "clientId");
    v.nonce = readFromJson<String>(jsonMap, "nonce");
    v.timestamp = readFromJson<DateTime>(jsonMap, "timestamp");
    v.ttl = readFromJson<int>(jsonMap, "ttl");
    return v;
  }

  AblyMessage decodeAblyMessage(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    int type = readFromJson<int>(jsonMap, "type");
    dynamic message = jsonMap["message"];
    if(type!=null){
      message = codecMap[type].decode(toJsonMap(jsonMap["message"]));
    }
    return AblyMessage(
        jsonMap["registrationHandle"] as int,
        message,
        type: type
    );
  }

  ErrorInfo decodeErrorInfo(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    return ErrorInfo(
        code: jsonMap["code"] as int,
        message: jsonMap["message"] as String,
        statusCode: jsonMap["statusCode"] as int,
        href: jsonMap["href"] as String,
        requestId: jsonMap["requestId"] as String,
        cause: jsonMap["cause"] as ErrorInfo
    );
  }

  ConnectionEvent decodeConnectionEvent(int index) => (index==null)?null:ConnectionEvent.values[index];
  ConnectionState decodeConnectionState(int index) => (index==null)?null:ConnectionState.values[index];
  ChannelEvent decodeChannelEvent(int index) => (index==null)?null:ChannelEvent.values[index];
  ChannelState decodeChannelState(int index) => (index==null)?null:ChannelState.values[index];

  ConnectionStateChange decodeConnectionStateChange(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    ConnectionState current = decodeConnectionState(readFromJson<int>(jsonMap, "current"));
    ConnectionState previous = decodeConnectionState(readFromJson<int>(jsonMap, "previous"));
    ConnectionEvent event = decodeConnectionEvent(readFromJson<int>(jsonMap, "event"));
    int retryIn = readFromJson<int>(jsonMap, "retryIn");
    ErrorInfo reason = decodeErrorInfo(toJsonMap(jsonMap["reason"]));
    return ConnectionStateChange(current, previous, event, retryIn: retryIn, reason: reason);
  }

  ChannelStateChange decodeChannelStateChange(Map<String, dynamic> jsonMap){
    if(jsonMap==null) return null;
    ChannelState current = decodeChannelState(readFromJson<int>(jsonMap, "current"));
    ChannelState previous = decodeChannelState(readFromJson<int>(jsonMap, "previous"));
    ChannelEvent event = decodeChannelEvent(readFromJson<int>(jsonMap, "event"));
    bool resumed = readFromJson<bool>(jsonMap, "resumed");
    ErrorInfo reason = decodeErrorInfo(jsonMap["reason"]);
    return ChannelStateChange(current, previous, event, resumed: resumed, reason: reason);
  }

}
