import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ably_flutter.dart';
import '../src/generated/platformconstants.dart';
import '../src/impl/message.dart';

/// a [_Encoder] encodes custom type and converts it to a Map which will
/// be passed on to platform side
typedef _Encoder<T> = Map<String, dynamic> Function(T value);

/// a [_Decoder] decodes Map received from platform side and converts to
/// to respective dart types
typedef _Decoder<T> = T Function(Map<String, dynamic> jsonMap);

/// A class to manage encoding/decoding by provided encoder/decoder functions.
class _CodecPair<T> {
  final _Encoder<T> _encoder;
  final _Decoder<T> _decoder;

  _CodecPair(this._encoder, this._decoder);

  /// Convert properties from an ably library object instance (dart) to Map.
  /// if passed [value] is null, encoder will not be called.
  /// This method will throw an [AblyException] if encoder is null.
  Map<String, dynamic> encode(final Object value) {
    if (_encoder == null) throw AblyException('Codec encoder is null');
    if (value == null) return null;
    return _encoder(value as T);
  }

  /// Convert Map entries to an ably library object instance (dart).
  /// if passed [jsonMap] is null, decoder will not be called.
  /// This method will throw an [AblyException] if decoder is null.
  T decode(Map<String, dynamic> jsonMap) {
    if (_decoder == null) throw AblyException('Codec decoder is null');
    if (jsonMap == null) return null;
    return _decoder(jsonMap);
  }
}

/// Custom message codec for encoding objects to send to platform
/// or decoding objects received from platform.
class Codec extends StandardMessageCodec {
  /// Map of codec type (a value from [CodecTypes]) vs encoder/decoder pair.
  /// Encoder/decoder can be null.
  /// For example, [ErrorInfo] only needs a decoder but not an encoder.
  Map<int, _CodecPair> codecMap;

  /// initializes codec with codec map linking codec type to codec pair
  Codec() : super() {
    codecMap = {
      // Ably flutter plugin protocol message
      CodecTypes.ablyMessage:
          _CodecPair<AblyMessage>(_encodeAblyMessage, _decodeAblyMessage),
      CodecTypes.ablyEventMessage:
          _CodecPair<AblyEventMessage>(_encodeAblyEventMessage, null),

      // Other ably objects
      CodecTypes.clientOptions:
          _CodecPair<ClientOptions>(_encodeClientOptions, _decodeClientOptions),
      CodecTypes.tokenParams:
          _CodecPair<TokenParams>(_encodeTokenParams, _decodeTokenParams),
      CodecTypes.tokenDetails:
          _CodecPair<TokenDetails>(_encodeTokenDetails, _decodeTokenDetails),
      CodecTypes.tokenRequest:
          _CodecPair<TokenRequest>(_encodeTokenRequest, null),
      CodecTypes.paginatedResult:
          _CodecPair<PaginatedResult>(null, _decodePaginatedResult),
      CodecTypes.realtimeHistoryParams:
          _CodecPair<RealtimeHistoryParams>(_encodeRealtimeHistoryParams, null),
      CodecTypes.restHistoryParams:
          _CodecPair<RestHistoryParams>(_encodeRestHistoryParams, null),
      CodecTypes.restPresenceParams:
          _CodecPair<RestPresenceParams>(_encodeRestPresenceParams, null),

      CodecTypes.errorInfo: _CodecPair<ErrorInfo>(null, _decodeErrorInfo),
      CodecTypes.message:
          _CodecPair<Message>(_encodeChannelMessage, _decodeChannelMessage),
      CodecTypes.presenceMessage:
          _CodecPair<PresenceMessage>(null, _decodePresenceMessage),

      // Events - Connection
      CodecTypes.connectionStateChange:
          _CodecPair<ConnectionStateChange>(null, _decodeConnectionStateChange),

      // Events - Channel
      CodecTypes.channelStateChange:
          _CodecPair<ChannelStateChange>(null, _decodeChannelStateChange),
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
    } else if (value is RealtimeHistoryParams) {
      return CodecTypes.realtimeHistoryParams;
    } else if (value is RestHistoryParams) {
      return CodecTypes.restHistoryParams;
    } else if (value is RestPresenceParams) {
      return CodecTypes.restPresenceParams;
    } else if (value is ErrorInfo) {
      return CodecTypes.errorInfo;
    } else if (value is AblyMessage) {
      return CodecTypes.ablyMessage;
    } else if (value is AblyEventMessage) {
      return CodecTypes.ablyEventMessage;
    }
    // ignore: avoid_returning_null
    return null;
  }

