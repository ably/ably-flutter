import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably_flutter_plugin.dart';
import '../src/generated/platformconstants.dart';
import '../src/impl/message.dart';

/// a [_Encoder] encodes custom type and converts it to a Map which will
/// be passed on to platform side
typedef Map<String, dynamic> _Encoder<T>(final T value);

/// a [_Decoder] decodes Map received from platform side and converts to
/// to respective dart types
typedef T _Decoder<T>(Map<String, dynamic> jsonMap);

/// A class to manage encoding/decoding by provided encoder/decoder functions.
class _CodecPair<T> {
  final _Encoder<T> _encoder;
  final _Decoder<T> _decoder;

  _CodecPair(this._encoder, this._decoder);

  /// Convert properties from an ably library object instance (dart) to Map.
  /// if passed [value] is null, encoder will not be called.
  /// This method will throw an [AblyException] if encoder is null.
  Map<String, dynamic> encode(final Object value) {
    if (_encoder == null) throw AblyException("Codec encoder is null");
    if (value == null) return null;
    return _encoder(value as T);
  }

  /// Convert Map entries to an ably library object instance (dart).
  /// if passed [jsonMap] is null, decoder will not be called.
  /// This method will throw an [AblyException] if decoder is null.
  T decode(Map<String, dynamic> jsonMap) {
    if (_decoder == null) throw AblyException("Codec decoder is null");
    if (jsonMap == null) return null;
    return _decoder(jsonMap);
  }
}

class Codec extends StandardMessageCodec {
  /// Map of codec type (a value from [CodecTypes]) vs encoder/decoder pair.
  /// Encoder/decoder can be null.
  /// For example, [ErrorInfo] only needs a decoder but not an encoder.
  Map<int, _CodecPair> codecMap;

  Codec() : super() {
    codecMap = {
      // Ably flutter plugin protocol message
      CodecTypes.ablyMessage:
          _CodecPair<AblyMessage>(encodeAblyMessage, decodeAblyMessage),
      CodecTypes.ablyEventMessage:
          _CodecPair<AblyEventMessage>(encodeAblyEventMessage, null),

      // Other ably objects
      CodecTypes.clientOptions:
          _CodecPair<ClientOptions>(encodeClientOptions, decodeClientOptions),
      CodecTypes.tokenParams:
          _CodecPair<TokenParams>(encodeTokenParams, decodeTokenParams),
      CodecTypes.tokenDetails:
          _CodecPair<TokenDetails>(encodeTokenDetails, decodeTokenDetails),
      CodecTypes.tokenRequest:
          _CodecPair<TokenRequest>(encodeTokenRequest, null),
      CodecTypes.paginatedResult:
          _CodecPair<PaginatedResult>(null, decodePaginatedResult),
      CodecTypes.restHistoryParams:
          _CodecPair<RestHistoryParams>(encodeRestHistoryParams, null),

      CodecTypes.errorInfo: _CodecPair<ErrorInfo>(null, decodeErrorInfo),
      CodecTypes.message:
          _CodecPair<Message>(encodeChannelMessage, decodeChannelMessage),

      // Events - Connection
      CodecTypes.connectionStateChange:
          _CodecPair<ConnectionStateChange>(null, decodeConnectionStateChange),

      // Events - Channel
      CodecTypes.channelStateChange:
          _CodecPair<ChannelStateChange>(null, decodeChannelStateChange),
    };
  }

  /// Converts a Map with dynamic keys and values to
  /// a Map with String keys and dynamic values.
  /// Returns null of [value] is null.
  Map<String, dynamic> toJsonMap(Map<dynamic, dynamic> value) {
    if (value == null) return null;
    return Map.castFrom<dynamic, dynamic, String, dynamic>(value);
  }

