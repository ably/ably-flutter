package io.ably.flutter.plugin;

import androidx.annotation.Nullable;
import com.google.firebase.messaging.RemoteMessage;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.types.PlatformClientOptions;
import io.ably.flutter.plugin.util.CipherParamsStorage;
import io.ably.flutter.plugin.util.Consumer;
import io.ably.lib.push.LocalDevice;
import io.ably.lib.push.Push;
import io.ably.lib.push.PushBase;
import io.ably.lib.realtime.ChannelEvent;
import io.ably.lib.realtime.ChannelState;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionEvent;
import io.ably.lib.realtime.ConnectionState;
import io.ably.lib.realtime.ConnectionStateListener;
import io.ably.lib.rest.Auth;
import io.ably.lib.rest.Auth.TokenDetails;
import io.ably.lib.rest.DeviceDetails;
import io.ably.lib.types.AsyncPaginatedResult;
import io.ably.lib.types.ChannelMode;
import io.ably.lib.types.ChannelOptions;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.DeltaExtras;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.types.Message;
import io.ably.lib.types.MessageExtras;
import io.ably.lib.types.Param;
import io.ably.lib.types.PresenceMessage;
import io.ably.lib.types.Stats;
import io.ably.lib.util.Crypto;
import io.ably.lib.util.Log;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class AblyMessageCodec extends StandardMessageCodec {

  interface CodecEncoder<T> {
    Map<String, Object> encode(T value);
  }

  interface CodecDecoder<T> {
    T decode(Map<String, Object> jsonMap);
  }

  private static class CodecPair<T> {
    private static final String TAG = CodecPair.class.getName();
    final CodecEncoder<T> encoder;
    final CodecDecoder<T> decoder;

    CodecPair(CodecEncoder<T> encoder, CodecDecoder<T> decoder) {
      this.encoder = encoder;
      this.decoder = decoder;
    }

    Map<String, Object> encode(final Object value) {
      if (this.encoder == null) {
        Log.w(TAG, "Encoder is null");
        return null;
      }
      return this.encoder.encode((T) value);
    }

    T decode(Map<String, Object> jsonMap) {
      if (this.decoder == null) {
        Log.w(TAG, "Decoder is null");
        return null;
      }
      return this.decoder.decode(jsonMap);
    }
  }

  private Map<Byte, CodecPair> codecMap;
  private static final Gson gson = new Gson();
  private final CipherParamsStorage cipherParamsStorage;

  public AblyMessageCodec(CipherParamsStorage cipherParamsStorage) {
    final AblyMessageCodec self = this;
    this.cipherParamsStorage = cipherParamsStorage;
    codecMap =
        new HashMap<Byte, CodecPair>() {
          {
            put(
                PlatformConstants.CodecTypes.ablyMessage,
                new CodecPair<>(self::encodeAblyFlutterMessage, self::decodeAblyFlutterMessage));
            put(
                PlatformConstants.CodecTypes.ablyEventMessage,
                new CodecPair<>(null, self::decodeAblyFlutterEventMessage));
            put(
                PlatformConstants.CodecTypes.clientOptions,
                new CodecPair<>(null, self::decodeClientOptions));
            put(
                PlatformConstants.CodecTypes.tokenParams,
                new CodecPair<>(self::encodeTokenParams, null));
            put(
                PlatformConstants.CodecTypes.tokenDetails,
                new CodecPair<>(null, self::decodeTokenDetails));
            put(
                PlatformConstants.CodecTypes.tokenRequest,
                new CodecPair<>(null, self::decodeTokenRequest));
            put(
                PlatformConstants.CodecTypes.restChannelOptions,
                new CodecPair<>(null, self::decodeRestChannelOptions));
            put(
                PlatformConstants.CodecTypes.realtimeChannelOptions,
                new CodecPair<>(null, self::decodeRealtimeChannelOptions));
            put(
                PlatformConstants.CodecTypes.paginatedResult,
                new CodecPair<>(self::encodePaginatedResult, null));
            put(
                PlatformConstants.CodecTypes.restHistoryParams,
                new CodecPair<>(null, self::decodeRestHistoryParams));
            put(
                PlatformConstants.CodecTypes.realtimeHistoryParams,
                new CodecPair<>(null, self::decodeRealtimeHistoryParams));
            put(PlatformConstants.CodecTypes.stats, new CodecPair<>(self::encodeStats, null));
            put(
                PlatformConstants.CodecTypes.restPresenceParams,
                new CodecPair<>(null, self::decodeRestPresenceParams));
            put(
                PlatformConstants.CodecTypes.realtimePresenceParams,
                new CodecPair<>(null, self::decodeRealtimePresenceParams));
            put(
                PlatformConstants.CodecTypes.errorInfo,
                new CodecPair<>(self::encodeErrorInfo, null));
            put(
                PlatformConstants.CodecTypes.messageData,
                new CodecPair<>(null, self::decodeChannelMessageData));
            put(
                PlatformConstants.CodecTypes.messageExtras,
                new CodecPair<>(
                    self::encodeChannelMessageExtras, self::decodeChannelMessageExtras));
            put(
                PlatformConstants.CodecTypes.message,
                new CodecPair<>(self::encodeChannelMessage, self::decodeChannelMessage));
            put(
                PlatformConstants.CodecTypes.presenceMessage,
                new CodecPair<>(self::encodePresenceMessage, null));
            put(
                PlatformConstants.CodecTypes.connectionStateChange,
                new CodecPair<>(self::encodeConnectionStateChange, null));
            put(
                PlatformConstants.CodecTypes.channelStateChange,
                new CodecPair<>(self::encodeChannelStateChange, null));
            put(
                PlatformConstants.CodecTypes.deviceDetails,
                new CodecPair<>(self::encodeDeviceDetails, null));
            put(
                PlatformConstants.CodecTypes.localDevice,
                new CodecPair<>(self::encodeLocalDevice, null));
            put(
                PlatformConstants.CodecTypes.pushChannelSubscription,
                new CodecPair<>(self::encodePushChannelSubscription, null));
            put(
                PlatformConstants.CodecTypes.remoteMessage,
                new CodecPair<>(self::encodeRemoteMessage, null));
            put(
                PlatformConstants.CodecTypes.cipherParams,
                new CodecPair<>(self::encodeCipherParams, self::decodeCipherParams));
          }
        };
  }

  private Map<String, Object> encodeStats(Stats stats) {
    if (stats == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxStats.all, encodeStatsMessageTypes(stats.all));
    writeValueToJson(
        jsonMap, PlatformConstants.TxStats.apiRequests, encodeStatsRequestCount(stats.apiRequests));
    writeValueToJson(
        jsonMap, PlatformConstants.TxStats.channels, encodeStatsResourceCount(stats.channels));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStats.connections,
        encodeStatsConnectionTypes(stats.connections));
    writeValueToJson(
        jsonMap, PlatformConstants.TxStats.inbound, encodeStatsMessageTraffic(stats.inbound));
    writeValueToJson(jsonMap, PlatformConstants.TxStats.intervalId, stats.intervalId);
    writeValueToJson(
        jsonMap, PlatformConstants.TxStats.outbound, encodeStatsMessageTraffic(stats.outbound));
    writeValueToJson(
        jsonMap, PlatformConstants.TxStats.persisted, encodeStatsMessageTypes(stats.persisted));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStats.tokenRequests,
        encodeStatsRequestCount(stats.tokenRequests));
    return jsonMap;
  }

  private Map<String, Object> encodeStatsMessageTraffic(Stats.MessageTraffic messageTraffic) {
    if (messageTraffic == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTraffic.all,
        encodeStatsMessageTypes(messageTraffic.all));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTraffic.realtime,
        encodeStatsMessageTypes(messageTraffic.realtime));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTraffic.rest,
        encodeStatsMessageTypes(messageTraffic.rest));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTraffic.webhook,
        encodeStatsMessageTypes(messageTraffic.webhook));
    return jsonMap;
  }

  private Map<String, Object> encodeStatsConnectionTypes(Stats.ConnectionTypes connectionTypes) {
    if (connectionTypes == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsConnectionTypes.all,
        encodeStatsResourceCount(connectionTypes.all));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsConnectionTypes.plain,
        encodeStatsResourceCount(connectionTypes.plain));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsConnectionTypes.tls,
        encodeStatsResourceCount(connectionTypes.tls));
    return jsonMap;
  }

  private Map<String, Object> encodeStatsResourceCount(Stats.ResourceCount resourceCount) {
    if (resourceCount == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxStatsResourceCount.mean, resourceCount.mean);
    writeValueToJson(jsonMap, PlatformConstants.TxStatsResourceCount.min, resourceCount.min);
    writeValueToJson(jsonMap, PlatformConstants.TxStatsResourceCount.opened, resourceCount.opened);
    writeValueToJson(jsonMap, PlatformConstants.TxStatsResourceCount.peak, resourceCount.peak);
    writeValueToJson(
        jsonMap, PlatformConstants.TxStatsResourceCount.refused, resourceCount.refused);
    return jsonMap;
  }

  private Map<String, Object> encodeStatsRequestCount(Stats.RequestCount apiRequests) {
    if (apiRequests == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap, PlatformConstants.TxStatsRequestCount.succeeded, apiRequests.succeeded);
    writeValueToJson(jsonMap, PlatformConstants.TxStatsRequestCount.failed, apiRequests.failed);
    writeValueToJson(jsonMap, PlatformConstants.TxStatsRequestCount.refused, apiRequests.refused);
    return jsonMap;
  }

  private Map<String, Object> encodeStatsMessageTypes(Stats.MessageTypes messageTypes) {
    if (messageTypes == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTypes.all,
        encodeMessageCategory(messageTypes.all));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTypes.messages,
        encodeMessageCategory(messageTypes.messages));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxStatsMessageTypes.presence,
        encodeMessageCategory(messageTypes.presence));
    return jsonMap;
  }

  // This is different in other platform and will correspond to StatsMessageCount for other libraries
  private Map<String, Object> encodeMessageCategory(Stats.MessageCategory category) {
    if (category == null) return null;
    if (category.category == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();

    writeValueToJson(
          jsonMap, PlatformConstants.TxStatsMessageCount.count, category.count);
    writeValueToJson(
          jsonMap, PlatformConstants.TxStatsMessageCount.data, category.data);

    return jsonMap;
  }

  @Override
  protected Object readValueOfType(final byte type, final ByteBuffer buffer) {
    CodecPair pair = codecMap.get(type);
    if (pair != null) {
      Map<String, Object> jsonMap = (Map<String, Object>) readValue(buffer);
      return pair.decode(jsonMap);
    }
    return super.readValueOfType(type, buffer);
  }

  private void readValueFromJson(
      Map<String, Object> jsonMap, String key, final Consumer<Object> consumer) {
    final Object object = jsonMap.get(key);
    if (null != object) {
      consumer.accept(object);
    }
  }

  private void writeValueToJson(Map<String, Object> jsonMap, String key, Object value) {
    if (null != value) {
      jsonMap.put(key, value);
    }
  }

  private Byte getType(Object value) {
    if (value instanceof AblyFlutterMessage) {
      return PlatformConstants.CodecTypes.ablyMessage;
    } else if (value instanceof ErrorInfo) {
      return PlatformConstants.CodecTypes.errorInfo;
    } else if (value instanceof Auth.TokenParams) {
      return PlatformConstants.CodecTypes.tokenParams;
    } else if (value instanceof AsyncPaginatedResult) {
      return PlatformConstants.CodecTypes.paginatedResult;
    } else if (value instanceof ConnectionStateListener.ConnectionStateChange) {
      return PlatformConstants.CodecTypes.connectionStateChange;
    } else if (value instanceof ChannelStateListener.ChannelStateChange) {
      return PlatformConstants.CodecTypes.channelStateChange;
    } else if (value instanceof PresenceMessage) {
      return PlatformConstants.CodecTypes.presenceMessage;
    } else if (value instanceof MessageExtras) {
      return PlatformConstants.CodecTypes.messageExtras;
    } else if (value instanceof Message) {
      return PlatformConstants.CodecTypes.message;
    } else if (value instanceof LocalDevice) {
      return PlatformConstants.CodecTypes.localDevice;
    } else if (value instanceof DeviceDetails) {
      return PlatformConstants.CodecTypes.deviceDetails;
    } else if (value instanceof Push.ChannelSubscription) {
      return PlatformConstants.CodecTypes.pushChannelSubscription;
    } else if (value instanceof RemoteMessage) {
      return PlatformConstants.CodecTypes.remoteMessage;
    } else if (value instanceof Crypto.CipherParams) {
      return PlatformConstants.CodecTypes.cipherParams;
    } else if (value instanceof ChannelOptions) {
      // Encoding it into a RealtimeChannelOptions instance, because it extends RestChannelOptions
      return PlatformConstants.CodecTypes.realtimeChannelOptions;
    }
    return null;
  }

  @Override
  protected void writeValue(ByteArrayOutputStream stream, Object value) {
    Byte type = getType(value);
    if (type != null) {
      CodecPair pair = codecMap.get(type);
      if (pair != null) {
        stream.write(type);
        writeValue(stream, pair.encode(value));
        return;
      }
    }
    if (value instanceof JsonElement) {
      WriteJsonElement(stream, (JsonElement) value);
      return;
    }
    super.writeValue(stream, value);
  }

  private void WriteJsonElement(ByteArrayOutputStream stream, JsonElement value) {
    if (value instanceof JsonObject) {
      super.writeValue(stream, gson.fromJson(value, Map.class));
    } else if (value instanceof JsonArray) {
      super.writeValue(stream, gson.fromJson(value, ArrayList.class));
    }
  }

  /**
   * Converts Map to JsonObject, ArrayList to JsonArray and returns null if these 2 types are a
   * no-match
   */
  static JsonElement readValueAsJsonElement(final Object object) {
    if (object instanceof Map) {
      return gson.fromJson(gson.toJson(object, Map.class), JsonObject.class);
    } else if (object instanceof ArrayList) {
      return gson.fromJson(gson.toJson(object, ArrayList.class), JsonArray.class);
    }
    return null;
  }

  /**
   * Dart int types get delivered to Java as Integer, unless '32 bits not enough' in which case they
   * are delivered as Long. See:
   * https://flutter.dev/docs/development/platform-integration/platform-channels#codec
   */
  private Long readValueAsLong(final Object object) {
    if (null == object) {
      return null;
    }
    if (object instanceof Integer) {
      return ((Integer) object).longValue();
    }
    return (Long) object; // will java.lang.ClassCastException if object is not a Long
  }

  private AblyFlutterMessage decodeAblyFlutterMessage(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final Long handle =
        readValueAsLong(jsonMap.get(PlatformConstants.TxAblyMessage.registrationHandle));
    final Object messageType = jsonMap.get(PlatformConstants.TxAblyMessage.type);
    final Integer type = (messageType == null) ? null : Integer.parseInt(messageType.toString());
    Object message = jsonMap.get(PlatformConstants.TxAblyMessage.message);
    if (type != null) {
      message = codecMap.get((byte) (int) type).decode((Map<String, Object>) message);
    }
    return new AblyFlutterMessage<>(message, handle);
  }

  private AblyEventMessage decodeAblyFlutterEventMessage(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final String eventName = (String) jsonMap.get(PlatformConstants.TxAblyEventMessage.eventName);
    final Object messageType = jsonMap.get(PlatformConstants.TxAblyEventMessage.type);
    final Integer type = (messageType == null) ? null : Integer.parseInt(messageType.toString());
    Object message = jsonMap.get(PlatformConstants.TxAblyEventMessage.message);
    if (type != null) {
      message = codecMap.get((byte) (int) type).decode((Map<String, Object>) message);
    }
    return new AblyEventMessage<>(eventName, message);
  }

  private PlatformClientOptions decodeClientOptions(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final ClientOptions o = new ClientOptions();

    // AuthOptions (super class of ClientOptions)
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.authUrl, v -> o.authUrl = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.authMethod, v -> o.authMethod = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.key, v -> o.key = (String) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.tokenDetails,
        v -> o.tokenDetails = decodeTokenDetails((Map<String, Object>) v));
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.authHeaders, v -> o.authHeaders = (Param[]) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.authParams, v -> o.authParams = (Param[]) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.queryTime, v -> o.queryTime = (Boolean) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.useTokenAuth, v -> o.useTokenAuth = (Boolean) v);

    // ClientOptions
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.clientId, v -> o.clientId = (String) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.logLevel,
        v -> o.logLevel = decodeLogLevel((String) v));
    readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.tls, v -> o.tls = (Boolean) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.restHost, v -> o.restHost = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.realtimeHost, v -> o.realtimeHost = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.port, v -> o.port = (Integer) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.tlsPort, v -> o.tlsPort = (Integer) v);
    o.autoConnect =
        false; // Always avoid auto-connect, to allow handle to be returned back to Dart side before
    // authCallback is called.
    // If the user specifies autoConnect, we call connect once we get the handle back to the dart
    // side
    // In other words, Ably Flutter internally manually connects, but to the SDK user this looks
    // like autoConnect.
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.useBinaryProtocol,
        v -> o.useBinaryProtocol = (Boolean) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.queueMessages,
        v -> o.queueMessages = (Boolean) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.echoMessages, v -> o.echoMessages = (Boolean) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.recover, v -> o.recover = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxClientOptions.environment, v -> o.environment = (String) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.idempotentRestPublishing,
        v -> o.idempotentRestPublishing = (Boolean) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.httpOpenTimeout,
        v -> o.httpOpenTimeout = (Integer) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.httpRequestTimeout,
        v -> o.httpRequestTimeout = (Integer) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.httpMaxRetryCount,
        v -> o.httpMaxRetryCount = (Integer) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.realtimeRequestTimeout,
        v -> o.realtimeRequestTimeout = readValueAsLong(v));
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.fallbackHosts,
        v -> o.fallbackHosts = (String[]) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.fallbackHostsUseDefault,
        v -> o.fallbackHostsUseDefault = (Boolean) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.fallbackRetryTimeout,
        v -> o.fallbackRetryTimeout = readValueAsLong(v));
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.defaultTokenParams,
        v -> o.defaultTokenParams = decodeTokenParams((Map<String, Object>) v));
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.channelRetryTimeout,
        v -> o.channelRetryTimeout = (Integer) v);
    readValueFromJson(
        jsonMap,
        PlatformConstants.TxClientOptions.transportParams,
        v -> o.transportParams = (Param[]) v);

    o.agents = new HashMap<>();
    o.agents.put("ably-flutter", BuildConfig.FLUTTER_PACKAGE_PLUGIN_VERSION);

    return new PlatformClientOptions(
        o,
        jsonMap.containsKey(PlatformConstants.TxClientOptions.hasAuthCallback)
            ? ((boolean) jsonMap.get(PlatformConstants.TxClientOptions.hasAuthCallback))
            : false);
  }

  private int decodeLogLevel(String logLevelString) {
    if (logLevelString == null) return Log.WARN;
    switch (logLevelString) {
      case PlatformConstants.TxLogLevelEnum.none:
        return Log.NONE;
      case PlatformConstants.TxLogLevelEnum.verbose:
        return Log.VERBOSE;
      case PlatformConstants.TxLogLevelEnum.debug:
        return Log.DEBUG;
      case PlatformConstants.TxLogLevelEnum.info:
        return Log.INFO;
      case PlatformConstants.TxLogLevelEnum.error:
        return Log.ERROR;
      default:
        return Log.WARN;
    }
  }

  private TokenDetails decodeTokenDetails(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final TokenDetails o = new TokenDetails();
    readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.token, v -> o.token = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.expires, v -> o.expires = (int) v);
    readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.issued, v -> o.issued = (int) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenDetails.capability, v -> o.capability = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenDetails.clientId, v -> o.clientId = (String) v);

    return o;
  }

  private Auth.TokenParams decodeTokenParams(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final Auth.TokenParams o = new Auth.TokenParams();
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenParams.capability, v -> o.capability = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenParams.clientId, v -> o.clientId = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenParams.timestamp, v -> o.timestamp = readValueAsLong(v));
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenParams.ttl, v -> o.ttl = readValueAsLong(v));
    // nonce is not supported in ably-java
    // Track @ https://github.com/ably/ably-flutter/issues/14
    return o;
  }

  private Auth.TokenRequest decodeTokenRequest(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final Auth.TokenRequest o = new Auth.TokenRequest();
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenRequest.keyName, v -> o.keyName = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxTokenRequest.nonce, v -> o.nonce = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxTokenRequest.mac, v -> o.mac = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenRequest.capability, v -> o.capability = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenRequest.clientId, v -> o.clientId = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenRequest.timestamp, v -> o.timestamp = readValueAsLong(v));
    readValueFromJson(
        jsonMap, PlatformConstants.TxTokenRequest.ttl, v -> o.ttl = readValueAsLong(v));
    return o;
  }

  private ChannelOptions decodeRestChannelOptions(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    ChannelOptions options = new ChannelOptions();
    options.cipherParams =
        decodeCipherParams(
            (Map<String, Object>) jsonMap.get(PlatformConstants.TxRestChannelOptions.cipherParams));
    if (options.cipherParams != null) {
      options.encrypted = true;
    }
    return options;
  }

  private ChannelOptions decodeRealtimeChannelOptions(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    ChannelOptions options = new ChannelOptions();
    options.cipherParams =
        decodeCipherParams(
            (Map<String, Object>)
                jsonMap.get(PlatformConstants.TxRealtimeChannelOptions.cipherParams));
    if (options.cipherParams != null) {
      options.encrypted = true;
    }
    options.params =
        (Map<String, String>) jsonMap.get(PlatformConstants.TxRealtimeChannelOptions.params);
    final ArrayList<String> modes =
        (ArrayList<String>) jsonMap.get(PlatformConstants.TxRealtimeChannelOptions.modes);
    if (modes != null && modes.size() > 0) {
      options.modes = createChannelModesArray(modes);
    }

    return options;
  }

  private Map<String, Object> encodeCipherParams(Crypto.CipherParams cipherParams) {
    if (cipherParams == null) return null;
    final Integer handle = cipherParamsStorage.getHandle(cipherParams);
    HashMap<String, Object> jsonMap = new HashMap<>();

    // All other properties in CipherParams are package private, so cannot be exposed to Dart side.
    jsonMap.put(PlatformConstants.TxCipherParams.androidHandle, handle);

    return jsonMap;
  }

  private Crypto.CipherParams decodeCipherParams(
      @Nullable Map<String, Object> cipherParamsDictionary) {
    if (cipherParamsDictionary == null) return null;
    final Integer cipherParamsHandle =
        (Integer) cipherParamsDictionary.get(PlatformConstants.TxCipherParams.androidHandle);
    return cipherParamsStorage.from(cipherParamsHandle);
  }

  private ChannelMode[] createChannelModesArray(ArrayList<String> modesString) {
    ChannelMode[] modes = new ChannelMode[modesString.size()];
    for (int i = 0; i < modesString.size(); i++) {
      modes[i] = decodeChannelOptionsMode(modesString.get(i));
    }
    return modes;
  }

  private ChannelMode decodeChannelOptionsMode(String mode) {
    switch (mode) {
      case PlatformConstants.TxEnumConstants.presence:
        return ChannelMode.presence;
      case PlatformConstants.TxEnumConstants.publish:
        return ChannelMode.publish;
      case PlatformConstants.TxEnumConstants.subscribe:
        return ChannelMode.subscribe;
      case PlatformConstants.TxEnumConstants.presenceSubscribe:
        return ChannelMode.presence_subscribe;
      default:
        return null;
    }
  }

  private Param[] decodeRestHistoryParams(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    Param[] params = new Param[jsonMap.size()];
    int index = 0;
    final Object start = jsonMap.get(PlatformConstants.TxRestHistoryParams.start);
    final Object end = jsonMap.get(PlatformConstants.TxRestHistoryParams.end);
    final Object limit = jsonMap.get(PlatformConstants.TxRestHistoryParams.limit);
    final Object direction = jsonMap.get(PlatformConstants.TxRestHistoryParams.direction);
    if (start != null) {
      params[index++] =
          new Param(PlatformConstants.TxRestHistoryParams.start, readValueAsLong(start));
    }
    if (end != null) {
      params[index++] = new Param(PlatformConstants.TxRestHistoryParams.end, readValueAsLong(end));
    }
    if (limit != null) {
      params[index++] = new Param(PlatformConstants.TxRestHistoryParams.limit, (Integer) limit);
    }
    if (direction != null) {
      params[index] =
          new Param(PlatformConstants.TxRestHistoryParams.direction, (String) direction);
    }
    return params;
  }

  private Param[] decodeRealtimeHistoryParams(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    Param[] params = new Param[jsonMap.size()];
    int index = 0;
    final Object start = jsonMap.get(PlatformConstants.TxRealtimeHistoryParams.start);
    final Object end = jsonMap.get(PlatformConstants.TxRealtimeHistoryParams.end);
    final Object limit = jsonMap.get(PlatformConstants.TxRealtimeHistoryParams.limit);
    final Object direction = jsonMap.get(PlatformConstants.TxRealtimeHistoryParams.direction);
    final Object untilAttach = jsonMap.get(PlatformConstants.TxRealtimeHistoryParams.untilAttach);
    if (start != null) {
      params[index++] =
          new Param(PlatformConstants.TxRealtimeHistoryParams.start, readValueAsLong(start));
    }
    if (end != null) {
      params[index++] =
          new Param(PlatformConstants.TxRealtimeHistoryParams.end, readValueAsLong(end));
    }
    if (limit != null) {
      params[index++] = new Param(PlatformConstants.TxRealtimeHistoryParams.limit, (Integer) limit);
    }
    if (direction != null) {
      params[index++] =
          new Param(PlatformConstants.TxRealtimeHistoryParams.direction, (String) direction);
    }
    if (untilAttach != null) {
      params[index] =
          new Param(PlatformConstants.TxRealtimeHistoryParams.untilAttach, (boolean) untilAttach);
    }
    return params;
  }

  private Param[] decodeRestPresenceParams(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    Param[] params = new Param[jsonMap.size()];
    int index = 0;
    final Object limit = jsonMap.get(PlatformConstants.TxRestPresenceParams.limit);
    final Object clientId = jsonMap.get(PlatformConstants.TxRestPresenceParams.clientId);
    final Object connectionId = jsonMap.get(PlatformConstants.TxRestPresenceParams.connectionId);
    if (limit != null) {
      params[index++] = new Param(PlatformConstants.TxRestPresenceParams.limit, (Integer) limit);
    }
    if (clientId != null) {
      params[index++] =
          new Param(PlatformConstants.TxRestPresenceParams.clientId, (String) clientId);
    }
    if (connectionId != null) {
      params[index] =
          new Param(PlatformConstants.TxRestPresenceParams.connectionId, (String) connectionId);
    }
    return params;
  }

  private Param[] decodeRealtimePresenceParams(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    Param[] params = new Param[jsonMap.size()];
    int index = 0;
    final Object waitForSync = jsonMap.get(PlatformConstants.TxRealtimePresenceParams.waitForSync);
    final Object clientId = jsonMap.get(PlatformConstants.TxRealtimePresenceParams.clientId);
    final Object connectionId =
        jsonMap.get(PlatformConstants.TxRealtimePresenceParams.connectionId);
    if (waitForSync != null) {
      params[index++] =
          new Param(PlatformConstants.TxRealtimePresenceParams.waitForSync, (Boolean) waitForSync);
    }
    if (clientId != null) {
      params[index++] =
          new Param(PlatformConstants.TxRealtimePresenceParams.clientId, (String) clientId);
    }
    if (connectionId != null) {
      params[index] =
          new Param(PlatformConstants.TxRealtimePresenceParams.connectionId, (String) connectionId);
    }
    return params;
  }

  private Object decodeMessageData(Object messageData) {
    final JsonElement json = readValueAsJsonElement(messageData);
    return (json == null) ? messageData : json;
  }

  private Object decodeChannelMessageData(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    return decodeMessageData(jsonMap.get(PlatformConstants.TxMessage.data));
  }

  private MessageExtras decodeChannelMessageExtras(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    Object extras = jsonMap.get(PlatformConstants.TxMessageExtras.extras);
    // extras received from dart side could be a nested map with dynamic value types
    // So, converting to a json string and then using that to create a JSONObject
    String extrasJson = gson.toJson(extras, Map.class);
    return new MessageExtras(gson.fromJson(extrasJson, JsonObject.class));
  }

  private Message decodeChannelMessage(Map<String, Object> jsonMap) {
    if (jsonMap == null) return null;
    final Message o = new Message();
    readValueFromJson(jsonMap, PlatformConstants.TxMessage.id, v -> o.id = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxMessage.clientId, v -> o.clientId = (String) v);
    readValueFromJson(jsonMap, PlatformConstants.TxMessage.name, v -> o.name = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxMessage.data, v -> o.data = decodeMessageData(v));
    readValueFromJson(jsonMap, PlatformConstants.TxMessage.encoding, v -> o.encoding = (String) v);
    readValueFromJson(
        jsonMap, PlatformConstants.TxMessage.extras, v -> o.extras = (MessageExtras) v);
    return o;
  }

  // ===============================================================
  // =====================HANDLING WRITE============================
  // ===============================================================

  private Map<String, Object> encodeAblyFlutterMessage(AblyFlutterMessage c) {
    if (c == null) return null;
    HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.registrationHandle, c.handle);
    Byte type = getType(c.message);
    CodecPair pair = codecMap.get(type);
    if (type != null && pair != null) {
      writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.type, type & 0xff);
      writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.message, pair.encode(c.message));
    }
    return jsonMap;
  }

  private Map<String, Object> encodeErrorInfo(ErrorInfo c) {
    if (c == null) return null;
    HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxErrorInfo.code, c.code);
    writeValueToJson(jsonMap, PlatformConstants.TxErrorInfo.message, c.message);
    writeValueToJson(jsonMap, PlatformConstants.TxErrorInfo.statusCode, c.statusCode);
    writeValueToJson(jsonMap, PlatformConstants.TxErrorInfo.href, c.href);
    // requestId and cause - not available in ably-java
    // track @ https://github.com/ably/ably-flutter/issues/14
    return jsonMap;
  }

  private Map<String, Object> encodeTokenParams(Auth.TokenParams c) {
    if (c == null) return null;
    HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.capability, c.capability);
    writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.timestamp, c.timestamp);
    writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.ttl, c.ttl);
    // nonce is not supported in ably-java
    // Track @ https://github.com/ably/ably-flutter/issues/14
    return jsonMap;
  }

  private String encodeConnectionState(ConnectionState state) {
    switch (state) {
      case initialized:
        return PlatformConstants.TxEnumConstants.initialized;
      case connecting:
        return PlatformConstants.TxEnumConstants.connecting;
      case connected:
        return PlatformConstants.TxEnumConstants.connected;
      case disconnected:
        return PlatformConstants.TxEnumConstants.disconnected;
      case suspended:
        return PlatformConstants.TxEnumConstants.suspended;
      case closing:
        return PlatformConstants.TxEnumConstants.closing;
      case closed:
        return PlatformConstants.TxEnumConstants.closed;
      case failed:
        return PlatformConstants.TxEnumConstants.failed;
      default:
        return null;
    }
  }

  private String encodeConnectionEvent(ConnectionEvent event) {
    switch (event) {
      case initialized:
        return PlatformConstants.TxEnumConstants.initialized;
      case connecting:
        return PlatformConstants.TxEnumConstants.connecting;
      case connected:
        return PlatformConstants.TxEnumConstants.connected;
      case disconnected:
        return PlatformConstants.TxEnumConstants.disconnected;
      case suspended:
        return PlatformConstants.TxEnumConstants.suspended;
      case closing:
        return PlatformConstants.TxEnumConstants.closing;
      case closed:
        return PlatformConstants.TxEnumConstants.closed;
      case failed:
        return PlatformConstants.TxEnumConstants.failed;
      case update:
        return PlatformConstants.TxEnumConstants.update;
      default:
        return null;
    }
  }

  private String encodeChannelState(ChannelState state) {
    switch (state) {
      case initialized:
        return PlatformConstants.TxEnumConstants.initialized;
      case attaching:
        return PlatformConstants.TxEnumConstants.attaching;
      case attached:
        return PlatformConstants.TxEnumConstants.attached;
      case detaching:
        return PlatformConstants.TxEnumConstants.detaching;
      case detached:
        return PlatformConstants.TxEnumConstants.detached;
      case failed:
        return PlatformConstants.TxEnumConstants.failed;
      case suspended:
        return PlatformConstants.TxEnumConstants.suspended;
      default:
        return null;
    }
  }

  private String encodeChannelEvent(ChannelEvent event) {
    switch (event) {
      case initialized:
        return PlatformConstants.TxEnumConstants.initialized;
      case attaching:
        return PlatformConstants.TxEnumConstants.attaching;
      case attached:
        return PlatformConstants.TxEnumConstants.attached;
      case detaching:
        return PlatformConstants.TxEnumConstants.detaching;
      case detached:
        return PlatformConstants.TxEnumConstants.detached;
      case failed:
        return PlatformConstants.TxEnumConstants.failed;
      case suspended:
        return PlatformConstants.TxEnumConstants.suspended;
      case update:
        return PlatformConstants.TxEnumConstants.update;
      default:
        return null;
    }
  }

  private Map<String, Object> encodePaginatedResult(AsyncPaginatedResult<Object> c) {
    if (c == null) return null;
    HashMap<String, Object> jsonMap = new HashMap<>();
    Object[] items = c.items();
    if (items.length > 0) {
      Byte type = getType(items[0]);
      CodecPair pair = codecMap.get(type);
      if (type != null && pair != null) {
        ArrayList<Map<String, Object>> list = new ArrayList<>(items.length);
        for (Object item : items) {
          list.add((Map<String, Object>) pair.encode(item));
        }
        writeValueToJson(jsonMap, PlatformConstants.TxPaginatedResult.items, list);
        writeValueToJson(jsonMap, PlatformConstants.TxPaginatedResult.type, type & 0xff);
      }
    } else {
      writeValueToJson(jsonMap, PlatformConstants.TxPaginatedResult.items, null);
    }
    writeValueToJson(jsonMap, PlatformConstants.TxPaginatedResult.hasNext, c.hasNext());
    return jsonMap;
  }

  private Map<String, Object> encodeConnectionStateChange(
      ConnectionStateListener.ConnectionStateChange c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxConnectionStateChange.current,
        encodeConnectionState(c.current));
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxConnectionStateChange.previous,
        encodeConnectionState(c.previous));
    writeValueToJson(
        jsonMap, PlatformConstants.TxConnectionStateChange.event, encodeConnectionEvent(c.event));
    writeValueToJson(jsonMap, PlatformConstants.TxConnectionStateChange.retryIn, c.retryIn);
    writeValueToJson(
        jsonMap, PlatformConstants.TxConnectionStateChange.reason, encodeErrorInfo(c.reason));
    return jsonMap;
  }

  private Map<String, Object> encodeChannelStateChange(ChannelStateListener.ChannelStateChange c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(
        jsonMap, PlatformConstants.TxChannelStateChange.current, encodeChannelState(c.current));
    writeValueToJson(
        jsonMap, PlatformConstants.TxChannelStateChange.previous, encodeChannelState(c.previous));
    writeValueToJson(
        jsonMap, PlatformConstants.TxChannelStateChange.event, encodeChannelEvent(c.event));
    writeValueToJson(jsonMap, PlatformConstants.TxChannelStateChange.resumed, c.resumed);
    writeValueToJson(
        jsonMap, PlatformConstants.TxChannelStateChange.reason, encodeErrorInfo(c.reason));
    return jsonMap;
  }

  private Map<String, Object> encodeDeviceDetails(DeviceDetails c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();

    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.id, c.id);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.platform, c.platform);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.formFactor, c.formFactor);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.metadata, c.metadata);
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxDeviceDetails.devicePushDetails,
        encodeDevicePushDetails(c.push));

    return jsonMap;
  }

  private Map<String, Object> encodeDevicePushDetails(DeviceDetails.Push c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();

    writeValueToJson(jsonMap, PlatformConstants.TxDevicePushDetails.recipient, c.recipient);
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxDevicePushDetails.state,
        encodeDevicePushDetailsState(c.state));
    writeValueToJson(
        jsonMap, PlatformConstants.TxDevicePushDetails.errorReason, encodeErrorInfo(c.errorReason));

    return jsonMap;
  }

  private String encodeDevicePushDetailsState(DeviceDetails.Push.State state) {
    if (state == null) return null;

    switch (state) {
      case ACTIVE:
        return PlatformConstants.TxDevicePushStateEnum.active;
      case FAILING:
        return PlatformConstants.TxDevicePushStateEnum.failing;
      case FAILED:
        return PlatformConstants.TxDevicePushStateEnum.failed;
      default:
        return null;
    }
  }

  private Map<String, Object> encodeLocalDevice(LocalDevice c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();

    writeValueToJson(jsonMap, PlatformConstants.TxLocalDevice.deviceSecret, c.deviceSecret);
    writeValueToJson(
        jsonMap, PlatformConstants.TxLocalDevice.deviceIdentityToken, c.deviceIdentityToken);

    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.id, c.id);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.platform, c.platform);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.formFactor, c.formFactor);
    writeValueToJson(jsonMap, PlatformConstants.TxDeviceDetails.metadata, c.metadata);
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxDeviceDetails.devicePushDetails,
        encodeDevicePushDetails(c.push));

    return jsonMap;
  }

  private Map<String, Object> encodePushChannelSubscription(PushBase.ChannelSubscription c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();

    writeValueToJson(jsonMap, PlatformConstants.TxPushChannelSubscription.channel, c.channel);
    writeValueToJson(jsonMap, PlatformConstants.TxPushChannelSubscription.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxPushChannelSubscription.deviceId, c.deviceId);

    return jsonMap;
  }

  private Map<String, Object> encodeChannelMessageExtras(MessageExtras c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap =
        gson.<HashMap<String, Object>>fromJson(c.asJsonObject().toString(), HashMap.class);
    DeltaExtras deltaExtras = c.getDelta();
    if (deltaExtras != null) {
      final HashMap<String, Object> deltaJson = new HashMap<>();
      writeValueToJson(deltaJson, PlatformConstants.TxDeltaExtras.format, deltaExtras.getFormat());
      writeValueToJson(deltaJson, PlatformConstants.TxDeltaExtras.from, deltaExtras.getFrom());
      writeValueToJson(jsonMap, PlatformConstants.TxMessageExtras.delta, deltaJson);
    }
    return jsonMap;
  }

  private Map<String, Object> encodeChannelMessage(Message c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.id, c.id);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.connectionId, c.connectionId);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.timestamp, c.timestamp);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.name, c.name);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.data, c.data);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.encoding, c.encoding);
    writeValueToJson(jsonMap, PlatformConstants.TxMessage.extras, c.extras);
    return jsonMap;
  }

  private String encodePresenceAction(PresenceMessage.Action action) {
    switch (action) {
      case absent:
        return PlatformConstants.TxEnumConstants.absent;
      case leave:
        return PlatformConstants.TxEnumConstants.leave;
      case enter:
        return PlatformConstants.TxEnumConstants.enter;
      case present:
        return PlatformConstants.TxEnumConstants.present;
      case update:
        return PlatformConstants.TxEnumConstants.update;
      default:
        return null;
    }
  }

  private Map<String, Object> encodePresenceMessage(PresenceMessage c) {
    if (c == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.id, c.id);
    writeValueToJson(
        jsonMap, PlatformConstants.TxPresenceMessage.action, encodePresenceAction(c.action));
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.clientId, c.clientId);
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.connectionId, c.connectionId);
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.timestamp, c.timestamp);
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.data, c.data);
    writeValueToJson(jsonMap, PlatformConstants.TxPresenceMessage.encoding, c.encoding);
    // PresenceMessage#extras is not supported in ably-java
    // Track @ https://github.com/ably/ably-flutter/issues/14
    return jsonMap;
  }

  private Map<String, Object> encodeRemoteMessage(RemoteMessage message) {
    if (message == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxRemoteMessage.data, message.getData());
    writeValueToJson(
        jsonMap,
        PlatformConstants.TxRemoteMessage.notification,
        encodeNotification(message.getNotification()));
    return jsonMap;
  }

  private Map<String, Object> encodeNotification(RemoteMessage.Notification notification) {
    if (notification == null) return null;
    final HashMap<String, Object> jsonMap = new HashMap<>();
    writeValueToJson(jsonMap, PlatformConstants.TxNotification.title, notification.getTitle());
    writeValueToJson(jsonMap, PlatformConstants.TxNotification.body, notification.getBody());
    return jsonMap;
  }
}