  /// Encodes values from [_CodecPair._encoder] available in [_CodecPair]
  /// obtained from [codecMap] against codecType obtained from [value].
  /// If decoder is not found, [StandardMessageCodec] is used to read value
  @override
  void writeValue(final WriteBuffer buffer, final Object value) {
    final type = getCodecType(value);
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
    final pair = codecMap[type];
    if (pair == null) {
      return super.readValueOfType(type, buffer);
    } else {
      final map = toJsonMap(readValue(buffer) as Map);
      return pair.decode(map);
    }
  }

  // =========== ENCODERS ===========
  /// Writes [value] for [key] in [map] if [value] is not null
  void _writeToJson(Map<String, dynamic> map, String key, Object value) {
    assert(value is! DateTime, '`DateTime` objects cannot be encoded');
    if (value == null) return;
    map[key] = value;
  }

  /// Encodes [ClientOptions] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeClientOptions(final ClientOptions v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    // AuthOptions (super class of ClientOptions)
    _writeToJson(jsonMap, TxClientOptions.authUrl, v.authUrl);
    _writeToJson(jsonMap, TxClientOptions.authMethod, v.authMethod);
    _writeToJson(jsonMap, TxClientOptions.key, v.key);
    _writeToJson(jsonMap, TxClientOptions.tokenDetails,
      _encodeTokenDetails(v.tokenDetails));
    _writeToJson(jsonMap, TxClientOptions.authHeaders, v.authHeaders);
    _writeToJson(jsonMap, TxClientOptions.authParams, v.authParams);
    _writeToJson(jsonMap, TxClientOptions.queryTime, v.queryTime);
    _writeToJson(jsonMap, TxClientOptions.useTokenAuth, v.useTokenAuth);
    _writeToJson(
      jsonMap, TxClientOptions.hasAuthCallback, v.authCallback != null);

