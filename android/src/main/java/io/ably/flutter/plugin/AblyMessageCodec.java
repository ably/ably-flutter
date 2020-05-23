package io.ably.flutter.plugin;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import io.ably.lib.realtime.ChannelEvent;
import io.ably.lib.realtime.ChannelState;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionEvent;
import io.ably.lib.realtime.ConnectionState;
import io.ably.lib.realtime.ConnectionStateListener;
import io.ably.lib.rest.Auth;
import io.ably.lib.rest.Auth.TokenDetails;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.types.Param;
import io.flutter.plugin.common.StandardMessageCodec;
import io.ably.flutter.plugin.gen.PlatformConstants;

public class AblyMessageCodec extends StandardMessageCodec {

    interface CodecEncoder<T>{ Map<String, Object> encode(T value); }
    interface CodecDecoder<T>{ T decode(Map<String, Object> jsonMap); }

    class CodecPair<T>{

        final CodecEncoder<T> encoder;
        final CodecDecoder<T> decoder;
        CodecPair(CodecEncoder<T> encoder, CodecDecoder<T> decoder){
            this.encoder = encoder;
            this.decoder = decoder;
        }

        Map<String, Object> encode(final Object value){
            if(this.encoder==null){
                System.out.println("Codec encoder not defined");
                return null;
            }
            return this.encoder.encode((T)value);
        }

        T decode(Map<String, Object> jsonMap){
            if(this.decoder==null){
                System.out.println("Codec decoder not defined");
                return null;
            }
            return this.decoder.decode(jsonMap);
        }
    }

    private Map<Byte, CodecPair> codecMap;

