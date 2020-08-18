package io.ably.flutter.plugin;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.types.PlatformClientOptions;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionStateListener;
import io.ably.lib.rest.Auth;
import io.ably.lib.rest.Auth.TokenDetails;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.types.Message;
import io.ably.lib.types.Param;
import io.flutter.plugin.common.StandardMessageCodec;

public class AblyMessageCodec extends StandardMessageCodec {

    interface CodecEncoder<T> {
        Map<String, Object> encode(T value);
    }

    interface CodecDecoder<T> {
        T decode(Map<String, Object> jsonMap);
    }

    private static class CodecPair<T> {

        final CodecEncoder<T> encoder;
        final CodecDecoder<T> decoder;

        CodecPair(CodecEncoder<T> encoder, CodecDecoder<T> decoder) {
            this.encoder = encoder;
            this.decoder = decoder;
        }

        Map<String, Object> encode(final Object value) {
            if (this.encoder == null) {
                System.out.println("Codec encoder not defined");
                return null;
            }
            return this.encoder.encode((T) value);
        }

        T decode(Map<String, Object> jsonMap) {
            if (this.decoder == null) {
                System.out.println("Codec decoder not defined");
                return null;
            }
            return this.decoder.decode(jsonMap);
        }
    }

    private Map<Byte, CodecPair> codecMap;

    AblyMessageCodec() {
        final AblyMessageCodec self = this;
        codecMap = new HashMap<Byte, CodecPair>() {
            {
                put(PlatformConstants.CodecTypes.ablyMessage,
                        new CodecPair<>(self::encodeAblyFlutterMessage, self::decodeAblyFlutterMessage));
                put(PlatformConstants.CodecTypes.ablyEventMessage,
                        new CodecPair<>(null, self::decodeAblyFlutterEventMessage));
                put(PlatformConstants.CodecTypes.clientOptions,
                        new CodecPair<>(null, self::decodeClientOptions));
                put(PlatformConstants.CodecTypes.tokenParams,
                        new CodecPair<>(self::encodeTokenParams, null));
                put(PlatformConstants.CodecTypes.tokenDetails,
                        new CodecPair<>(null, self::decodeTokenDetails));
                put(PlatformConstants.CodecTypes.tokenRequest,
                        new CodecPair<>(null, self::decodeTokenRequest));
                put(PlatformConstants.CodecTypes.errorInfo,
                        new CodecPair<>(self::encodeErrorInfo, null));
                put(PlatformConstants.CodecTypes.message,
                        new CodecPair<>(self::encodeChannelMessage, self::decodeChannelMessage));
                put(PlatformConstants.CodecTypes.connectionStateChange,
                        new CodecPair<>(self::encodeConnectionStateChange, null));
                put(PlatformConstants.CodecTypes.channelStateChange,
                        new CodecPair<>(self::encodeChannelStateChange, null));
            }
        };
    }

    @Override
    protected Object readValueOfType(final byte type, final ByteBuffer buffer) {
        CodecPair pair = codecMap.get(type);
        if(pair!=null){
            Map<String, Object> jsonMap = (Map<String, Object>)readValue(buffer);
            return pair.decode(jsonMap);
        }
        return super.readValueOfType(type, buffer);
    }

    private void readValueFromJson(Map<String, Object> jsonMap, String key, final Consumer<Object> consumer) {
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

    private void writeEnumToJson(Map<String, Object> jsonMap, String key, Enum value) {
        if (null != value) {
            jsonMap.put(key, value.ordinal());
        }
    }

    private Byte getType(Object value){
        if(value instanceof AblyFlutterMessage) {
            return PlatformConstants.CodecTypes.ablyMessage;
        }else if(value instanceof ErrorInfo){
            return PlatformConstants.CodecTypes.errorInfo;
        }else if(value instanceof Auth.TokenParams){
            return PlatformConstants.CodecTypes.tokenParams;
        }else if(value instanceof ConnectionStateListener.ConnectionStateChange){
            return PlatformConstants.CodecTypes.connectionStateChange;
        }else if(value instanceof ChannelStateListener.ChannelStateChange){
            return PlatformConstants.CodecTypes.channelStateChange;
        }else if(value instanceof Message){
            return PlatformConstants.CodecTypes.message;
        }
        return null;
    }

    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
        Byte type = getType(value);
        if(type!=null){
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
            super.writeValue(stream, (new Gson()).fromJson(value, Map.class));
        } else if (value instanceof JsonArray) {
            super.writeValue(stream, (new Gson()).fromJson(value, ArrayList.class));
        }
    }