    // ClientOptions
    _writeToJson(jsonMap, TxClientOptions.clientId, v.clientId);
    _writeToJson(jsonMap, TxClientOptions.logLevel, v.logLevel);
    //TODO handle logHandler
    _writeToJson(jsonMap, TxClientOptions.tls, v.tls);
    _writeToJson(jsonMap, TxClientOptions.restHost, v.restHost);
    _writeToJson(jsonMap, TxClientOptions.realtimeHost, v.realtimeHost);
    _writeToJson(jsonMap, TxClientOptions.port, v.port);
    _writeToJson(jsonMap, TxClientOptions.tlsPort, v.tlsPort);
    _writeToJson(jsonMap, TxClientOptions.autoConnect, v.autoConnect);
    _writeToJson(
      jsonMap, TxClientOptions.useBinaryProtocol, v.useBinaryProtocol);
    _writeToJson(jsonMap, TxClientOptions.queueMessages, v.queueMessages);
    _writeToJson(jsonMap, TxClientOptions.echoMessages, v.echoMessages);
    _writeToJson(jsonMap, TxClientOptions.recover, v.recover);
    _writeToJson(jsonMap, TxClientOptions.environment, v.environment);
    _writeToJson(jsonMap, TxClientOptions.idempotentRestPublishing,
      v.idempotentRestPublishing);
    _writeToJson(jsonMap, TxClientOptions.httpOpenTimeout, v.httpOpenTimeout);
    _writeToJson(
      jsonMap, TxClientOptions.httpRequestTimeout, v.httpRequestTimeout);
    _writeToJson(
      jsonMap, TxClientOptions.httpMaxRetryCount, v.httpMaxRetryCount);
    _writeToJson(jsonMap, TxClientOptions.realtimeRequestTimeout,
      v.realtimeRequestTimeout);
    _writeToJson(jsonMap, TxClientOptions.fallbackHosts, v.fallbackHosts);
    _writeToJson(jsonMap, TxClientOptions.fallbackHostsUseDefault,
      v.fallbackHostsUseDefault);
    _writeToJson(
      jsonMap, TxClientOptions.fallbackRetryTimeout, v.fallbackRetryTimeout);
    _writeToJson(jsonMap, TxClientOptions.defaultTokenParams,
      _encodeTokenParams(v.defaultTokenParams));
    _writeToJson(
      jsonMap, TxClientOptions.channelRetryTimeout, v.channelRetryTimeout);
    _writeToJson(jsonMap, TxClientOptions.transportParams, v.transportParams);
    return jsonMap;
  }

  /// Encodes [TokenDetails] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeTokenDetails(final TokenDetails v) {
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
  Map<String, dynamic> _encodeTokenParams(final TokenParams v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxTokenParams.capability, v.capability);
    _writeToJson(jsonMap, TxTokenParams.clientId, v.clientId);
    _writeToJson(jsonMap, TxTokenParams.nonce, v.nonce);
    _writeToJson(jsonMap, TxTokenParams.timestamp, v.timestamp);
    _writeToJson(jsonMap, TxTokenParams.ttl, v.ttl);
    return jsonMap;
  }

  /// Encodes [TokenRequest] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeTokenRequest(final TokenRequest v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxTokenRequest.capability, v.capability);
    _writeToJson(jsonMap, TxTokenRequest.clientId, v.clientId);
    _writeToJson(jsonMap, TxTokenRequest.keyName, v.keyName);
    _writeToJson(jsonMap, TxTokenRequest.mac, v.mac);
    _writeToJson(jsonMap, TxTokenRequest.nonce, v.nonce);
    _writeToJson(
      jsonMap, TxTokenRequest.timestamp, v.timestamp?.millisecondsSinceEpoch);
    _writeToJson(jsonMap, TxTokenRequest.ttl, v.ttl);
    return jsonMap;
  }

  /// Encodes [RestHistoryParams] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeRestHistoryParams(final RestHistoryParams v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(
      jsonMap, TxRestHistoryParams.start, v.start?.millisecondsSinceEpoch);
    _writeToJson(
      jsonMap, TxRestHistoryParams.end, v.end?.millisecondsSinceEpoch);
    _writeToJson(jsonMap, TxRestHistoryParams.direction, v.direction);
    _writeToJson(jsonMap, TxRestHistoryParams.limit, v.limit);
    return jsonMap;
  }

  Map<String, dynamic> _encodeRestPresenceParams(final RestPresenceParams v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxRestPresenceParams.limit, v.limit);
    _writeToJson(jsonMap, TxRestPresenceParams.clientId, v.clientId);
    _writeToJson(jsonMap, TxRestPresenceParams.connectionId, v.connectionId);
    return jsonMap;
  }

  /// Encodes [RealtimeHistoryParams] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeRealtimeHistoryParams(
    final RealtimeHistoryParams v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxRealtimeHistoryParams.start,
      v.start?.millisecondsSinceEpoch);
    _writeToJson(
      jsonMap, TxRealtimeHistoryParams.end, v.end?.millisecondsSinceEpoch);
    _writeToJson(jsonMap, TxRealtimeHistoryParams.direction, v.direction);
    _writeToJson(jsonMap, TxRealtimeHistoryParams.limit, v.limit);
    _writeToJson(jsonMap, TxRealtimeHistoryParams.untilAttach, v.untilAttach);
    return jsonMap;
  }

  /// Encodes [AblyMessage] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeAblyMessage(final AblyMessage v) {
    if (v == null) return null;
    final codecType = getCodecType(v.message);
    final message = (v.message == null)
      ? null
      : (codecType == null)
      ? v.message
      : codecMap[codecType].encode(v.message);
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxAblyMessage.registrationHandle, v.handle);
    _writeToJson(jsonMap, TxAblyMessage.type, codecType);
    _writeToJson(jsonMap, TxAblyMessage.message, message);
    return jsonMap;
  }

  /// Encodes [AblyEventMessage] to a Map
  /// returns null of passed value [v] is null
  Map<String, dynamic> _encodeAblyEventMessage(final AblyEventMessage v) {
    if (v == null) return null;
    final codecType = getCodecType(v.message);
    final message = (v.message == null)
      ? null
      : (codecType == null)
      ? v.message
      : codecMap[codecType].encode(v.message);
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxAblyEventMessage.eventName, v.eventName);
    _writeToJson(jsonMap, TxAblyEventMessage.type, codecType);
    _writeToJson(jsonMap, TxAblyEventMessage.message, message);
    return jsonMap;
  }

  Map<String, dynamic> _encodeChannelMessage(final Message v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    // Note: connectionId and timestamp are automatically set by platform
    // So they are suppressed on dart side
    _writeToJson(jsonMap, TxMessage.name, v.name);
    _writeToJson(jsonMap, TxMessage.clientId, v.clientId);
    _writeToJson(jsonMap, TxMessage.data, v.data);
    _writeToJson(jsonMap, TxMessage.id, v.id);
    _writeToJson(jsonMap, TxMessage.encoding, v.encoding);
    _writeToJson(jsonMap, TxMessage.extras, v.extras);
    return jsonMap;
  }

  // =========== DECODERS ===========
  /// Reads [key] value from [jsonMap]
  /// Casts it to [T] if the value is not null
  T _readFromJson<T>(Map<String, dynamic> jsonMap, String key) {
    final value = jsonMap[key];
    if (value == null) return null;
    return value as T;
  }

  /// Decodes value [jsonMap] to [ClientOptions]
  /// returns null if [jsonMap] is null
  ClientOptions _decodeClientOptions(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;

    return ClientOptions()
    // AuthOptions (super class of ClientOptions)
      ..authUrl = _readFromJson<String>(
        jsonMap,
        TxClientOptions.authUrl,
      )
      ..authMethod = _readFromJson<String>(
        jsonMap,
        TxClientOptions.authMethod,
      )
      ..key = _readFromJson<String>(
        jsonMap,
        TxClientOptions.key,
      )
      ..tokenDetails = _decodeTokenDetails(
        toJsonMap(_readFromJson<Map>(
          jsonMap,
          TxClientOptions.tokenDetails,
        )),
      )
      ..authHeaders = _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.authHeaders,
      )
      ..authParams = _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.authParams,
      )
      ..queryTime = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.queryTime,
      )
      ..useTokenAuth = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.useTokenAuth,
      )

    // ClientOptions
      ..clientId = _readFromJson<String>(
        jsonMap,
        TxClientOptions.clientId,
      )
      ..logLevel = _readFromJson<int>(
        jsonMap,
        TxClientOptions.logLevel,
      )
    //TODO handle logHandler
      ..tls = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.tls,
      )
      ..restHost = _readFromJson<String>(
        jsonMap,
        TxClientOptions.restHost,
      )
      ..realtimeHost = _readFromJson<String>(
        jsonMap,
        TxClientOptions.realtimeHost,
      )
      ..port = _readFromJson<int>(
        jsonMap,
        TxClientOptions.port,
      )
      ..tlsPort = _readFromJson<int>(
        jsonMap,
        TxClientOptions.tlsPort,
      )
      ..autoConnect = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.autoConnect,
      )
      ..useBinaryProtocol = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.useBinaryProtocol,
      )
      ..queueMessages = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.queueMessages,
      )
      ..echoMessages = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.echoMessages,
      )
      ..recover = _readFromJson<String>(
        jsonMap,
        TxClientOptions.recover,
      )
      ..environment = _readFromJson<String>(
        jsonMap,
        TxClientOptions.environment,
      )
      ..idempotentRestPublishing = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.idempotentRestPublishing,
      )
      ..httpOpenTimeout = _readFromJson<int>(
        jsonMap,
        TxClientOptions.httpOpenTimeout,
      )
      ..httpRequestTimeout = _readFromJson<int>(
        jsonMap,
        TxClientOptions.httpRequestTimeout,
      )
      ..httpMaxRetryCount = _readFromJson<int>(
        jsonMap,
        TxClientOptions.httpMaxRetryCount,
      )
      ..realtimeRequestTimeout = _readFromJson<int>(
        jsonMap,
        TxClientOptions.realtimeRequestTimeout,
      )
      ..fallbackHosts = _readFromJson<List<String>>(
        jsonMap,
        TxClientOptions.fallbackHosts,
      )
      ..fallbackHostsUseDefault = _readFromJson<bool>(
        jsonMap,
        TxClientOptions.fallbackHostsUseDefault,
      )
      ..fallbackRetryTimeout = _readFromJson<int>(
        jsonMap,
        TxClientOptions.fallbackRetryTimeout,
      )
      ..defaultTokenParams = _decodeTokenParams(
        toJsonMap(_readFromJson<Map>(
          jsonMap,
          TxClientOptions.defaultTokenParams,
        )),
      )
      ..channelRetryTimeout = _readFromJson<int>(
        jsonMap,
        TxClientOptions.channelRetryTimeout,
      )
      ..transportParams = _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.transportParams,
      );
  }

  /// Decodes value [jsonMap] to [TokenDetails]
  /// returns null if [jsonMap] is null
  TokenDetails _decodeTokenDetails(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return TokenDetails(_readFromJson<String>(jsonMap, TxTokenDetails.token))
      ..expires = _readFromJson<int>(jsonMap, TxTokenDetails.expires)
      ..issued = _readFromJson<int>(jsonMap, TxTokenDetails.issued)
      ..capability = _readFromJson<String>(jsonMap, TxTokenDetails.capability)
      ..clientId = _readFromJson<String>(jsonMap, TxTokenDetails.clientId);
  }

  /// Decodes value [jsonMap] to [TokenParams]
  /// returns null if [jsonMap] is null
  TokenParams _decodeTokenParams(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return TokenParams()
      ..capability = _readFromJson<String>(jsonMap, TxTokenParams.capability)
      ..clientId = _readFromJson<String>(jsonMap, TxTokenParams.clientId)
      ..nonce = _readFromJson<String>(jsonMap, TxTokenParams.nonce)
      ..timestamp = DateTime.fromMillisecondsSinceEpoch(
        _readFromJson<int>(jsonMap, TxTokenParams.timestamp))
      ..ttl = _readFromJson<int>(jsonMap, TxTokenParams.ttl);
  }

  /// Decodes value [jsonMap] to [AblyMessage]
  /// returns null if [jsonMap] is null
  AblyMessage _decodeAblyMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final type = _readFromJson<int>(jsonMap, TxAblyMessage.type);
    dynamic message = jsonMap[TxAblyMessage.message];
    if (type != null) {
      message = codecMap[type].decode(
        toJsonMap(_readFromJson<Map>(jsonMap, TxAblyMessage.message)));
    }
    return AblyMessage(message,
      handle: jsonMap[TxAblyMessage.registrationHandle] as int, type: type);
  }

  /// Decodes value [jsonMap] to [ErrorInfo]
  /// returns null if [jsonMap] is null
  ErrorInfo _decodeErrorInfo(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    return ErrorInfo(
      code: jsonMap[TxErrorInfo.code] as int,
      message: jsonMap[TxErrorInfo.message] as String,
      statusCode: jsonMap[TxErrorInfo.statusCode] as int,
      href: jsonMap[TxErrorInfo.href] as String,
      requestId: jsonMap[TxErrorInfo.requestId] as String,
      cause: jsonMap[TxErrorInfo.cause] as ErrorInfo);
  }

  /// Decodes [eventName] to [ConnectionEvent] enum if not null
  // ignore: missing_return
  ConnectionEvent _decodeConnectionEvent(String eventName) {
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
  // ignore: missing_return
  ConnectionState _decodeConnectionState(String state) {
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
  // ignore: missing_return
  ChannelEvent _decodeChannelEvent(String eventName) {
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
  // ignore: missing_return
  ChannelState _decodeChannelState(String state) {
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
  ConnectionStateChange _decodeConnectionStateChange(
    Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final current = _decodeConnectionState(
      _readFromJson<String>(jsonMap, TxConnectionStateChange.current));
    final previous = _decodeConnectionState(
      _readFromJson<String>(jsonMap, TxConnectionStateChange.previous));
    final event = _decodeConnectionEvent(
      _readFromJson<String>(jsonMap, TxConnectionStateChange.event));
    final retryIn =
    _readFromJson<int>(jsonMap, TxConnectionStateChange.retryIn);
    final reason = _decodeErrorInfo(
      toJsonMap(_readFromJson<Map>(jsonMap, TxConnectionStateChange.reason)));
    return ConnectionStateChange(current, previous, event,
      retryIn: retryIn, reason: reason);
  }

  /// Decodes value [jsonMap] to [ChannelStateChange]
  /// returns null if [jsonMap] is null
  ChannelStateChange _decodeChannelStateChange(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final current = _decodeChannelState(
      _readFromJson<String>(jsonMap, TxChannelStateChange.current));
    final previous = _decodeChannelState(
      _readFromJson<String>(jsonMap, TxChannelStateChange.previous));
    final event = _decodeChannelEvent(
      _readFromJson<String>(jsonMap, TxChannelStateChange.event));
    final resumed = _readFromJson<bool>(jsonMap, TxChannelStateChange.resumed);
    final reason = _decodeErrorInfo(
      toJsonMap(_readFromJson<Map>(jsonMap, TxChannelStateChange.reason)));
    return ChannelStateChange(current, previous, event,
      resumed: resumed, reason: reason);
  }

  Message _decodeChannelMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final message = Message(
      name: _readFromJson<String>(jsonMap, TxMessage.name),
      clientId: _readFromJson<String>(jsonMap, TxMessage.clientId),
      data: _readFromJson<dynamic>(jsonMap, TxMessage.data))
      ..id = _readFromJson<String>(jsonMap, TxMessage.id)
      ..connectionId = _readFromJson<String>(jsonMap, TxMessage.connectionId)
      ..encoding = _readFromJson<String>(jsonMap, TxMessage.encoding)
      ..extras = _readFromJson<Map>(jsonMap, TxMessage.extras);
    final timestamp = _readFromJson<int>(jsonMap, TxMessage.timestamp);
    if (timestamp != null) {
      message.timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return message;
  }

  PresenceAction _decodePresenceAction(int index) =>
      (index == null) ? null : PresenceAction.values[index];

  PresenceMessage _decodePresenceMessage(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final timestamp = _readFromJson<int>(jsonMap, TxPresenceMessage.timestamp);
    return PresenceMessage(
      id: _readFromJson<String>(jsonMap, TxPresenceMessage.id),
      action: _decodePresenceAction(_readFromJson(
        jsonMap,
        TxPresenceMessage.action,
      )),
      clientId: _readFromJson<String>(jsonMap, TxPresenceMessage.clientId),
      data: _readFromJson<dynamic>(jsonMap, TxPresenceMessage.data),
      connectionId:
      _readFromJson<String>(jsonMap, TxPresenceMessage.connectionId),
      encoding: _readFromJson<String>(jsonMap, TxPresenceMessage.encoding),
      extras: toJsonMap(_readFromJson<Map>(jsonMap, TxPresenceMessage.extras)),
      timestamp: (timestamp == null)
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  PaginatedResult<Object> _decodePaginatedResult(Map<String, dynamic> jsonMap) {
    if (jsonMap == null) return null;
    final type = _readFromJson<int>(jsonMap, TxPaginatedResult.type);
    final items = _readFromJson<List>(jsonMap, TxPaginatedResult.items)
      ?.map((e) => codecMap[type].decode(toJsonMap(e as Map)))
      ?.toList() ??
      [];
    return PaginatedResult(items,
      hasNext: _readFromJson(jsonMap, TxPaginatedResult.hasNext) as bool);
  }
}
