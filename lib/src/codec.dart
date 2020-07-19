import 'package:ably_flutter_plugin/src/generated/platformconstants.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably.dart';


/// a [_Encoder] encodes custom type and converts it to a Map which will
/// be passed on to platform side
typedef Map<String, dynamic> _Encoder<T>(final T value);

/// a [_Decoder] decodes Map received from platform side and converts to
/// to respective dart types
typedef T _Decoder<T>(Map<String, dynamic> jsonMap);

/// A class to manage encoding/decoding by provided encoder/decoder functions.
class _CodecPair<T>{

    final _Encoder<T> _encoder;
    final _Decoder<T> _decoder;
    _CodecPair(this._encoder, this._decoder);

    /// Convert properties from an ably library object instance (dart) to Map.
    /// if passed [value] is null, encoder will not be called.
    /// This method will throw an [AblyException] if encoder is null.
    Map<String, dynamic> encode(final dynamic value){
        if (this._encoder==null) throw AblyException("Codec encoder is null");
        if(value==null) return null;
        return this._encoder(value as T);
    }

    /// Convert Map entries to an ably library object instance (dart).
    /// if passed [jsonMap] is null, decoder will not be called.
    /// This method will throw an [AblyException] if decoder is null.
    T decode(Map<String, dynamic> jsonMap){
        if (this._decoder==null) throw AblyException("Codec decoder is null");
        if(jsonMap==null) return null;
        return this._decoder(jsonMap);
    }

}


class Codec extends StandardMessageCodec {

    /// Map of codec type (a value from [CodecTypes]) vs encoder/decoder pair.
    /// Encoder/decoder can be null.
    /// For example, [ErrorInfo] only needs a decoder but not an encoder.
    Map<int, _CodecPair> codecMap;

    Codec():super(){
        this.codecMap = {
            // Ably flutter plugin protocol message
            CodecTypes.ablyMessage: _CodecPair<AblyMessage>(encodeAblyMessage, decodeAblyMessage),
            CodecTypes.ablyEventMessage: _CodecPair<AblyEventMessage>(encodeAblyEventMessage, null),

            // Other ably objects
            CodecTypes.clientOptions: _CodecPair<ClientOptions>(encodeClientOptions, decodeClientOptions),
            CodecTypes.errorInfo: _CodecPair<ErrorInfo>(null, decodeErrorInfo),

            // Events - Connection
            CodecTypes.connectionStateChange: _CodecPair<ConnectionStateChange>(null, decodeConnectionStateChange),

            // Events - Channel
            CodecTypes.channelStateChange: _CodecPair<ChannelStateChange>(null, decodeChannelStateChange),
        };
    }

    /// Converts a Map with dynamic keys and values to
    /// a Map with String keys and dynamic values.
    /// Returns null of [value] is null.
    Map<String, dynamic> toJsonMap(Map<dynamic, dynamic> value){
        if(value==null) return null;
        return Map.castFrom<dynamic, dynamic, String, dynamic>(value);
    }

    /// Returns a value from [CodecTypes] based of the [Type] of [value]
    int getCodecType(final dynamic value){
        if (value is ClientOptions) {
            return CodecTypes.clientOptions;
        } else if (value is ErrorInfo) {
            return CodecTypes.errorInfo;
        } else if (value is AblyMessage) {
            return CodecTypes.ablyMessage;
        } else if (value is AblyEventMessage) {
          return CodecTypes.ablyEventMessage;
        }
        return null;
    }

    /// Encodes values from [_CodecPair._encoder] available in [_CodecPair]
    /// obtained from [codecMap] against codecType obtained from [value].
    /// If decoder is not found, [StandardMessageCodec] is used to read value
    @override
    void writeValue(final WriteBuffer buffer, final dynamic value) {
        int type = getCodecType(value);
        if (type==null) {
            super.writeValue(buffer, value);
        } else {
            buffer.putUint8(type);
            writeValue(buffer, codecMap[type].encode(value));
        }
    }

    /// Decodes values from [_CodecPair._decoder] available in codec pair,
    /// obtained from [codecMap] against [type].
    /// If decoder is not found, [StandardMessageCodec] is used to read value
    @override
    dynamic readValueOfType(int type, ReadBuffer buffer) {
        _CodecPair pair = codecMap[type];
        if (pair==null) {
            return super.readValueOfType(type, buffer);
        } else {
            Map<String, dynamic> map = toJsonMap(readValue(buffer));
            return pair.decode(map);
        }
    }

    // =========== ENCODERS ===========
    /// Writes [value] for [key] in [map] if [value] is not null
    writeToJson(Map<String, dynamic> map, key, value){
        if(value==null) return;
        map[key] = value;
    }

    /// Encodes [ClientOptions] to a Map
    /// returns null of passed value [v] is null
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

    /// Encodes [TokenDetails] to a Map
    /// returns null of passed value [v] is null
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

    /// Encodes [TokenParams] to a Map
    /// returns null of passed value [v] is null
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

