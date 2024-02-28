import 'dart:io' as io show Platform;
import 'dart:typed_data';
import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// @nodoc
/// a [_Encoder] encodes custom type and converts it to a Map which will
/// be passed on to platform side
typedef _Encoder<T> = Map<String, dynamic>? Function(T value);

/// @nodoc
/// a [_Decoder] decodes Map received from platform side and converts to
/// to respective dart types
typedef _Decoder<T> = T Function(Map<String, dynamic> jsonMap);

/// @nodoc
/// A class to manage encoding/decoding by provided encoder/decoder functions.
class _CodecPair<T> {
  final _Encoder<T>? _encoder;
  final _Decoder<T>? _decoder;

  _CodecPair(this._encoder, this._decoder);

  /// @nodoc
  /// Convert properties from an ably library object instance (dart) to Map.
  /// if passed [value] is null, encoder will not be called.
  /// This method will throw an [AblyException] if encoder is null.
  Map<String, dynamic>? encode(final Object? value) {
    if (_encoder == null) {
      throw AblyException(
        message: 'Codec encoder is null',
      );
    }
    if (value == null) return null;
    return _encoder!(value as T);
  }

  /// @nodoc
  /// Convert Map entries to an ably library object instance (dart).
  /// if passed [jsonMap] is null, decoder will not be called.
  /// This method will throw an [AblyException] if decoder is null.
  T? decode(Map<String, dynamic>? jsonMap) {
    if (_decoder == null) {
      throw AblyException(
        message: 'Codec decoder is null',
      );
    }
    if (jsonMap == null) return null;
    return _decoder!(jsonMap);
  }
}

/// @nodoc
/// Custom message codec for encoding objects to send to platform
/// or decoding objects received from platform.
class Codec extends StandardMessageCodec {
  /// @nodoc
  /// Map of codec type (a value from [CodecTypes]) vs encoder/decoder pair.
  /// Encoder/decoder can be null.
  /// For example, [ErrorInfo] only needs a decoder but not an encoder.
  late Map<int, _CodecPair<dynamic>> codecMap;

  /// @nodoc
  /// initializes codec with codec map linking codec type to codec pair
  Codec() : super() {
    codecMap = {
      // Ably flutter plugin protocol message
      CodecTypes.ablyMessage: _CodecPair<AblyMessage<dynamic>>(
          _encodeAblyMessage, _decodeAblyMessage),
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
          _CodecPair<TokenRequest>(_encodeTokenRequest, _decodeTokenRequest),
      CodecTypes.restChannelOptions:
          _CodecPair<RestChannelOptions>(_encodeRestChannelOptions, null),
      CodecTypes.realtimeChannelOptions: _CodecPair<RealtimeChannelOptions>(
        _encodeRealtimeChannelOptions,
        null,
      ),
      CodecTypes.authOptions: _CodecPair<AuthOptions>(_encodeAuthOptions, null),
      CodecTypes.paginatedResult:
          _CodecPair<PaginatedResult<dynamic>>(null, _decodePaginatedResult),
      CodecTypes.realtimeHistoryParams:
          _CodecPair<RealtimeHistoryParams>(_encodeRealtimeHistoryParams, null),
      CodecTypes.restHistoryParams:
          _CodecPair<RestHistoryParams>(_encodeRestHistoryParams, null),
      CodecTypes.restPresenceParams:
          _CodecPair<RestPresenceParams>(_encodeRestPresenceParams, null),
      CodecTypes.realtimePresenceParams: _CodecPair<RealtimePresenceParams>(
        _encodeRealtimePresenceParams,
        null,
      ),

      // Push Notifications
      CodecTypes.deviceDetails:
          _CodecPair<DeviceDetails>(null, _decodeDeviceDetails),
      CodecTypes.localDevice: _CodecPair<LocalDevice>(null, _decodeLocalDevice),
      CodecTypes.pushChannelSubscription: _CodecPair<PushChannelSubscription>(
          null, _decodePushChannelSubscription),
      CodecTypes.unNotificationSettings: _CodecPair<UNNotificationSettings>(
          null, _decodeUNNotificationSettings),
      CodecTypes.remoteMessage:
          _CodecPair<RemoteMessage>(null, _decodeRemoteMessage),

      CodecTypes.errorInfo:
          _CodecPair<ErrorInfo>(_encodeErrorInfo, _decodeErrorInfo),
      CodecTypes.messageData: _CodecPair<MessageData<dynamic>?>(
        _encodeChannelMessageData,
        _decodeChannelMessageData,
      ),
      CodecTypes.messageExtras: _CodecPair<MessageExtras?>(
        _encodeChannelMessageExtras,
        _decodeChannelMessageExtras,
      ),
      CodecTypes.message:
          _CodecPair<Message>(_encodeChannelMessage, _decodeChannelMessage),
      CodecTypes.presenceMessage:
          _CodecPair<PresenceMessage>(null, _decodePresenceMessage),

      // Events - Connection
      CodecTypes.connectionStateChange:
          _CodecPair<EnrichedConnectionStateChange>(
              null, _decodeConnectionStateChange),

      // Events - Channel
      CodecTypes.channelStateChange:
          _CodecPair<ChannelStateChange>(null, _decodeChannelStateChange),

      // Encryption
      CodecTypes.cipherParams:
          _CodecPair<CipherParams>(_encodeCipherParams, _decodeCipherParams),
    };
  }