    /**
     * Converts Map to JsonObject, ArrayList to JsonArray and
     * returns null if these 2 types are a no-match
     */
    static JsonElement readValueAsJsonElement(final Object object) {
        final Gson gson = new Gson();
        if (object instanceof Map) {
            return gson.fromJson(gson.toJson(object, Map.class), JsonObject.class);
        } else if (object instanceof ArrayList) {
            return gson.fromJson(gson.toJson(object, ArrayList.class), JsonArray.class);
        }
        return null;
    }

    /**
     * Dart int types get delivered to Java as Integer, unless '32 bits not enough' in which case
     * they are delivered as Long.
     * See: https://flutter.dev/docs/development/platform-integration/platform-channels#codec
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
        final Long handle = readValueAsLong(jsonMap.get(PlatformConstants.TxAblyMessage.registrationHandle));
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

    private ClientOptions decodeClientOptions(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final PlatformClientOptions o = new PlatformClientOptions();

        // AuthOptions (super class of ClientOptions)
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.authUrl, v -> o.authUrl = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.authMethod, v -> o.authMethod = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.key, v -> o.key = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.tokenDetails, v -> o.tokenDetails = decodeTokenDetails((Map<String, Object>)v));
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.authHeaders, v -> o.authHeaders = (Param[])v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.authParams, v -> o.authParams = (Param[])v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.queryTime, v -> o.queryTime = (Boolean)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.useTokenAuth, v -> o.useTokenAuth = (Boolean)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.hasAuthCallback, v -> o.hasAuthCallback = (Boolean)v);

        // ClientOptions
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.clientId, v -> o.clientId = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.logLevel, v -> o.logLevel = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.tls, v -> o.tls = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.restHost, v -> o.restHost = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.realtimeHost, v -> o.realtimeHost = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.port, v -> o.port = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.tlsPort, v -> o.tlsPort = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.autoConnect, v -> o.autoConnect = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.useBinaryProtocol, v -> o.useBinaryProtocol = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.queueMessages, v -> o.queueMessages = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.echoMessages, v -> o.echoMessages = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.recover, v -> o.recover = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.environment, v -> o.environment = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.idempotentRestPublishing, v -> o.idempotentRestPublishing = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.httpOpenTimeout, v -> o.httpOpenTimeout = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.httpRequestTimeout, v -> o.httpRequestTimeout = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.httpMaxRetryCount, v -> o.httpMaxRetryCount = (Integer) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.realtimeRequestTimeout, v -> o.realtimeRequestTimeout = readValueAsLong(v));
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.fallbackHosts, v -> o.fallbackHosts = (String[]) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.fallbackHostsUseDefault, v -> o.fallbackHostsUseDefault = (Boolean) v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.fallbackRetryTimeout, v -> o.fallbackRetryTimeout = readValueAsLong(v));
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.defaultTokenParams, v -> o.defaultTokenParams = decodeTokenParams((Map<String, Object>)v));
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.channelRetryTimeout, v -> o.channelRetryTimeout = (Integer)v);
        readValueFromJson(jsonMap, PlatformConstants.TxClientOptions.transportParams, v -> o.transportParams = (Param[])v);
        return o;
    }

    private TokenDetails decodeTokenDetails(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final TokenDetails o = new TokenDetails();
        readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.token, v -> o.token = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.expires, v -> o.expires = (int) v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.issued, v -> o.issued = (int) v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.capability, v -> o.capability = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenDetails.clientId, v -> o.clientId = (String) v);

        return o;
    }

    private Auth.TokenParams decodeTokenParams(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final Auth.TokenParams o = new Auth.TokenParams();
        readValueFromJson(jsonMap, PlatformConstants.TxTokenParams.capability, v -> o.capability = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenParams.clientId, v -> o.clientId = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenParams.timestamp, v -> o.timestamp = readValueAsLong(v));
        readValueFromJson(jsonMap, PlatformConstants.TxTokenParams.ttl, v -> o.ttl = readValueAsLong(v));
        // nonce is not supported in ably-java
        // Track @ https://github.com/ably/ably-flutter/issues/14
        return o;
    }

    private Auth.TokenRequest decodeTokenRequest(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final Auth.TokenRequest o = new Auth.TokenRequest();
        readValueFromJson(jsonMap, PlatformConstants.TxTokenRequest.keyName, v -> o.keyName = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenRequest.nonce, v -> o.nonce = (String)v);
        readValueFromJson(jsonMap, PlatformConstants.TxTokenRequest.mac, v -> o.mac = (String)v);
        // capability, clientId, timestamp, ttl are not supported in ably-java
        // Track @ https://github.com/ably/ably-flutter/issues/14
        return o;
    }

    private Message decodeChannelMessage(Map<String, Object> jsonMap) {
        if (jsonMap == null) return null;
        final Message o = new Message();
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.id, v -> o.id = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.clientId, v -> o.clientId = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.name, v -> o.name = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.data, v -> {
            final JsonElement json = readValueAsJsonElement(v);
            o.data = (json == null) ? v : json;
        });
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.encoding, v -> o.encoding = (String) v);
        readValueFromJson(jsonMap, PlatformConstants.TxMessage.extras, v -> {
            final Gson gson = new Gson();
            o.extras = gson.fromJson(gson.toJson(v, Map.class), JsonObject.class);
        });
        return o;
    }

//===============================================================
//=====================HANDLING WRITE============================
//===============================================================

    private Map<String, Object> encodeAblyFlutterMessage(AblyFlutterMessage c) {
        if(c==null) return null;
        HashMap<String, Object> jsonMap = new HashMap<>();
        writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.registrationHandle, c.handle);
        Byte type = getType(c.message);
        CodecPair pair = codecMap.get(type);
        if(type!=null && pair!=null){
            writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.type, type & 0xff);
            writeValueToJson(jsonMap, PlatformConstants.TxAblyMessage.message, pair.encode(c.message));
        }
        return jsonMap;
    }

    private Map<String, Object> encodeErrorInfo(ErrorInfo c){
        if(c==null) return null;
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
        if(c==null) return null;
        HashMap<String, Object> jsonMap = new HashMap<>();
        writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.capability, c.capability);
        writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.clientId, c.clientId);
        writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.timestamp, c.timestamp);
        writeValueToJson(jsonMap, PlatformConstants.TxTokenParams.ttl, c.ttl);
        // nonce is not supported in ably-java
        // Track @ https://github.com/ably/ably-flutter/issues/14
        return jsonMap;
    }

    private Map<String, Object> encodeConnectionStateChange(ConnectionStateListener.ConnectionStateChange c) {
        if (c == null) return null;
        final HashMap<String, Object> jsonMap = new HashMap<>();
        writeEnumToJson(jsonMap, PlatformConstants.TxConnectionStateChange.current, c.current);
        writeEnumToJson(jsonMap, PlatformConstants.TxConnectionStateChange.previous, c.previous);
        writeEnumToJson(jsonMap, PlatformConstants.TxConnectionStateChange.event, c.event);
        writeValueToJson(jsonMap, PlatformConstants.TxConnectionStateChange.retryIn, c.retryIn);
        writeValueToJson(jsonMap, PlatformConstants.TxConnectionStateChange.reason, encodeErrorInfo(c.reason));
        return jsonMap;
    }

    private Map<String, Object> encodeChannelStateChange(ChannelStateListener.ChannelStateChange c) {
        if (c == null) return null;
        final HashMap<String, Object> jsonMap = new HashMap<>();
        writeEnumToJson(jsonMap, PlatformConstants.TxChannelStateChange.current, c.current);
        writeEnumToJson(jsonMap, PlatformConstants.TxChannelStateChange.previous, c.previous);
        writeEnumToJson(jsonMap, PlatformConstants.TxChannelStateChange.event, c.event);
        writeValueToJson(jsonMap, PlatformConstants.TxChannelStateChange.resumed, c.resumed);
        writeValueToJson(jsonMap, PlatformConstants.TxChannelStateChange.reason, encodeErrorInfo(c.reason));
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

}