    /// Encodes [AblyMessage] to a Map
    /// returns null of passed value [v] is null
    Map<String, dynamic> encodeAblyMessage(final AblyMessage v){
        if(v==null) return null;
        int codecType = getCodecType(v.message);
        dynamic message = (v.message==null)?null:(codecType == null)?v.message:codecMap[codecType].encode(v.message);
        Map<String, dynamic> jsonMap = {};
        writeToJson(jsonMap, TxAblyMessage.registrationHandle, v.handle);
        writeToJson(jsonMap, TxAblyMessage.type, codecType);
        writeToJson(jsonMap, TxAblyMessage.message, message);
        return jsonMap;
    }

    /// Encodes [AblyEventMessage] to a Map
    /// returns null of passed value [v] is null
    Map<String, dynamic> encodeAblyEventMessage(final AblyEventMessage v){
      if(v==null) return null;
      int codecType = getCodecType(v.message);
      dynamic message = (v.message==null)?null:(codecType == null)?v.message:codecMap[codecType].encode(v.message);
      Map<String, dynamic> jsonMap = {};
      writeToJson(jsonMap, TxAblyEventMessage.eventName, v.eventName);
      writeToJson(jsonMap, TxAblyEventMessage.type, codecType);
      writeToJson(jsonMap, TxAblyEventMessage.message, message);
      return jsonMap;
    }


    // =========== DECODERS ===========
    /// Reads [key] value from [jsonMap]
    /// Casts it to [T] if the value is not null
    T readFromJson<T>(Map<String, dynamic> jsonMap, String key){
        dynamic value = jsonMap[key];
        if(value==null) return null;
        return value as T;
    }

    /// Decodes value [jsonMap] to [ClientOptions]
    /// returns null if [jsonMap] is null
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

    /// Decodes value [jsonMap] to [TokenDetails]
    /// returns null if [jsonMap] is null
    TokenDetails decodeTokenDetails(Map<String, dynamic> jsonMap){
        if(jsonMap==null) return null;
        TokenDetails v = TokenDetails(jsonMap[TxTokenDetails.token]);
        v.expires = readFromJson<int>(jsonMap, TxTokenDetails.expires);
        v.issued = readFromJson<int>(jsonMap, TxTokenDetails.issued);
        v.capability = readFromJson<String>(jsonMap, TxTokenDetails.capability);
        v.clientId = readFromJson<String>(jsonMap, TxTokenDetails.clientId);
        return v;
    }

    /// Decodes value [jsonMap] to [TokenParams]
    /// returns null if [jsonMap] is null
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

    /// Decodes value [jsonMap] to [AblyMessage]
    /// returns null if [jsonMap] is null
    AblyMessage decodeAblyMessage(Map<String, dynamic> jsonMap){
        if(jsonMap==null) return null;
        int type = readFromJson<int>(jsonMap, TxAblyMessage.type);
        dynamic message = jsonMap[TxAblyMessage.message];
        if(type!=null){
            message = codecMap[type].decode(toJsonMap(jsonMap[TxAblyMessage.message]));
        }
        return AblyMessage(
            message,
            handle: jsonMap[TxAblyMessage.registrationHandle] as int,
            type: type
        );
    }

    /// Decodes value [jsonMap] to [ErrorInfo]
    /// returns null if [jsonMap] is null
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

    /// Decodes [index] value to [ConnectionEvent] enum if not null
    ConnectionEvent decodeConnectionEvent(int index) => (index==null)?null:ConnectionEvent.values[index];

    /// Decodes [index] value to [ConnectionState] enum if not null
    ConnectionState decodeConnectionState(int index) => (index==null)?null:ConnectionState.values[index];

    /// Decodes [index] value to [ChannelEvent] enum if not null
    ChannelEvent decodeChannelEvent(int index) => (index==null)?null:ChannelEvent.values[index];

    /// Decodes [index] value to [ChannelState] enum if not null
    ChannelState decodeChannelState(int index) => (index==null)?null:ChannelState.values[index];

    /// Decodes value [jsonMap] to [ConnectionStateChange]
    /// returns null if [jsonMap] is null
    ConnectionStateChange decodeConnectionStateChange(Map<String, dynamic> jsonMap){
        if(jsonMap==null) return null;
        ConnectionState current = decodeConnectionState(readFromJson<int>(jsonMap, TxConnectionStateChange.current));
        ConnectionState previous = decodeConnectionState(readFromJson<int>(jsonMap, TxConnectionStateChange.previous));
        ConnectionEvent event = decodeConnectionEvent(readFromJson<int>(jsonMap, TxConnectionStateChange.event));
        int retryIn = readFromJson<int>(jsonMap, TxConnectionStateChange.retryIn);
        ErrorInfo reason = decodeErrorInfo(toJsonMap(jsonMap[TxConnectionStateChange.reason]));
        return ConnectionStateChange(current, previous, event, retryIn: retryIn, reason: reason);
    }

    /// Decodes value [jsonMap] to [ChannelStateChange]
    /// returns null if [jsonMap] is null
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