  /// @nodoc
  /// Converts a Map with dynamic keys and values to
  /// a Map with String keys and dynamic values.
  /// Returns null of [value] is null.
  Map<String, dynamic>? toJsonMap(Map<dynamic, dynamic>? value) {
    if (value == null) return null;
    return Map.castFrom<dynamic, dynamic, String, dynamic>(value);
  }

  /// @nodoc
  /// Converts a Map with dynamic keys and values to
  /// a Map with String keys and dynamic values.
  /// Returns null of [value] is null.
  Map<String, T> toTypedJsonMap<T>(Map<dynamic, dynamic>? value) {
    if (value == null) return <String, T>{};
    return Map.castFrom<dynamic, dynamic, String, T>(value);
  }

  /// @nodoc
  /// Returns a value from [CodecTypes] based of the [Type] of [value]
  int? getCodecType(final Object? value) {
    if (value is ClientOptions) {
      return CodecTypes.clientOptions;
    } else if (value is TokenDetails) {
      return CodecTypes.tokenDetails;
    } else if (value is TokenParams) {
      return CodecTypes.tokenParams;
    } else if (value is TokenRequest) {
      return CodecTypes.tokenRequest;
    } else if (value is MessageData) {
      return CodecTypes.messageData;
    } else if (value is RealtimeChannelOptions) {
      return CodecTypes.realtimeChannelOptions;
    } else if (value is RestChannelOptions) {
      return CodecTypes.restChannelOptions;
    } else if (value is MessageExtras) {
      return CodecTypes.messageExtras;
    } else if (value is Message) {
      return CodecTypes.message;
    } else if (value is RealtimeHistoryParams) {
      return CodecTypes.realtimeHistoryParams;
    } else if (value is RestHistoryParams) {
      return CodecTypes.restHistoryParams;
    } else if (value is RestPresenceParams) {
      return CodecTypes.restPresenceParams;
    } else if (value is RealtimePresenceParams) {
      return CodecTypes.realtimePresenceParams;
    } else if (value is ErrorInfo) {
      return CodecTypes.errorInfo;
    } else if (value is AblyMessage) {
      return CodecTypes.ablyMessage;
    } else if (value is AblyEventMessage) {
      return CodecTypes.ablyEventMessage;
    } else if (value is AuthOptions) {
      return CodecTypes.authOptions;
    }
    // ignore: avoid_returning_null
    return null;
  }

  /// @nodoc
  /// Encodes values from [_CodecPair._encoder] available in [_CodecPair]
  /// obtained from [codecMap] against codecType obtained from [value].
  /// If decoder is not found, [StandardMessageCodec] is used to read value
  @override
  void writeValue(final WriteBuffer buffer, final Object? value) {
    final type = getCodecType(value);
    if (type == null) {
      super.writeValue(buffer, value);
    } else {
      buffer.putUint8(type);
      writeValue(buffer, codecMap[type]!.encode(value));
    }
  }

  /// @nodoc
  /// Decodes values from [_CodecPair._decoder] available in codec pair,
  /// obtained from [codecMap] against [type].
  /// If decoder is not found, [StandardMessageCodec] is used to read value
  @override
  dynamic readValueOfType(int type, ReadBuffer buffer) {
    final pair = codecMap[type];
    if (pair == null) {
      return super.readValueOfType(type, buffer);
    } else {
      final map = toJsonMap(readValue(buffer) as Map?);
      return pair.decode(map);
    }
  }

  // =========== ENCODERS ===========
  /// @nodoc
  /// Writes [value] for [key] in [map] if [value] is not null
  void _writeToJson(Map<String, dynamic> map, String key, Object? value) {
    assert(value is! DateTime, '`DateTime` objects cannot be encoded');
    if (value == null) return;
    map[key] = value;
  }

