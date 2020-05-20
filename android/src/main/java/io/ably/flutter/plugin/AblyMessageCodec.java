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

//    @FunctionalInterface
    interface CodecEncoder<T>{ void encode(ByteArrayOutputStream stream, T value); }
//    @FunctionalInterface
    interface CodecDecoder<T>{ T decode(ByteBuffer buffer); }
    class CodecPair<T>{

        final CodecEncoder<T> encoder;
        final CodecDecoder<T> decoder;
        CodecPair(CodecEncoder<T> encoder, CodecDecoder<T> decoder){
            this.encoder = encoder;
            this.decoder = decoder;
        }

        void encode(final ByteArrayOutputStream stream, final Object value){
            if(this.encoder==null){
                System.out.println("Codec encoder not defined");
                return;
            }
            this.encoder.encode(stream, (T)value);
        }

        T decode(ByteBuffer buffer){
            if(this.decoder==null){
                System.out.println("Codec decoder not defined");
                return null;
            }
            return this.decoder.decode(buffer);
        }
    }

    private Map<Byte, CodecPair> codecMap;

    AblyMessageCodec(){
        AblyMessageCodec self = this;
        codecMap = new HashMap<Byte, CodecPair>(){
            {
                put(PlatformConstants.CodecTypes.ablyMessage, new CodecPair<>(null, self::readAblyFlutterMessage));
                put(PlatformConstants.CodecTypes.clientOptions, new CodecPair<>(null, self::readClientOptions));
                put(PlatformConstants.CodecTypes.tokenDetails, new CodecPair<>(null, self::readTokenDetails));
                put(PlatformConstants.CodecTypes.errorInfo, new CodecPair<>(self::writeErrorInfo, null));

                put(PlatformConstants.CodecTypes.connectionEvent, new CodecPair<>(self::writeConnectionEvent, null));
                put(PlatformConstants.CodecTypes.connectionState, new CodecPair<>(self::writeConnectionState, null));
                put(PlatformConstants.CodecTypes.connectionStateChange, new CodecPair<>(self::writeConnectionStateChange, null));

                put(PlatformConstants.CodecTypes.channelEvent, new CodecPair<>(self::writeChannelEvent, null));
                put(PlatformConstants.CodecTypes.channelState, new CodecPair<>(self::writeChannelState, null));
                put(PlatformConstants.CodecTypes.channelStateChange, new CodecPair<>(self::writeChannelStateChange, null));
            }
        };
    }

    @Override
    protected Object readValueOfType(final byte type, final ByteBuffer buffer) {
        CodecPair pair = codecMap.get(type);
        if(pair!=null){
            return pair.decode(buffer);
        }
        return super.readValueOfType(type, buffer);
    }

    private void readValue(final ByteBuffer buffer, final Consumer<Object> consumer) {
        final Object object = readValue(buffer);
        if (null != object) {
            consumer.accept(object);
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
                pair.encode(stream, value);
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
    private Long readValueAsLong(final ByteBuffer buffer) {
        final Object object = readValue(buffer);
        if (null == object) {
            return null;
        }
        if (object instanceof Integer) {
            return ((Integer)object).longValue();
        }
        return (Long)object; // will java.lang.ClassCastException if object is not a Long
    }

    private AblyFlutterMessage readAblyFlutterMessage(final ByteBuffer buffer) {
        final Long handle = readValueAsLong(buffer);
        final Object message = readValue(buffer);
        return new AblyFlutterMessage<>(handle, message);
    }

    private ClientOptions readClientOptions(final ByteBuffer buffer) {
        final ClientOptions o = new ClientOptions();

        // AuthOptions (super class of ClientOptions)
        readValue(buffer, v -> o.authUrl = (String)v);
        readValue(buffer, v -> o.authMethod = (String)v);
        readValue(buffer, v -> o.key = (String)v);
        readValue(buffer, v -> o.tokenDetails = (Auth.TokenDetails)v);
        readValue(buffer, v -> o.authHeaders = (Param[])v);
        readValue(buffer, v -> o.authParams = (Param[])v);
        readValue(buffer, v -> o.queryTime = (Boolean)v);
        readValue(buffer); // o.useAuthToken

        // ClientOptions
        readValue(buffer, v -> o.clientId = (String)v);
        readValue(buffer, v -> o.logLevel = (Integer)v);
        readValue(buffer, v -> o.tls = (Boolean)v);
        readValue(buffer, v -> o.restHost = (String)v);
        readValue(buffer, v -> o.realtimeHost = (String)v);
        readValue(buffer, v -> o.port = (Integer)v);
        readValue(buffer, v -> o.tlsPort = (Integer)v);
        readValue(buffer, v -> o.autoConnect = (Boolean)v);
        readValue(buffer, v -> o.useBinaryProtocol = (Boolean)v);
        readValue(buffer, v -> o.queueMessages = (Boolean)v);
        readValue(buffer, v -> o.echoMessages = (Boolean)v);
        readValue(buffer, v -> o.recover = (String)v);
        readValue(buffer, v -> o.environment = (String)v);
        readValue(buffer, v -> o.idempotentRestPublishing = (Boolean)v);
        readValue(buffer, v -> o.httpOpenTimeout = (Integer)v);
        readValue(buffer, v -> o.httpRequestTimeout = (Integer)v);
        readValue(buffer, v -> o.httpMaxRetryCount = (Integer)v);
        readValue(buffer, v -> o.realtimeRequestTimeout = (Long)v);
        readValue(buffer, v -> o.fallbackHosts = (String[])v);
        readValue(buffer, v -> o.fallbackHostsUseDefault = (Boolean)v);
        readValue(buffer, v -> o.fallbackRetryTimeout = (Long)v);
        readValue(buffer, v -> o.defaultTokenParams = (Auth.TokenParams) v);
        readValue(buffer, v -> o.channelRetryTimeout = (Integer)v);
        readValue(buffer, v -> o.transportParams = (Param[])v);
        return o;
    }

    private TokenDetails readTokenDetails(final ByteBuffer buffer) {
        final TokenDetails o = new TokenDetails();

        readValue(buffer, v -> o.token = (String)v);
        readValue(buffer, v -> o.expires = (int)v);
        readValue(buffer, v -> o.issued = (int)v);
        readValue(buffer, v -> o.capability = (String)v);
        readValue(buffer, v -> o.clientId = (String)v);

        return o;
    }


    //HANDLING WRITE
    private void writeErrorInfo(ByteArrayOutputStream stream, ErrorInfo e){
        stream.write(PlatformConstants.CodecTypes.errorInfo);
        writeValue(stream, e.code);
        writeValue(stream, e.message);
        writeValue(stream, e.statusCode);
        writeValue(stream, e.href);
        writeValue(stream, null); //requestId - not available in ably-java
        writeValue(stream, null); //cause - not available in ably-java
    }

    private void writeConnectionEvent(ByteArrayOutputStream stream, ConnectionEvent e){ writeEnum(stream, PlatformConstants.CodecTypes.connectionEvent, e); }
    private void writeConnectionState(ByteArrayOutputStream stream, ConnectionState e){ writeEnum(stream, PlatformConstants.CodecTypes.connectionState, e); }
    private void writeConnectionStateChange(ByteArrayOutputStream stream, ConnectionStateListener.ConnectionStateChange c){
        stream.write(PlatformConstants.CodecTypes.connectionStateChange);
        writeValue(stream, c.current);
        writeValue(stream, c.previous);
        writeValue(stream, c.event);
        writeValue(stream, c.retryIn);
        writeValue(stream, c.reason);
    }

    private void writeChannelEvent(ByteArrayOutputStream stream, ChannelEvent e){ writeEnum(stream, PlatformConstants.CodecTypes.channelEvent, e); }
    private void writeChannelState(ByteArrayOutputStream stream, ChannelState e){ writeEnum(stream, PlatformConstants.CodecTypes.channelState, e); }
    private void writeChannelStateChange(ByteArrayOutputStream stream, ChannelStateListener.ChannelStateChange c){
        stream.write(PlatformConstants.CodecTypes.channelStateChange);
        writeValue(stream, c.current);
        writeValue(stream, c.previous);
        writeValue(stream, c.event);
        writeValue(stream, c.resumed);
        writeValue(stream, c.reason);
    }

    private void writeEnum(ByteArrayOutputStream stream, int eventCode, Enum e){
        stream.write(eventCode);
        writeValue(stream, e.ordinal());
    }

}
