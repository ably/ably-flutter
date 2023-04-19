package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.push.PushActivationReceiver.PUSH_ACTIVATE_ACTION;
import static io.ably.flutter.plugin.push.PushActivationReceiver.PUSH_DEACTIVATE_ACTION;
import static io.ably.flutter.plugin.push.PushActivationReceiver.PUSH_UPDATE_FAILED_ACTION;

import android.content.Context;

import androidx.annotation.Nullable;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.util.Log;
import io.flutter.plugin.common.MethodChannel;

public class PushActivationEventHandlers {
    private static final String TAG = PushActivationEventHandlers.class.getName();

    private static PushActivationEventHandlers instance;

    private MethodChannel.Result resultForActivate;
    private MethodChannel.Result resultForDeactivate;

    private final PushActivationReceiver pushActivationReceiver;
    private final MethodChannel methodChannel;
    private final Context context;

    private PushActivationEventHandlers(Context context, MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
        this.context = context;
        pushActivationReceiver = new PushActivationReceiver();
    }

    public static synchronized void instantiate(Context context, MethodChannel methodChannel) {
        if (instance == null) {
            instance = new PushActivationEventHandlers(context, methodChannel);
        }
    }

    public static PushActivationEventHandlers getInstance() {
        return instance;
    }

    public void registerReceiver() {
        pushActivationReceiver.register(context, this::activationResultReceived);
    }

    public void unregisterReceiver() {
        pushActivationReceiver.unregister(context);
    }

    public void setResultForActivate(MethodChannel.Result result) {
        resultForActivate = result;
    }

    public void setResultForDeactivate(MethodChannel.Result result) {
        resultForDeactivate = result;
    }

    private void activationResultReceived(String action, ErrorInfo errorInfo) {
        switch (action) {
            case PUSH_ACTIVATE_ACTION:
                methodChannel.invokeMethod(PlatformConstants.PlatformMethod.pushOnActivate, errorInfo);
                if (resultForActivate != null) {
                    Log.d(TAG, "resultForActivate received on PUSH_ACTIVATE_ACTION.");
                    returnMethodCallResult(resultForActivate, errorInfo);
                } else {
                    Log.e(TAG, "resultForActivate is null on PUSH_ACTIVATE_ACTION.");
                }
                break;
            case PUSH_DEACTIVATE_ACTION:
                methodChannel.invokeMethod(PlatformConstants.PlatformMethod.pushOnDeactivate, errorInfo);
                if (resultForDeactivate != null) {
                    Log.d(TAG, "resultForDeactivate received on PUSH_DEACTIVATE_ACTION.");
                    returnMethodCallResult(resultForDeactivate, errorInfo);
                } else {
                    Log.e(TAG, "resultForDeactivate is null on PUSH_DEACTIVATE_ACTION.");
                }
                break;
            case PUSH_UPDATE_FAILED_ACTION:
                methodChannel.invokeMethod(PlatformConstants.PlatformMethod.pushOnUpdateFailed, errorInfo);
                break;
            default:
                Log.e(TAG, String.format("Received unknown intent action from receiver: %s", action));
                break;
        }

    }

    private void returnMethodCallResult(MethodChannel.Result result, @Nullable ErrorInfo errorInfo) {
        if (errorInfo != null) {
            result.error(String.valueOf(errorInfo.code), errorInfo.message, errorInfo);
        } else {
            result.success(null);
        }
    }

}
