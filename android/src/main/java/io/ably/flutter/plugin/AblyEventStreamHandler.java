package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.realtime.ConnectionStateListener;
import io.flutter.plugin.common.EventChannel;


/**
 * Dart side can listen to Event Streams by pushing data to eventSink available in onListen method.
 * Event listening can be cancelled when stream subscription is cancelled on dart side
 *
 * ref: https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.StreamHandler.html
 * */
public class AblyEventStreamHandler implements EventChannel.StreamHandler {

    /**
     * Creating an ablyLibrary instance.
     * As ablyLibrary is a singleton,
     * all ably object instance will be accessible
     * */
    private final AblyLibrary ablyLibrary = AblyLibrary.getInstance();

    /**
     * Refer to the comments on AblyMethodCallHandler.MethodResultWrapper
     * on why this customized EventSink is required
     * */
    private static class MainThreadEventSink implements EventChannel.EventSink {
        private EventChannel.EventSink eventSink;
        private Handler handler;

        MainThreadEventSink(EventChannel.EventSink eventSink) {
            this.eventSink = eventSink;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object o) {
            handler.post(() -> eventSink.success(o));   //lambda for new Runnable
        }

        @Override
        public void error(final String s, final String s1, final Object o) {
            handler.post(() -> eventSink.error(s, s1, o));
        }

        @Override
        public void endOfStream() {}
    }

    // Listeners
    private PluginConnectionStateListener connectionStateListener;

    private class Listener{
        EventChannel.EventSink eventSink;
        Listener(EventChannel.EventSink eventSink){ this.eventSink = eventSink; }
    }

    private class PluginConnectionStateListener extends Listener implements ConnectionStateListener {

        PluginConnectionStateListener(EventChannel.EventSink eventSink){
            super(eventSink);
        }

        public void onConnectionStateChanged(ConnectionStateChange stateChange){
            eventSink.success(stateChange);
        }

    }

    // Casting stream creation arguments from `Object` into `AblyMessage`
    private AblyFlutterMessage<String> getMessage(Object message){
        return ((AblyFlutterMessage<AblyFlutterMessage<String>>)message).message;
    }

    @Override
    public void onListen(Object object, EventChannel.EventSink uiThreadEventSink) {
        MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
        AblyFlutterMessage<String> message = getMessage(object);
        String eventName = message.message;
        switch(eventName) {
            case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                connectionStateListener = new PluginConnectionStateListener(eventSink);
                ablyLibrary.getRealtime(message.handle).connection.on(connectionStateListener);
                return;
            default:
                eventSink.error("unhandled event", null, null);
        }
    }

    @Override
    public void onCancel(Object object) {
        if(object==null){
            System.out.println("Cannot process null input on cancel");
            return;
        }
        AblyFlutterMessage<String> message = getMessage(object);
        String eventName = message.message;
        switch (eventName) {
            case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                ablyLibrary.getRealtime(message.handle).connection.off(connectionStateListener);
        }
    }

}