  /// Returns a value from [CodecTypes] based of the [Type] of [value]
  int getCodecType(final Object value) {
    if (value is ClientOptions) {
      return CodecTypes.clientOptions;
    } else if (value is TokenDetails) {
      return CodecTypes.tokenDetails;
    } else if (value is TokenParams) {
      return CodecTypes.tokenParams;
    } else if (value is TokenRequest) {
      return CodecTypes.tokenRequest;
    } else if (value is Message) {
      return CodecTypes.message;
    } else if (value is RestHistoryParams) {
      return CodecTypes.restHistoryParams;
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
  void writeValue(final WriteBuffer buffer, final Object value) {
    int type = getCodecType(value);
    if (type == null) {
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
    if (pair == null) {
      return super.readValueOfType(type, buffer);
    } else {
      Map<String, dynamic> map = toJsonMap(readValue(buffer) as Map);
      return pair.decode(map);
    }
  }

  // =========== ENCODERS ===========
  /// Writes [value] for [key] in [map] if [value] is not null
  writeToJson(Map<String, dynamic> map, String key, Object value) {
    assert(!(value is DateTime), "`DateTime` objects cannot be encoded");
    if (value == null) return;
    map[key] = value;
  }

  /// Encodes [ClientOptions] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeClientOptions(final ClientOptions v) {
    if (v == null) return null;
    Map<String, dynamic> jsonMap = {};
    // AuthOptions (super class of ClientOptions)
    writeToJson(jsonMap, TxClientOptions.authUrl, v.authUrl);
    writeToJson(jsonMap, TxClientOptions.authMethod, v.authMethod);
    writeToJson(jsonMap, TxClientOptions.key, v.key);
    writeToJson(jsonMap, TxClientOptions.tokenDetails,
        encodeTokenDetails(v.tokenDetails));
    writeToJson(jsonMap, TxClientOptions.authHeaders, v.authHeaders);
    writeToJson(jsonMap, TxClientOptions.authParams, v.authParams);
    writeToJson(jsonMap, TxClientOptions.queryTime, v.queryTime);
    writeToJson(jsonMap, TxClientOptions.useTokenAuth, v.useTokenAuth);
    writeToJson(
        jsonMap, TxClientOptions.hasAuthCallback, v.authCallback != null);

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
    writeToJson(
        jsonMap, TxClientOptions.useBinaryProtocol, v.useBinaryProtocol);
    writeToJson(jsonMap, TxClientOptions.queueMessages, v.queueMessages);
    writeToJson(jsonMap, TxClientOptions.echoMessages, v.echoMessages);
    writeToJson(jsonMap, TxClientOptions.recover, v.recover);
    writeToJson(jsonMap, TxClientOptions.environment, v.environment);
    writeToJson(jsonMap, TxClientOptions.idempotentRestPublishing,
        v.idempotentRestPublishing);
    writeToJson(jsonMap, TxClientOptions.httpOpenTimeout, v.httpOpenTimeout);
    writeToJson(
        jsonMap, TxClientOptions.httpRequestTimeout, v.httpRequestTimeout);
    writeToJson(
        jsonMap, TxClientOptions.httpMaxRetryCount, v.httpMaxRetryCount);
    writeToJson(jsonMap, TxClientOptions.realtimeRequestTimeout,
        v.realtimeRequestTimeout);
    writeToJson(jsonMap, TxClientOptions.fallbackHosts, v.fallbackHosts);
    writeToJson(jsonMap, TxClientOptions.fallbackHostsUseDefault,
        v.fallbackHostsUseDefault);
    writeToJson(
        jsonMap, TxClientOptions.fallbackRetryTimeout, v.fallbackRetryTimeout);
    writeToJson(jsonMap, TxClientOptions.defaultTokenParams,
        encodeTokenParams(v.defaultTokenParams));
    writeToJson(
        jsonMap, TxClientOptions.channelRetryTimeout, v.channelRetryTimeout);
    writeToJson(jsonMap, TxClientOptions.transportParams, v.transportParams);
    return jsonMap;
  }

  /// Encodes [TokenDetails] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeTokenDetails(final TokenDetails v) {
    if (v == null) return null;
    return {
      TxTokenDetails.token: v.token,
      TxTokenDetails.expires: v.expires,
      TxTokenDetails.issued: v.issued,
      TxTokenDetails.capability: v.capability,
      TxTokenDetails.clientId: v.clientId,
    };
  }

  /// Encodes [TokenParams] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeTokenParams(final TokenParams v) {
    if (v == null) return null;
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxTokenParams.capability, v.capability);
    writeToJson(jsonMap, TxTokenParams.clientId, v.clientId);
    writeToJson(jsonMap, TxTokenParams.nonce, v.nonce);
    writeToJson(jsonMap, TxTokenParams.timestamp, v.timestamp);
    writeToJson(jsonMap, TxTokenParams.ttl, v.ttl);
    return jsonMap;
  }

  /// Encodes [TokenRequest] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeTokenRequest(final TokenRequest v) {
    if (v == null) return null;
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxTokenRequest.capability, v.capability);
    writeToJson(jsonMap, TxTokenRequest.clientId, v.clientId);
    writeToJson(jsonMap, TxTokenRequest.keyName, v.keyName);
    writeToJson(jsonMap, TxTokenRequest.mac, v.mac);
    writeToJson(jsonMap, TxTokenRequest.nonce, v.nonce);
    writeToJson(
        jsonMap, TxTokenRequest.timestamp, v.timestamp?.millisecondsSinceEpoch);
    writeToJson(jsonMap, TxTokenRequest.ttl, v.ttl);
    return jsonMap;
  }

  Map<String, dynamic> encodeRestHistoryParams(final RestHistoryParams v) {
    if (v == null) return null;
    var jsonMap = <String, dynamic>{};
    writeToJson(
        jsonMap, TxRestHistoryParams.start, v.start?.millisecondsSinceEpoch);
    writeToJson(
        jsonMap, TxRestHistoryParams.end, v.end?.millisecondsSinceEpoch);
    writeToJson(jsonMap, TxRestHistoryParams.direction, v.direction);
    writeToJson(jsonMap, TxRestHistoryParams.limit, v.limit);
    return jsonMap;
  }

  /// Encodes [AblyMessage] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeAblyMessage(final AblyMessage v) {
    if (v == null) return null;
    int codecType = getCodecType(v.message);
    dynamic message = (v.message == null)
        ? null
        : (codecType == null)
            ? v.message
            : codecMap[codecType].encode(v.message);
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxAblyMessage.registrationHandle, v.handle);
    writeToJson(jsonMap, TxAblyMessage.type, codecType);
    writeToJson(jsonMap, TxAblyMessage.message, message);
    return jsonMap;
  }

  /// Encodes [AblyEventMessage] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> encodeAblyEventMessage(final AblyEventMessage v) {
    if (v == null) return null;
    int codecType = getCodecType(v.message);
    dynamic message = (v.message == null)
        ? null
        : (codecType == null)
            ? v.message
            : codecMap[codecType].encode(v.message);
    Map<String, dynamic> jsonMap = {};
    writeToJson(jsonMap, TxAblyEventMessage.eventName, v.eventName);
    writeToJson(jsonMap, TxAblyEventMessage.type, codecType);
    writeToJson(jsonMap, TxAblyEventMessage.message, message);
    return jsonMap;
  }

  Map<String, dynamic> encodeChannelMessage(final Message v) {
    if (v == null) return null;
    Map<String, dynamic> jsonMap = {};
    // Note: connectionId and timestamp are automatically set by platform
    // So they are suppressed on dart side
    writeToJson(jsonMap, TxMessage.name, v.name);
    writeToJson(jsonMap, TxMessage.clientId, v.clientId);
    writeToJson(jsonMap, TxMessage.data, v.data);
    writeToJson(jsonMap, TxMessage.id, v.id);
    writeToJson(jsonMap, TxMessage.encoding, v.encoding);
    writeToJson(jsonMap, TxMessage.extras, v.extras);
    return jsonMap;
  }

  // =========== DECODERS ===========
  /// Reads [key] value from [jsonMap]
  /// Casts it to [T] if the value is not null
  T readFromJson<T>(Map<String, dynamic> jsonMap, String key) {
    dynamic value = jsonMap[key];
    if (value == null) return null;
    return value as T;
  }

  /// Decodes value [jsonMap] to [ClientOptions]
  /// returns null if [jsonMap] is null
  ClientOptions decodeClientOptions(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;

    return ClientOptions()
      // AuthOptions (super class of ClientOptions)
      ..authUrl = readFromJson<String>(jsonMap, TxClientOptions.authUrl)
      ..authMethod =
          readFromJson<HTTPMethods>(jsonMap, TxClientOptions.authMethod)
      ..key = readFromJson<String>(jsonMap, TxClientOptions.key)
      ..tokenDetails = decodeTokenDetails(
          toJsonMap(readFromJson<Map>(jsonMap, TxClientOptions.tokenDetails)))
      ..authHeaders = readFromJson<Map<String, String>>(
          jsonMap, TxClientOptions.authHeaders)
      ..authParams =
          readFromJson<Map<String, String>>(jsonMap, TxClientOptions.authParams)
      ..queryTime = readFromJson<bool>(jsonMap, TxClientOptions.queryTime)
      ..useTokenAuth = readFromJson<bool>(jsonMap, TxClientOptions.useTokenAuth)

      // ClientOptions
      ..clientId = readFromJson<String>(jsonMap, TxClientOptions.clientId)
      ..logLevel = readFromJson<int>(jsonMap, TxClientOptions.logLevel)
      //TODO handle logHandler
      ..tls = readFromJson<bool>(jsonMap, TxClientOptions.tls)
      ..restHost = readFromJson<String>(jsonMap, TxClientOptions.restHost)
      ..realtimeHost =
          readFromJson<String>(jsonMap, TxClientOptions.realtimeHost)
      ..port = readFromJson<int>(jsonMap, TxClientOptions.port)
      ..tlsPort = readFromJson<int>(jsonMap, TxClientOptions.tlsPort)
      ..autoConnect = readFromJson<bool>(jsonMap, TxClientOptions.autoConnect)
      ..useBinaryProtocol =
          readFromJson<bool>(jsonMap, TxClientOptions.useBinaryProtocol)
      ..queueMessages =
          readFromJson<bool>(jsonMap, TxClientOptions.queueMessages)
      ..echoMessages = readFromJson<bool>(jsonMap, TxClientOptions.echoMessages)
      ..recover = readFromJson<String>(jsonMap, TxClientOptions.recover)
      ..environment = readFromJson<String>(jsonMap, TxClientOptions.environment)
      ..idempotentRestPublishing =
          readFromJson<bool>(jsonMap, TxClientOptions.idempotentRestPublishing)
      ..httpOpenTimeout =
          readFromJson<int>(jsonMap, TxClientOptions.httpOpenTimeout)
      ..httpRequestTimeout =
          readFromJson<int>(jsonMap, TxClientOptions.httpRequestTimeout)
      ..httpMaxRetryCount =
          readFromJson<int>(jsonMap, TxClientOptions.httpMaxRetryCount)
      ..realtimeRequestTimeout =
          readFromJson<int>(jsonMap, TxClientOptions.realtimeRequestTimeout)
      ..fallbackHosts =
          readFromJson<List<String>>(jsonMap, TxClientOptions.fallbackHosts)
      ..fallbackHostsUseDefault =
          readFromJson<bool>(jsonMap, TxClientOptions.fallbackHostsUseDefault)
      ..fallbackRetryTimeout =
          readFromJson<int>(jsonMap, TxClientOptions.fallbackRetryTimeout)
      ..defaultTokenParams = decodeTokenParams(toJsonMap(
          readFromJson<Map>(jsonMap, TxClientOptions.defaultTokenParams)))
      ..channelRetryTimeout =
          readFromJson<int>(jsonMap, TxClientOptions.channelRetryTimeout)
      ..transportParams = readFromJson<Map<String, String>>(
          jsonMap, TxClientOptions.transportParams);
  }

  /// Decodes value [jsonMap] to [TokenDetails]
  /// returns null if [jsonMap] is null
  TokenDetails decodeTokenDetails(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return TokenDetails(readFromJson<String>(jsonMap, TxTokenDetails.token))
      ..expires = readFromJson<int>(jsonMap, TxTokenDetails.expires)
      ..issued = readFromJson<int>(jsonMap, TxTokenDetails.issued)
      ..capability = readFromJson<String>(jsonMap, TxTokenDetails.capability)
      ..clientId = readFromJson<String>(jsonMap, TxTokenDetails.clientId);
  }

  /// Decodes value [jsonMap] to [TokenParams]
  /// returns null if [jsonMap] is null
  TokenParams decodeTokenParams(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return TokenParams()
      ..capability = readFromJson<String>(jsonMap, TxTokenParams.capability)
      ..clientId = readFromJson<String>(jsonMap, TxTokenParams.clientId)
      ..nonce = readFromJson<String>(jsonMap, TxTokenParams.nonce)
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(
          readFromJson<int>(jsonMap, TxTokenParams.timestamp))
      ..ttl = readFromJson<int>(jsonMap, TxTokenParams.ttl);
  }

  /// Decodes value [jsonMap] to [AblyMessage]
  /// returns null if [jsonMap] is null
  AblyMessage decodeAblyMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    int type = readFromJson<int>(jsonMap, TxAblyMessage.type);
    dynamic message = jsonMap[TxAblyMessage.message];
    if (type != null) {
      message = codecMap[type]
          .decode(toJsonMap(readFromJson<Map>(jsonMap, TxAblyMessage.message)));
    }
    return AblyMessage(message,
        handle: jsonMap[TxAblyMessage.registrationHandle] as int, type: type);
  }

  /// Decodes value [jsonMap] to [ErrorInfo]
  /// returns null if [jsonMap] is null
  ErrorInfo decodeErrorInfo(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return ErrorInfo(
        code: jsonMap[TxErrorInfo.code] as int,
        message: jsonMap[TxErrorInfo.message] as String,
        statusCode: jsonMap[TxErrorInfo.statusCode] as int,
        href: jsonMap[TxErrorInfo.href] as String,
        requestId: jsonMap[TxErrorInfo.requestId] as String,
        cause: jsonMap[TxErrorInfo.cause] as ErrorInfo);
  }

  /// Decodes [index] value to [ConnectionEvent] enum if not null
    ConnectionEvent decodeConnectionEvent(String eventName) {
      switch (eventName) {
        case TxEnumConstants.initialized:
          return ConnectionEvent.initialized;
        case TxEnumConstants.connecting:
          return ConnectionEvent.connecting;
        case TxEnumConstants.connected:
          return ConnectionEvent.connected;
        case TxEnumConstants.disconnected:
          return ConnectionEvent.disconnected;
        case TxEnumConstants.suspended:
          return ConnectionEvent.suspended;
        case TxEnumConstants.closing:
          return ConnectionEvent.closing;
        case TxEnumConstants.closed:
          return ConnectionEvent.closed;
        case TxEnumConstants.failed:
          return ConnectionEvent.failed;
        case TxEnumConstants.update:
          return ConnectionEvent.update;
      }
    }

    /// Decodes [state] to [ConnectionState] enum if not null
    ConnectionState decodeConnectionState(String state) {
      if (state == null) return null;
      switch (state) {
        case TxEnumConstants.initialized:
          return ConnectionState.initialized;
        case TxEnumConstants.connecting:
          return ConnectionState.connecting;
        case TxEnumConstants.connected:
          return ConnectionState.connected;
        case TxEnumConstants.disconnected:
          return ConnectionState.disconnected;
        case TxEnumConstants.suspended:
          return ConnectionState.suspended;
        case TxEnumConstants.closing:
          return ConnectionState.closing;
        case TxEnumConstants.closed:
          return ConnectionState.closed;
        case TxEnumConstants.failed:
          return ConnectionState.failed;
      }
    }

    /// Decodes [eventName] to [ChannelEvent] enum if not null
    ChannelEvent decodeChannelEvent(String eventName) {
      switch (eventName) {
        case TxEnumConstants.initialized:
          return ChannelEvent.initialized;
        case TxEnumConstants.attaching:
          return ChannelEvent.attaching;
        case TxEnumConstants.attached:
          return ChannelEvent.attached;
        case TxEnumConstants.detaching:
          return ChannelEvent.detaching;
        case TxEnumConstants.detached:
          return ChannelEvent.detached;
        case TxEnumConstants.suspended:
          return ChannelEvent.suspended;
        case TxEnumConstants.failed:
          return ChannelEvent.failed;
        case TxEnumConstants.update:
          return ChannelEvent.update;
      }
    }

    /// Decodes [state] to [ChannelState] enum if not null
    ChannelState decodeChannelState(String state) {
      switch (state) {
        case TxEnumConstants.initialized:
          return ChannelState.initialized;
        case TxEnumConstants.attaching:
          return ChannelState.attaching;
        case TxEnumConstants.attached:
          return ChannelState.attached;
        case TxEnumConstants.detaching:
          return ChannelState.detaching;
        case TxEnumConstants.detached:
          return ChannelState.detached;
        case TxEnumConstants.suspended:
          return ChannelState.suspended;
        case TxEnumConstants.failed:
          return ChannelState.failed;
      }
    }

  /// Decodes value [jsonMap] to [ConnectionStateChange]
  /// returns null if [jsonMap] is null
  ConnectionStateChange decodeConnectionStateChange(
      Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    ConnectionState current = decodeConnectionState(readFromJson<String>(jsonMap, TxConnectionStateChange.current));
    ConnectionState previous = decodeConnectionState(readFromJson<String>(jsonMap, TxConnectionStateChange.previous));
    ConnectionEvent event = decodeConnectionEvent(readFromJson<String>(jsonMap, TxConnectionStateChange.event));
    int retryIn = readFromJson<int>(jsonMap, TxConnectionStateChange.retryIn);
    ErrorInfo reason = decodeErrorInfo(
        toJsonMap(readFromJson<Map>(jsonMap, TxConnectionStateChange.reason)));
    return ConnectionStateChange(current, previous, event,
        retryIn: retryIn, reason: reason);
  }

  /// Decodes value [jsonMap] to [ChannelStateChange]
  /// returns null if [jsonMap] is null
  ChannelStateChange decodeChannelStateChange(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    ChannelState current = decodeChannelState(readFromJson<String>(jsonMap, TxChannelStateChange.current));
    ChannelState previous = decodeChannelState(readFromJson<String>(jsonMap, TxChannelStateChange.previous));
    ChannelEvent event = decodeChannelEvent(readFromJson<String>(jsonMap, TxChannelStateChange.event));
    bool resumed = readFromJson<bool>(jsonMap, TxChannelStateChange.resumed);
    ErrorInfo reason = decodeErrorInfo(
        toJsonMap(readFromJson<Map>(jsonMap, TxChannelStateChange.reason)));
    return ChannelStateChange(current, previous, event,
        resumed: resumed, reason: reason);
  }

  Message decodeChannelMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    var message = Message(
        name: readFromJson<String>(jsonMap, TxMessage.name),
        clientId: readFromJson<String>(jsonMap, TxMessage.clientId),
        data: readFromJson<dynamic>(jsonMap, TxMessage.data))
      ..id = readFromJson<String>(jsonMap, TxMessage.id)
      ..connectionId = readFromJson<String>(jsonMap, TxMessage.connectionId)
      ..encoding = readFromJson<String>(jsonMap, TxMessage.encoding)
      ..extras = readFromJson<Map>(jsonMap, TxMessage.extras);
    var timestamp = readFromJson<int>(jsonMap, TxMessage.timestamp);
    if (timestamp != null) {
      message.timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return message;
  }

  PaginatedResult<Object> decodePaginatedResult(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    var type = readFromJson<int>(jsonMap, TxPaginatedResult.type);
    var items = readFromJson<List<Map>>(jsonMap, TxPaginatedResult.items)
            ?.map((e) => codecMap[type].decode(toJsonMap(e)))
            ?.toList() ??
        [];
    return PaginatedResult(items,
        hasNext: readFromJson(jsonMap, TxPaginatedResult.hasNext) as bool);
  }
}