  /// @nodoc
  /// Encodes [ClientOptions] to a Map
  /// returns null of [v] is null
  Map<String, dynamic> _encodeClientOptions(final ClientOptions v) {
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
    jsonMap[TxClientOptions.hasAuthCallback] = v.authCallback != null;

    // ClientOptions
    _writeToJson(jsonMap, TxClientOptions.clientId, v.clientId);
    _writeToJson(
        jsonMap, TxClientOptions.logLevel, _encodeLogLevel(v.logLevel));
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
    _writeToJson(
        jsonMap,
        TxClientOptions.fallbackHostsUseDefault,
        // ignore: deprecated_member_use_from_same_package
        v.fallbackHostsUseDefault);
    _writeToJson(
        jsonMap, TxClientOptions.fallbackRetryTimeout, v.fallbackRetryTimeout);
    _writeToJson(jsonMap, TxClientOptions.defaultTokenParams,
        _encodeTokenParams(v.defaultTokenParams));
    _writeToJson(
        jsonMap, TxClientOptions.channelRetryTimeout, v.channelRetryTimeout);
    _writeToJson(jsonMap, TxClientOptions.transportParams, v.transportParams);
    _writeToJson(jsonMap, TxClientOptions.dartVersion, dartVersion());
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [TokenDetails] to a Map
  /// returns null if [v] is null
  Map<String, dynamic>? _encodeTokenDetails(final TokenDetails? v) {
    if (v == null) return null;
    return {
      TxTokenDetails.token: v.token,
      TxTokenDetails.expires: v.expires,
      TxTokenDetails.issued: v.issued,
      TxTokenDetails.capability: v.capability,
      TxTokenDetails.clientId: v.clientId,
    };
  }

  /// @nodoc
  /// Encodes [TokenParams] to a Map
  /// returns null if [v] is null
  Map<String, dynamic>? _encodeTokenParams(final TokenParams? v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxTokenParams.capability, v.capability);
    _writeToJson(jsonMap, TxTokenParams.clientId, v.clientId);
    _writeToJson(jsonMap, TxTokenParams.nonce, v.nonce);
    _writeToJson(jsonMap, TxTokenParams.timestamp, v.timestamp);
    _writeToJson(jsonMap, TxTokenParams.ttl, v.ttl);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [TokenRequest] to a Map
  /// returns null if [v] is null
  Map<String, dynamic> _encodeTokenRequest(final TokenRequest v) {
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

  /// @nodoc
  /// Encodes [RestChannelOptions] to a Map
  /// returns null if [v] is null
  Map<String, dynamic> _encodeRestChannelOptions(final RestChannelOptions v) {
    final jsonMap = <String, dynamic>{};
    jsonMap[TxRestChannelOptions.cipherParams] =
        _encodeCipherParams(v.cipherParams);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [ChannelMode] to a string constant
  String _encodeChannelMode(ChannelMode mode) {
    switch (mode) {
      case ChannelMode.presence:
        return TxEnumConstants.presence;
      case ChannelMode.publish:
        return TxEnumConstants.publish;
      case ChannelMode.subscribe:
        return TxEnumConstants.subscribe;
      case ChannelMode.presenceSubscribe:
        return TxEnumConstants.presenceSubscribe;
    }
  }

  /// @nodoc
  /// Encodes [RealtimeChannelOptions] to a Map
  /// returns null if [v] is null
  Map<String, dynamic> _encodeRealtimeChannelOptions(
      final RealtimeChannelOptions v) {
    final jsonMap = <String, dynamic>{};
    jsonMap[TxRealtimeChannelOptions.cipherParams] =
        _encodeCipherParams(v.cipherParams);
    _writeToJson(jsonMap, TxRealtimeChannelOptions.params, v.params);
    _writeToJson(
      jsonMap,
      TxRealtimeChannelOptions.modes,
      v.modes?.map(_encodeChannelMode).toList(),
    );
    return jsonMap;
  }

  Map<String, dynamic> _encodeAuthOptions(final AuthOptions authOptions) {
    final jsonMap = <String, dynamic>{};
    jsonMap[TxAuthOptions.tokenDetails] =
        _encodeTokenDetails(authOptions.tokenDetails);
    jsonMap[TxAuthOptions.authUrl] = authOptions.authUrl;
    jsonMap[TxAuthOptions.authMethod] = authOptions.authMethod;
    jsonMap[TxAuthOptions.key] = authOptions.key;
    //For authOptions.authCallback happens check method_call_handler.dart
    jsonMap[TxAuthOptions.token] = authOptions.tokenDetails?.token;
    jsonMap[TxAuthOptions.authHeaders] = authOptions.authHeaders;
    jsonMap[TxAuthOptions.authParams] = authOptions.authParams;
    jsonMap[TxAuthOptions.queryTime] = authOptions.queryTime;
    jsonMap[TxAuthOptions.useTokenAuth] = authOptions.useTokenAuth;

    return jsonMap;
  }

  Map<String, dynamic>? _encodeCipherParams(final CipherParams? params) {
    if (params == null) {
      return null;
    }
    final jsonMap = <String, dynamic>{};
    final paramsNative = CipherParamsInternal.fromCipherParams(params);
    jsonMap[TxCipherParams.androidHandle] = paramsNative.androidHandle;
    jsonMap[TxCipherParams.iosKey] = paramsNative.key;
    jsonMap[TxCipherParams.iosAlgorithm] = paramsNative.algorithm;

    return jsonMap;
  }

  CipherParams _decodeCipherParams(final Map<String, dynamic> jsonMap) {
    if (io.Platform.isAndroid) {
      final cipherParamsHandle = jsonMap[TxCipherParams.androidHandle] as int;
      return CipherParamsInternal.forAndroid(
        androidHandle: cipherParamsHandle,
      );
    } else if (io.Platform.isIOS) {
      final algorithm = jsonMap[TxCipherParams.iosAlgorithm] as String;
      final key = jsonMap[TxCipherParams.iosKey] as Uint8List;
      return CipherParamsInternal.forIOS(
        algorithm: algorithm,
        key: key,
      );
    } else {
      throw AblyException(
        message: 'Unsupported platform',
      );
    }
  }

  /// @nodoc
  /// Encodes [RestHistoryParams] to a Map
  /// returns null if [v] is null
  Map<String, dynamic> _encodeRestHistoryParams(final RestHistoryParams v) {
    final jsonMap = <String, dynamic>{};
    _writeToJson(
        jsonMap, TxRestHistoryParams.start, v.start.millisecondsSinceEpoch);
    _writeToJson(
        jsonMap, TxRestHistoryParams.end, v.end.millisecondsSinceEpoch);
    _writeToJson(jsonMap, TxRestHistoryParams.direction, v.direction);
    _writeToJson(jsonMap, TxRestHistoryParams.limit, v.limit);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [RestPresenceParams] to a Map
  /// returns null if [v] is null
  Map<String, dynamic> _encodeRestPresenceParams(final RestPresenceParams v) {
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxRestPresenceParams.limit, v.limit);
    _writeToJson(jsonMap, TxRestPresenceParams.clientId, v.clientId);
    _writeToJson(jsonMap, TxRestPresenceParams.connectionId, v.connectionId);
    return jsonMap;
  }

  Map<String, dynamic> _encodeRealtimePresenceParams(
      final RealtimePresenceParams v) {
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxRealtimePresenceParams.waitForSync, v.waitForSync);
    _writeToJson(jsonMap, TxRealtimePresenceParams.clientId, v.clientId);
    _writeToJson(
        jsonMap, TxRealtimePresenceParams.connectionId, v.connectionId);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [RealtimeHistoryParams] to a Map
  /// returns null of [v] is null
  Map<String, dynamic> _encodeRealtimeHistoryParams(
    final RealtimeHistoryParams v,
  ) {
    final jsonMap = <String, dynamic>{};
    _writeToJson(
      jsonMap,
      TxRealtimeHistoryParams.start,
      v.start.millisecondsSinceEpoch,
    );
    _writeToJson(
      jsonMap,
      TxRealtimeHistoryParams.end,
      v.end.millisecondsSinceEpoch,
    );
    _writeToJson(jsonMap, TxRealtimeHistoryParams.direction, v.direction);
    _writeToJson(jsonMap, TxRealtimeHistoryParams.limit, v.limit);
    _writeToJson(jsonMap, TxRealtimeHistoryParams.untilAttach, v.untilAttach);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [AblyMessage] to a Map
  /// returns null of [v] is null
  Map<String, dynamic> _encodeAblyMessage(final AblyMessage<dynamic> v) {
    final codecType = getCodecType(v.message);
    final message = (codecType == null)
        ? v.message
        : codecMap[codecType]!.encode(v.message);
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxAblyMessage.registrationHandle, v.handle);
    _writeToJson(jsonMap, TxAblyMessage.type, codecType);
    _writeToJson(jsonMap, TxAblyMessage.message, message);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [AblyEventMessage] to a Map
  /// returns null of [v] is null
  Map<String, dynamic> _encodeAblyEventMessage(final AblyEventMessage v) {
    final codecType = getCodecType(v.message);
    final message = (v.message == null)
        ? null
        : (codecType == null)
            ? v.message
            : codecMap[codecType]!.encode(v.message);
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxAblyEventMessage.eventName, v.eventName);
    _writeToJson(jsonMap, TxAblyEventMessage.type, codecType);
    _writeToJson(jsonMap, TxAblyEventMessage.message, message);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [ErrorInfo] to a Map
  /// returns null of [v] is null
  Map<String, dynamic>? _encodeErrorInfo(final ErrorInfo? v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxErrorInfo.code, v.code);
    _writeToJson(jsonMap, TxErrorInfo.message, v.message);
    _writeToJson(jsonMap, TxErrorInfo.statusCode, v.statusCode);
    _writeToJson(jsonMap, TxErrorInfo.href, v.href);
    _writeToJson(jsonMap, TxErrorInfo.requestId, v.requestId);
    _writeToJson(jsonMap, TxErrorInfo.cause, v.cause);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [MessageData] to a Map
  /// returns null of [v] is null
  Map<String, dynamic>? _encodeChannelMessageData(
    final MessageData<dynamic>? v,
  ) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    _writeToJson(jsonMap, TxMessageData.data, v.data);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [MessageExtras] to a Map
  /// returns null of [v] is null
  Map<String, dynamic>? _encodeChannelMessageExtras(final MessageExtras? v) {
    if (v == null) return null;
    final jsonMap = <String, dynamic>{};
    // Not encoding `delta`, as it is a readonly extension
    _writeToJson(jsonMap, TxMessageExtras.extras, v.map);
    return jsonMap;
  }

  /// @nodoc
  /// Encodes [Message] to a Map
  /// returns null of [v] is null
  Map<String, dynamic> _encodeChannelMessage(final Message v) {
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
  /// @nodoc
  /// Casts it to [T] if the value is not null
  T? _readFromJson<T>(Map<String, dynamic> jsonMap, String key) {
    final value = jsonMap[key];
    if (value == null) return null;
    return value as T;
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [ClientOptions]
  /// returns null if [jsonMap] is null
  ClientOptions _decodeClientOptions(Map<String, dynamic> jsonMap) {
    final tokenDetails = toJsonMap(_readFromJson<Map<dynamic, dynamic>>(
      jsonMap,
      TxClientOptions.tokenDetails,
    ));
    final tokenParams = toJsonMap(_readFromJson<Map<dynamic, dynamic>>(
      jsonMap,
      TxClientOptions.defaultTokenParams,
    ));
    final clientOptions = ClientOptions(
      // AuthOptions (super class of ClientOptions)
      authUrl: _readFromJson<String>(
        jsonMap,
        TxClientOptions.authUrl,
      ),
      authMethod: _readFromJson<String>(
        jsonMap,
        TxClientOptions.authMethod,
      ),
      key: _readFromJson<String>(
        jsonMap,
        TxClientOptions.key,
      ),
      tokenDetails:
          (tokenDetails == null) ? null : _decodeTokenDetails(tokenDetails),
      authHeaders: _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.authHeaders,
      ),
      authParams: _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.authParams,
      ),
      queryTime: _readFromJson<bool>(
        jsonMap,
        TxClientOptions.queryTime,
      ),
      useTokenAuth: _readFromJson<bool>(
        jsonMap,
        TxClientOptions.useTokenAuth,
      ),

      // ClientOptions
      clientId: _readFromJson<String>(
        jsonMap,
        TxClientOptions.clientId,
      ),
      logLevel: _decodeLogLevel(jsonMap[TxClientOptions.logLevel] as String?),
      //TODO handle logHandler
      tls: jsonMap[TxClientOptions.tls] as bool,
      restHost: _readFromJson<String>(
        jsonMap,
        TxClientOptions.restHost,
      ),
      realtimeHost: _readFromJson<String>(
        jsonMap,
        TxClientOptions.realtimeHost,
      ),
      port: _readFromJson<int>(
        jsonMap,
        TxClientOptions.port,
      ),
      tlsPort: _readFromJson<int>(
        jsonMap,
        TxClientOptions.tlsPort,
      ),
      autoConnect: jsonMap[TxClientOptions.autoConnect] as bool,
      useBinaryProtocol: jsonMap[TxClientOptions.useBinaryProtocol] as bool,
      queueMessages: jsonMap[TxClientOptions.queueMessages] as bool,
      echoMessages: jsonMap[TxClientOptions.echoMessages] as bool,
      recover: _readFromJson<String>(
        jsonMap,
        TxClientOptions.recover,
      ),
      environment: _readFromJson<String>(
        jsonMap,
        TxClientOptions.environment,
      ),
      idempotentRestPublishing: _readFromJson<bool>(
        jsonMap,
        TxClientOptions.idempotentRestPublishing,
      ),
      realtimeRequestTimeout:
          jsonMap[TxClientOptions.realtimeRequestTimeout] as int?,
      httpOpenTimeout: jsonMap[TxClientOptions.httpOpenTimeout] as int,
      httpRequestTimeout: jsonMap[TxClientOptions.httpRequestTimeout] as int,
      httpMaxRetryCount: jsonMap[TxClientOptions.httpMaxRetryCount] as int,
      fallbackHosts: _readFromJson<List<String>>(
        jsonMap,
        TxClientOptions.fallbackHosts,
      ),
      fallbackHostsUseDefault: _readFromJson<bool>(
        jsonMap,
        TxClientOptions.fallbackHostsUseDefault,
      ),
      fallbackRetryTimeout:
          jsonMap[TxClientOptions.fallbackRetryTimeout] as int,
      defaultTokenParams:
          (tokenParams == null) ? null : _decodeTokenParams(tokenParams),
      channelRetryTimeout: jsonMap[TxClientOptions.channelRetryTimeout] as int,
      transportParams: _readFromJson<Map<String, String>>(
        jsonMap,
        TxClientOptions.transportParams,
      ),
    );
    return clientOptions;
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [TokenDetails]
  /// returns null if [jsonMap] is null
  TokenDetails _decodeTokenDetails(Map<String, dynamic> jsonMap) =>
      TokenDetails(
        _readFromJson<String>(jsonMap, TxTokenDetails.token),
        expires: _readFromJson<int>(jsonMap, TxTokenDetails.expires),
        issued: _readFromJson<int>(jsonMap, TxTokenDetails.issued),
        capability: _readFromJson<String>(jsonMap, TxTokenDetails.capability),
        clientId: _readFromJson<String>(jsonMap, TxTokenDetails.clientId),
      );

  /// @nodoc
  /// Decodes value [jsonMap] to [TokenRequest]
  /// returns null if [jsonMap] is null
  TokenRequest _decodeTokenRequest(Map<String, dynamic> jsonMap) {
    final timestamp = _readFromJson<int>(jsonMap, TxTokenRequest.timestamp);
    return TokenRequest(
      capability: _readFromJson<String>(jsonMap, TxTokenRequest.capability),
      clientId: _readFromJson<String>(jsonMap, TxTokenRequest.clientId),
      keyName: _readFromJson<String>(jsonMap, TxTokenRequest.keyName),
      mac: _readFromJson<String>(jsonMap, TxTokenRequest.mac),
      nonce: _readFromJson<String>(jsonMap, TxTokenRequest.nonce),
      timestamp: (timestamp != null)
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null,
      ttl: _readFromJson<int>(jsonMap, TxTokenRequest.ttl),
    );
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [TokenParams]
  /// returns null if [jsonMap] is null
  TokenParams _decodeTokenParams(Map<String, dynamic> jsonMap) {
    final timestamp = _readFromJson<int>(jsonMap, TxTokenParams.timestamp);
    final params = TokenParams(
      capability: _readFromJson<String>(jsonMap, TxTokenParams.capability),
      clientId: _readFromJson<String>(jsonMap, TxTokenParams.clientId),
      nonce: _readFromJson<String>(jsonMap, TxTokenParams.nonce),
      timestamp: (timestamp != null)
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null,
      ttl: _readFromJson<int>(jsonMap, TxTokenParams.ttl),
    );
    return params;
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [AblyMessage]
  /// returns null if [jsonMap] is null
  AblyMessage<dynamic> _decodeAblyMessage(Map<String, dynamic> jsonMap) {
    final type = _readFromJson<int>(jsonMap, TxAblyMessage.type);
    var message = jsonMap[TxAblyMessage.message] as Object;
    if (type != null) {
      message = codecMap[type]!.decode(
        toJsonMap(_readFromJson<Map<dynamic, dynamic>>(
          jsonMap,
          TxAblyMessage.message,
        )),
      ) as Object;
    }
    return AblyMessage(
      message: message,
      handle: jsonMap[TxAblyMessage.registrationHandle] as int?,
      type: type,
    );
  }

  DeviceDetails _decodeDeviceDetails(Map<String, dynamic> jsonMap) {
    final formFactor = _decodeFormFactor(
        _readFromJson<String>(jsonMap, TxDeviceDetails.formFactor));

    return DeviceDetails(
      id: jsonMap[TxDeviceDetails.id] as String?,
      clientId: jsonMap[TxDeviceDetails.clientId] as String?,
      platform:
          _decodeDevicePlatform(jsonMap[TxDeviceDetails.platform] as String),
      formFactor: formFactor,
      metadata: toTypedJsonMap<String>(
          jsonMap[TxDeviceDetails.metadata] as Map<Object?, Object?>?),
      push: _decodeDevicePushDetails(
        Map<String, dynamic>.from(jsonMap[TxDeviceDetails.devicePushDetails]
            as Map<Object?, Object?>),
      ),
    );
  }

  DevicePushDetails _decodeDevicePushDetails(Map<String, dynamic> jsonMap) {
    final jsonMapErrorReason =
        jsonMap[TxDevicePushDetails.errorReason] as Map<Object?, Object?>?;

    final recipient =
        jsonMap[TxDevicePushDetails.recipient] as Map<Object?, Object?>?;

    return DevicePushDetails(
      recipient:
          (recipient != null) ? Map<String, Object>.from(recipient) : null,
      state:
          _decodeDevicePushState(jsonMap[TxDevicePushDetails.state] as String?),
      errorReason: (jsonMapErrorReason != null)
          ? _decodeErrorInfo(Map<String, dynamic>.from(jsonMapErrorReason))
          : null,
    );
  }

  LocalDevice _decodeLocalDevice(Map<String, dynamic> jsonMap) => LocalDevice(
        deviceDetails: _decodeDeviceDetails(jsonMap),
        deviceSecret: jsonMap[TxLocalDevice.deviceSecret] as String?,
        deviceIdentityToken:
            jsonMap[TxLocalDevice.deviceIdentityToken] as String?,
      );

  FormFactor _decodeFormFactor(String? enumValue) {
    switch (enumValue) {
      case TxFormFactorEnum.phone:
        return FormFactor.phone;
      case TxFormFactorEnum.tablet:
        return FormFactor.tablet;
      case TxFormFactorEnum.desktop:
        return FormFactor.desktop;
      case TxFormFactorEnum.tv:
        return FormFactor.tv;
      case TxFormFactorEnum.watch:
        return FormFactor.watch;
      case TxFormFactorEnum.car:
        return FormFactor.car;
      case TxFormFactorEnum.embedded:
        return FormFactor.embedded;
      case TxFormFactorEnum.other:
        return FormFactor.other;
    }
    throw AblyException(
      message:
          'Platform communication error. FormFactor is invalid: $enumValue',
    );
  }

  DevicePushState? _decodeDevicePushState(String? enumValue) {
    switch (enumValue) {
      case TxDevicePushStateEnum.active:
        return DevicePushState.active;
      case TxDevicePushStateEnum.failing:
        return DevicePushState.failing;
      case TxDevicePushStateEnum.failed:
        return DevicePushState.failed;
      default:
        return null;
    }
  }

  DevicePlatform _decodeDevicePlatform(String? enumValue) {
    switch (enumValue) {
      case TxDevicePlatformEnum.android:
        return DevicePlatform.android;
      case TxDevicePlatformEnum.ios:
        return DevicePlatform.ios;
      case TxDevicePlatformEnum.browser:
        return DevicePlatform.browser;
    }
    throw AblyException(
      message:
          'Platform communication error. DevicePlatform is invalid: $enumValue',
    );
  }

  PushChannelSubscription _decodePushChannelSubscription(
          Map<String, dynamic> jsonMap) =>
      PushChannelSubscription(
        channel: jsonMap[TxPushChannelSubscription.channel] as String,
        clientId: jsonMap[TxPushChannelSubscription.clientId] as String?,
        deviceId: jsonMap[TxPushChannelSubscription.deviceId] as String?,
      );

  UNNotificationSettings _decodeUNNotificationSettings(
          Map<String, dynamic> jsonMap) =>
      UNNotificationSettings(
        authorizationStatus: _decodeUNAuthorizationStatus(
            jsonMap[TxUNNotificationSettings.authorizationStatus] as String),
        soundSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.soundSetting] as String),
        badgeSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.badgeSetting] as String),
        alertSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.alertSetting] as String),
        notificationCenterSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.notificationCenterSetting]
                as String),
        lockScreenSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.lockScreenSetting] as String),
        carPlaySetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.carPlaySetting] as String),
        alertStyle: _decodeUNAlertStyle(
            jsonMap[TxUNNotificationSettings.alertStyle] as String),
        showPreviewsSetting: _decodeUNShowPreviewsSetting(
            jsonMap[TxUNNotificationSettings.showPreviewsSetting] as String),
        criticalAlertSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.criticalAlertSetting] as String),
        providesAppNotificationSettings:
            jsonMap[TxUNNotificationSettings.providesAppNotificationSettings]
                as bool,
        announcementSetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.announcementSetting] as String),
        scheduledDeliverySetting: _decodeUNNotificationSetting(
            jsonMap[TxUNNotificationSettings.scheduledDeliverySetting]
                as String),
      );

  UNShowPreviewsSetting _decodeUNShowPreviewsSetting(String setting) {
    switch (setting) {
      case TxUNShowPreviewsSettingEnum.always:
        return UNShowPreviewsSetting.always;
      case TxUNShowPreviewsSettingEnum.whenAuthenticated:
        return UNShowPreviewsSetting.whenAuthenticated;
      case TxUNShowPreviewsSettingEnum.never:
        return UNShowPreviewsSetting.never;
    }
    throw AblyException(
      message: 'Platform communication error. '
          'UNShowPreviewsSetting is invalid: $setting',
    );
  }

  UNAlertStyle _decodeUNAlertStyle(String style) {
    switch (style) {
      case TxUNAlertStyleEnum.alert:
        return UNAlertStyle.alert;
      case TxUNAlertStyleEnum.banner:
        return UNAlertStyle.banner;
      case TxUNAlertStyleEnum.none:
        return UNAlertStyle.none;
    }
    throw AblyException(
      message: 'Platform communication error. '
          'UNAlertStyle is invalid: $style',
    );
  }

  UNAuthorizationStatus _decodeUNAuthorizationStatus(String status) {
    switch (status) {
      case TxUNAuthorizationStatusEnum.notDetermined:
        return UNAuthorizationStatus.notDetermined;
      case TxUNAuthorizationStatusEnum.denied:
        return UNAuthorizationStatus.denied;
      case TxUNAuthorizationStatusEnum.authorized:
        return UNAuthorizationStatus.authorized;
      case TxUNAuthorizationStatusEnum.provisional:
        return UNAuthorizationStatus.provisional;
      case TxUNAuthorizationStatusEnum.ephemeral:
        return UNAuthorizationStatus.ephemeral;
    }
    throw AblyException(
      message: 'Platform communication error. '
          'UNAuthorizationStatus is invalid: $status',
    );
  }

  UNNotificationSetting _decodeUNNotificationSetting(String setting) {
    switch (setting) {
      case TxUNNotificationSettingEnum.disabled:
        return UNNotificationSetting.disabled;
      case TxUNNotificationSettingEnum.enabled:
        return UNNotificationSetting.enabled;
      case TxUNNotificationSettingEnum.notSupported:
        return UNNotificationSetting.notSupported;
    }
    throw AblyException(
      message: 'Platform communication error. '
          'UNNotificationSetting is invalid: $setting',
    );
  }

  RemoteMessage _decodeRemoteMessage(Map<String, dynamic> jsonMap) =>
      RemoteMessage.fromMap(jsonMap);

  /// @nodoc
  /// Decodes value [jsonMap] to [ErrorInfo]
  /// returns null if [jsonMap] is null
  ErrorInfo _decodeErrorInfo(Map<String, dynamic> jsonMap) => ErrorInfo(
        code: jsonMap[TxErrorInfo.code] as int?,
        message: jsonMap[TxErrorInfo.message] as String?,
        statusCode: jsonMap[TxErrorInfo.statusCode] as int?,
        href: jsonMap[TxErrorInfo.href] as String?,
        requestId: jsonMap[TxErrorInfo.requestId] as String?,
        cause: jsonMap[TxErrorInfo.cause] as ErrorInfo?,
      );

  /// @nodoc
  /// Decodes [eventName] to [ConnectionEvent] enum if not null
  ConnectionEvent _decodeConnectionEvent(String? eventName) {
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
    throw AblyException(
      message: 'Platform communication error. '
          'Connection event is invalid: $eventName',
    );
  }

  /// @nodoc
  /// Decodes [state] to [ConnectionState] enum if not null
  ConnectionState _decodeConnectionState(String? state) {
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
    throw AblyException(
      message:
          'Platform communication error. Connection state is invalid: $state',
    );
  }

  /// @nodoc
  /// Decodes [eventName] to [ChannelEvent] enum if not null
  ChannelEvent _decodeChannelEvent(String? eventName) {
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
    throw AblyException(
      message:
          'Platform communication error. Channel event is invalid: $eventName',
    );
  }

  /// @nodoc
  /// Decodes [state] to [ChannelState] enum if not null
  ChannelState _decodeChannelState(String? state) {
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
    throw AblyException(
      message: 'Platform communication error. Channel state is invalid: $state',
    );
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [ConnectionStateChange]
  /// returns null if [jsonMap] is null
  EnrichedConnectionStateChange _decodeConnectionStateChange(
    Map<String, dynamic> jsonMap,
  ) {
    final connectionId =
        _readFromJson<String>(jsonMap, TxConnectionStateChange.connectionId);
    final connectionKey =
        _readFromJson<String>(jsonMap, TxConnectionStateChange.connectionKey);

    final current = _decodeConnectionState(
        _readFromJson<String>(jsonMap, TxConnectionStateChange.current));
    final previous = _decodeConnectionState(
        _readFromJson<String>(jsonMap, TxConnectionStateChange.previous));
    final event = _decodeConnectionEvent(
        _readFromJson<String>(jsonMap, TxConnectionStateChange.event));
    final retryIn =
        _readFromJson<int>(jsonMap, TxConnectionStateChange.retryIn);
    final errorInfo = toJsonMap(_readFromJson<Map<dynamic, dynamic>>(
      jsonMap,
      TxConnectionStateChange.reason,
    ));
    final reason = (errorInfo == null) ? null : _decodeErrorInfo(errorInfo);
    return EnrichedConnectionStateChange(
      stateChange: ConnectionStateChange(
        current: current,
        previous: previous,
        event: event,
        retryIn: retryIn,
        reason: reason,
      ),
      connectionId: connectionId,
      connectionKey: connectionKey,
    );
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [ChannelStateChange]
  /// returns null if [jsonMap] is null
  ChannelStateChange _decodeChannelStateChange(Map<String, dynamic> jsonMap) {
    final current = _decodeChannelState(
        _readFromJson<String>(jsonMap, TxChannelStateChange.current));
    final previous = _decodeChannelState(
        _readFromJson<String>(jsonMap, TxChannelStateChange.previous));
    final event = _decodeChannelEvent(
        _readFromJson<String>(jsonMap, TxChannelStateChange.event));
    final resumed = _readFromJson<bool>(jsonMap, TxChannelStateChange.resumed)!;
    final errorInfo = toJsonMap(_readFromJson<Map<dynamic, dynamic>>(
      jsonMap,
      TxChannelStateChange.reason,
    ));
    final reason = (errorInfo == null) ? null : _decodeErrorInfo(errorInfo);
    return ChannelStateChange(
      current: current,
      previous: previous,
      event: event,
      resumed: resumed,
      reason: reason,
    );
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [MessageData]
  /// returns null if [jsonMap] is null
  MessageData<dynamic>? _decodeChannelMessageData(
    Map<String, dynamic> jsonMap,
  ) =>
      MessageData.fromValue(_readFromJson<Object>(jsonMap, TxMessageData.data));

  /// @nodoc
  /// Decodes value [jsonMap] to [MessageExtras]
  /// returns null if [jsonMap] is null
  MessageExtras? _decodeChannelMessageExtras(Map<String, dynamic> jsonMap) =>
      MessageExtras.fromMap(jsonMap);

  /// @nodoc
  /// Decodes value [jsonMap] to [Message]
  /// returns null if [jsonMap] is null
  Message _decodeChannelMessage(Map<String, dynamic> jsonMap) {
    final timestamp = _readFromJson<int>(jsonMap, TxMessage.timestamp);
    // here extras may be a Map or a MessageExtras instance as
    //  cocoa side doesn't have dedicated models to handle MessageExtras
    var extras = _readFromJson<Object>(jsonMap, TxMessage.extras);
    if (extras is! MessageExtras) {
      extras = MessageExtras.fromMap(toJsonMap(extras as Map?));
    }
    return Message(
      name: _readFromJson<String>(jsonMap, TxMessage.name),
      clientId: _readFromJson<String>(jsonMap, TxMessage.clientId),
      data: _readFromJson<dynamic>(jsonMap, TxMessage.data),
      id: _readFromJson<String>(jsonMap, TxMessage.id),
      connectionId: _readFromJson<String>(jsonMap, TxMessage.connectionId),
      encoding: _readFromJson<String>(jsonMap, TxMessage.encoding),
      extras: extras as MessageExtras?,
      timestamp: (timestamp == null)
          ? null
          : DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  /// @nodoc
  /// Decodes [action] to [PresenceAction] enum if not null
  PresenceAction? _decodePresenceAction(String? action) {
    switch (action) {
      case TxEnumConstants.present:
        return PresenceAction.present;
      case TxEnumConstants.absent:
        return PresenceAction.absent;
      case TxEnumConstants.enter:
        return PresenceAction.enter;
      case TxEnumConstants.leave:
        return PresenceAction.leave;
      case TxEnumConstants.update:
        return PresenceAction.update;
      default:
        return null;
    }
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [PresenceMessage]
  /// returns null if [jsonMap] is null
  PresenceMessage _decodePresenceMessage(Map<String, dynamic> jsonMap) {
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
      extras: _readFromJson<MessageExtras>(jsonMap, TxPresenceMessage.extras),
      timestamp: (timestamp == null)
          ? null
          : DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  /// @nodoc
  /// Decodes value [jsonMap] to [PaginatedResult]
  /// returns null if [jsonMap] is null
  PaginatedResult<Object> _decodePaginatedResult(Map<String, dynamic> jsonMap) {
    final type = _readFromJson<int>(jsonMap, TxPaginatedResult.type);
    final items = _readFromJson<List<dynamic>>(jsonMap, TxPaginatedResult.items)
            ?.map((e) => codecMap[type]?.decode(toJsonMap(e as Map)) as Object)
            .toList() ??
        [];
    final hasNext = _readFromJson<bool>(jsonMap, TxPaginatedResult.hasNext);
    if (hasNext == null) {
      throw AblyException(
        message:
            'Platform communication error. PaginatedResult.hasNext is null',
      );
    }
    return PaginatedResult(items, hasNext: hasNext);
  }

  String? _encodeLogLevel(final LogLevel? level) {
    if (level == null) return null;
    switch (level) {
      case LogLevel.none:
        return TxLogLevelEnum.none;
      case LogLevel.verbose:
        return TxLogLevelEnum.verbose;
      case LogLevel.debug:
        return TxLogLevelEnum.debug;
      case LogLevel.info:
        return TxLogLevelEnum.info;
      case LogLevel.warn:
        return TxLogLevelEnum.warn;
      case LogLevel.error:
        return TxLogLevelEnum.error;
    }
  }

  LogLevel _decodeLogLevel(String? logLevelString) {
    switch (logLevelString) {
      case TxLogLevelEnum.none:
        return LogLevel.none;
      case TxLogLevelEnum.verbose:
        return LogLevel.verbose;
      case TxLogLevelEnum.debug:
        return LogLevel.debug;
      case TxLogLevelEnum.info:
        return LogLevel.info;
      case TxLogLevelEnum.warn:
        return LogLevel.warn;
      case TxLogLevelEnum.error:
        return LogLevel.error;
    }
    throw AblyException(
      message: 'Error decoding LogLevel from platform string: $logLevelString',
    );
  }
}
