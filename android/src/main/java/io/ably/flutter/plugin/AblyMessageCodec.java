package io.ably.flutter.plugin;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
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
import io.ably.lib.types.Param;
import io.ably.lib.types.ErrorInfo;
import io.flutter.plugin.common.StandardMessageCodec;

public class AblyMessageCodec extends StandardMessageCodec {
    private static final byte _valueClientOptions = (byte)128;
    private static final byte _valueTokenDetails = (byte)129;
    private static final byte _errorInfo = (byte)144;

    // Events
    private static final byte _connectionEvent = (byte)201;
    private static final byte _connectionState = (byte)202;
    private static final byte _connectionStateChange = (byte)203;
    private static final byte _channelEvent = (byte)204;
    private static final byte _channelState = (byte)205;
    private static final byte _channelStateChange = (byte)206;

    private static final byte _valueAblyMessage = (byte)255;

    @Override
    protected Object readValueOfType(final byte type, final ByteBuffer buffer) {
        switch (type) {
            case _valueClientOptions:
                return readClientOptions(buffer);

            case _valueTokenDetails:
                return readTokenDetails(buffer);

            case _valueAblyMessage:
                return readAblyFlutterMessage(buffer);
        }
        return super.readValueOfType(type, buffer);
    }

    private void readValue(final ByteBuffer buffer, final Consumer<Object> consumer) {
        final Object object = readValue(buffer);
        if (null != object) {
            consumer.accept(object);
        }
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

    private Object readClientOptions(final ByteBuffer buffer) {
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

    private Object readTokenDetails(final ByteBuffer buffer) {
        final TokenDetails o = new TokenDetails();

        readValue(buffer, v -> o.token = (String)v);
        readValue(buffer, v -> o.expires = (int)v);
        readValue(buffer, v -> o.issued = (int)v);
        readValue(buffer, v -> o.capability = (String)v);
        readValue(buffer, v -> o.clientId = (String)v);

        return o;
    }


    //HANDLING WRITE

    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
        if(value instanceof ErrorInfo){
            writeErrorInfo(stream, (ErrorInfo) value);
            return;
        }else if(value instanceof ConnectionEvent){
            writeEnum(stream, _connectionEvent, (ConnectionEvent) value);
            return;
        }else if(value instanceof ConnectionState){
            writeEnum(stream, _connectionState, (ConnectionState) value);
            return;
        }else if(value instanceof ConnectionStateListener.ConnectionStateChange){
            writeConnectionStateChange(stream, (ConnectionStateListener.ConnectionStateChange) value);
            return;
        }else if(value instanceof ChannelEvent){
            writeEnum(stream, _channelEvent, (ChannelEvent) value);
            return;
        }else if(value instanceof ChannelState){
            writeEnum(stream, _channelState, (ChannelState) value);
            return;
        }else if(value instanceof ChannelStateListener.ChannelStateChange){
            writeChannelStateChange(stream, (ChannelStateListener.ChannelStateChange) value);
            return;
        }
        super.writeValue(stream, value);
    }

    private void writeErrorInfo(ByteArrayOutputStream stream, ErrorInfo e){
        stream.write(_errorInfo);
        writeValue(stream, e.code);
        writeValue(stream, e.message);
        writeValue(stream, e.statusCode);
        writeValue(stream, e.href);
        writeValue(stream, null); //requestId - not available in ably-java
        writeValue(stream, null); //cause - not available in ably-java
    }

    private void writeConnectionStateChange(ByteArrayOutputStream stream, ConnectionStateListener.ConnectionStateChange c){
        stream.write(_connectionStateChange);
        writeValue(stream, c.current);
        writeValue(stream, c.previous);
        writeValue(stream, c.event);
        writeValue(stream, c.retryIn);
        writeValue(stream, c.reason);
    }

    private void writeChannelStateChange(ByteArrayOutputStream stream, ChannelStateListener.ChannelStateChange c){
        stream.write(_channelStateChange);
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
