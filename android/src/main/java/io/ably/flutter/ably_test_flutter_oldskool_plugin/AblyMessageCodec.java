package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import java.nio.ByteBuffer;
import java.util.function.Consumer;

import io.ably.lib.rest.Auth;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.Param;
import io.ably.lib.types.ProxyOptions;
import io.flutter.plugin.common.StandardMessageCodec;

public class AblyMessageCodec extends StandardMessageCodec {
    private static final byte _valueClientOptions = (byte)128;

    @Override
    protected Object readValueOfType(final byte type, final ByteBuffer buffer) {
        switch (type) {
            case _valueClientOptions:
                return readClientOptions(buffer);
        }
        return super.readValueOfType(type, buffer);
    }

    private void readValue(final ByteBuffer buffer, final Consumer<Object> consumer) {
        final Object object = readValue(buffer);
        if (null != object) {
            consumer.accept(object);
        }
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
        readValue(buffer, v -> o.proxy = (ProxyOptions)v);
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
        readValue(buffer, v -> o.asyncHttpThreadpoolSize = (Integer)v);
        readValue(buffer, v -> o.pushFullWait = (Boolean)v);

        return o;
    }
}