    AblyMessageCodec(){
        AblyMessageCodec self = this;
        codecMap = new HashMap<Byte, CodecPair>(){
            {
                put(PlatformConstants.CodecTypes.ablyMessage, new CodecPair<>(null, self::readAblyFlutterMessage));
                put(PlatformConstants.CodecTypes.clientOptions, new CodecPair<>(null, self::readClientOptions));
//                put(PlatformConstants.CodecTypes.tokenDetails, new CodecPair<>(null, self::readTokenDetails));
                put(PlatformConstants.CodecTypes.errorInfo, new CodecPair<>(self::encodeErrorInfo, null));

//                put(PlatformConstants.CodecTypes.connectionEvent, new CodecPair<>(self::writeConnectionEvent, null));
//                put(PlatformConstants.CodecTypes.connectionState, new CodecPair<>(self::writeConnectionState, null));
                put(PlatformConstants.CodecTypes.connectionStateChange, new CodecPair<>(self::encodeConnectionStateChange, null));

//                put(PlatformConstants.CodecTypes.channelEvent, new CodecPair<>(self::writeChannelEvent, null));
//                put(PlatformConstants.CodecTypes.channelState, new CodecPair<>(self::writeChannelState, null));
                put(PlatformConstants.CodecTypes.channelStateChange, new CodecPair<>(self::writeChannelStateChange, null));
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

    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
        Byte type = null;
        if(value instanceof ErrorInfo){
            type = PlatformConstants.CodecTypes.errorInfo;
        }else if(value instanceof ConnectionEvent){
            type = PlatformConstants.CodecTypes.connectionEvent;
        }else if(value instanceof ConnectionState){
            type = PlatformConstants.CodecTypes.connectionState;
        }else if(value instanceof ConnectionStateListener.ConnectionStateChange){
            type = PlatformConstants.CodecTypes.connectionStateChange;
        }else if(value instanceof ChannelEvent){
            type = PlatformConstants.CodecTypes.channelEvent;
        }else if(value instanceof ChannelState){
            type = PlatformConstants.CodecTypes.channelState;
        }else if(value instanceof ChannelStateListener.ChannelStateChange){
            type = PlatformConstants.CodecTypes.channelStateChange;
        }
        if(type!=null){
            CodecPair pair = codecMap.get(type);
            if(pair!=null) {
                stream.write(type);
                Map<String, Object> jsonMap = pair.encode(value);
                writeValue(stream, jsonMap);
                return;
            }
        }
        super.writeValue(stream, value);
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
            return ((Integer)object).longValue();
        }
        return (Long)object; // will java.lang.ClassCastException if object is not a Long
    }

    private AblyFlutterMessage readAblyFlutterMessage(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final Long handle = readValueAsLong(jsonMap.get("registrationHandle"));
        Object messageType = jsonMap.get("type");
        final Integer type = (messageType==null)?null:Integer.parseInt(messageType.toString());
        Object message = jsonMap.get("message");
        if(type!=null){
            message = codecMap.get((byte)(int)type).decode((Map<String, Object>)message);
        }
        return new AblyFlutterMessage<>(handle, message);
    }

    private ClientOptions readClientOptions(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final ClientOptions o = new ClientOptions();

        // AuthOptions (super class of ClientOptions)
        readValueFromJson(jsonMap, "authUrl", v -> o.authUrl = (String)v);
        readValueFromJson(jsonMap, "authMethod", v -> o.authMethod = (String)v);
        readValueFromJson(jsonMap, "key", v -> o.key = (String)v);
        readValueFromJson(jsonMap, "tokenDetails", v -> o.tokenDetails = readTokenDetails((Map<String, Object>)v));
        readValueFromJson(jsonMap, "authHeaders", v -> o.authHeaders = (Param[])v);
        readValueFromJson(jsonMap, "authParams", v -> o.authParams = (Param[])v);
        readValueFromJson(jsonMap, "queryTime", v -> o.queryTime = (Boolean)v);
//        readValueFromJson(buffer); // o.useAuthToken

        // ClientOptions
        readValueFromJson(jsonMap, "clientId", v -> o.clientId = (String)v);
        readValueFromJson(jsonMap, "logLevel", v -> o.logLevel = (Integer)v);
        readValueFromJson(jsonMap, "tls", v -> o.tls = (Boolean)v);
        readValueFromJson(jsonMap, "restHost", v -> o.restHost = (String)v);
        readValueFromJson(jsonMap, "realtimeHost", v -> o.realtimeHost = (String)v);
        readValueFromJson(jsonMap, "port", v -> o.port = (Integer)v);
        readValueFromJson(jsonMap, "tlsPort", v -> o.tlsPort = (Integer)v);
        readValueFromJson(jsonMap, "autoConnect", v -> o.autoConnect = (Boolean)v);
        readValueFromJson(jsonMap, "useBinaryProtocol", v -> o.useBinaryProtocol = (Boolean)v);
        readValueFromJson(jsonMap, "queueMessages", v -> o.queueMessages = (Boolean)v);
        readValueFromJson(jsonMap, "echoMessages", v -> o.echoMessages = (Boolean)v);
        readValueFromJson(jsonMap, "recover", v -> o.recover = (String)v);
        readValueFromJson(jsonMap, "environment", v -> o.environment = (String)v);
        readValueFromJson(jsonMap, "idempotentRestPublishing", v -> o.idempotentRestPublishing = (Boolean)v);
        readValueFromJson(jsonMap, "httpOpenTimeout", v -> o.httpOpenTimeout = (Integer)v);
        readValueFromJson(jsonMap, "httpRequestTimeout", v -> o.httpRequestTimeout = (Integer)v);
        readValueFromJson(jsonMap, "httpMaxRetryCount", v -> o.httpMaxRetryCount = (Integer)v);
        readValueFromJson(jsonMap, "realtimeRequestTimeout", v -> o.realtimeRequestTimeout = (Long)v);
        readValueFromJson(jsonMap, "fallbackHosts", v -> o.fallbackHosts = (String[])v);
        readValueFromJson(jsonMap, "fallbackHostsUseDefault", v -> o.fallbackHostsUseDefault = (Boolean)v);
        readValueFromJson(jsonMap, "fallbackRetryTimeout", v -> o.fallbackRetryTimeout = (Long)v);
        readValueFromJson(jsonMap, "defaultTokenParams", v -> o.defaultTokenParams = readTokenParams((Map<String, Object>)v));
        readValueFromJson(jsonMap, "channelRetryTimeout", v -> o.channelRetryTimeout = (Integer)v);
        readValueFromJson(jsonMap, "transportParams", v -> o.transportParams = (Param[])v);
        return o;
    }

    private TokenDetails readTokenDetails(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final TokenDetails o = new TokenDetails();
        readValueFromJson(jsonMap, "token", v -> o.token = (String)v);
        readValueFromJson(jsonMap, "expires", v -> o.expires = (int)v);
        readValueFromJson(jsonMap, "issued", v -> o.issued = (int)v);
        readValueFromJson(jsonMap, "capability", v -> o.capability = (String)v);
        readValueFromJson(jsonMap, "clientId", v -> o.clientId = (String)v);

        return o;
    }

    private Auth.TokenParams readTokenParams(Map<String, Object> jsonMap) {
        if(jsonMap==null) return null;
        final Auth.TokenParams o = new Auth.TokenParams();
        readValueFromJson(jsonMap, "capability", v -> o.capability = (String)v);
        readValueFromJson(jsonMap, "clientId", v -> o.clientId = (String)v);
        readValueFromJson(jsonMap, "timestamp", v -> o.timestamp = (int)v);
        readValueFromJson(jsonMap, "ttl", v -> o.ttl = (long)v);
        //nonce is not supported in ably-java
        return o;
    }

//===============================================================
//=====================HANDLING WRITE============================
//===============================================================

    private Map<String, Object> encodeErrorInfo(ErrorInfo c){
        if(c==null) return null;
        HashMap<String, Object> jsonMap = new HashMap<>();
        writeValueToJson(jsonMap, "code", c.code);
        writeValueToJson(jsonMap, "message", c.message);
        writeValueToJson(jsonMap, "statusCode", c.statusCode);
        writeValueToJson(jsonMap, "href", c.href);
        //requestId and cause - not available in ably-java
        return jsonMap;
    }

    private Map<String, Object> encodeConnectionStateChange(ConnectionStateListener.ConnectionStateChange c){
        if(c==null) return null;
        HashMap<String, Object> jsonMap = new HashMap<>();
        writeEnumToJson(jsonMap, "current", c.current);
        writeEnumToJson(jsonMap, "previous", c.previous);
        writeEnumToJson(jsonMap, "event", c.event);
        writeValueToJson(jsonMap, "retryIn", c.retryIn);
        writeValueToJson(jsonMap, "reason", encodeErrorInfo(c.reason));
        return jsonMap;
    }

    private Map<String, Object> writeChannelStateChange(ChannelStateListener.ChannelStateChange c){
        if(c==null) return null;
        HashMap<String, Object> jsonMap = new HashMap<>();
        writeEnumToJson(jsonMap, "current", c.current);
        writeEnumToJson(jsonMap, "previous", c.previous);
        writeEnumToJson(jsonMap, "event", c.event);
        writeValueToJson(jsonMap, "resumed", c.resumed);
        writeValueToJson(jsonMap, "reason", encodeErrorInfo(c.reason));
        return jsonMap;
    }


}
