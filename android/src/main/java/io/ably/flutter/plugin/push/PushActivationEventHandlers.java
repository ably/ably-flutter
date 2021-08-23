package io.ably.flutter.plugin.push;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.util.IntentUtils;
import io.flutter.plugin.common.MethodChannel;

public class PushActivationEventHandlers {
  private static final String TAG = PushActivationEventHandlers.class.getName();
  private static final String PUSH_ACTIVATE_ACTION = "io.ably.broadcast.PUSH_ACTIVATE";
  private static final String PUSH_DEACTIVATE_ACTION = "io.ably.broadcast.PUSH_DEACTIVATE";
  private static final String PUSH_UPDATE_FAILED_ACTION = "io.ably.broadcast.PUSH_UPDATE_FAILED";

  static PushActivationEventHandlers instance;
  final private BroadcastReceiver broadcastReceiver;
  final private MethodChannel methodChannel;
  private MethodChannel.Result resultForActivate;
  private MethodChannel.Result resultForDeactivate;

  public static void instantiate(Context context, MethodChannel methodChannel) {
    if (instance == null) {
      instance = new PushActivationEventHandlers(context, methodChannel);
    }
  }

  public static void setResultForActivate(MethodChannel.Result result) {
    instance.resultForActivate = result;
  }

  public static void setResultForDeactivate(MethodChannel.Result result) {
    instance.resultForDeactivate = result;
  }

  public PushActivationEventHandlers(Context context, MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
    broadcastReceiver = new BroadcastReceiver(context);
  }

  class BroadcastReceiver extends android.content.BroadcastReceiver {
    BroadcastReceiver(Context context) {
      register(context);
    }

    private void register(Context context) {
      IntentFilter filter = new IntentFilter();
      filter.addAction(PUSH_ACTIVATE_ACTION);
      filter.addAction(PUSH_DEACTIVATE_ACTION);
      filter.addAction(PUSH_UPDATE_FAILED_ACTION);
      LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      @Nullable ErrorInfo errorInfo = IntentUtils.getErrorInfo(intent);
      switch (action) {
        case PUSH_ACTIVATE_ACTION:
          callCallbackOnDartSide(PlatformConstants.PlatformMethod.pushOnActivate, errorInfo);
          returnMethodCallResult(resultForActivate, errorInfo);
          resultForActivate = null;
          break;
        case PUSH_DEACTIVATE_ACTION:
          callCallbackOnDartSide(PlatformConstants.PlatformMethod.pushOnDeactivate, errorInfo);
          returnMethodCallResult(resultForDeactivate, errorInfo);
          resultForDeactivate = null;
          break;
        case PUSH_UPDATE_FAILED_ACTION:
          callCallbackOnDartSide(PlatformConstants.PlatformMethod.pushOnUpdateFailed, errorInfo);
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

    private void callCallbackOnDartSide(String platformMethod, @Nullable ErrorInfo errorInfo) {
      methodChannel.invokeMethod(platformMethod, errorInfo);
    }
  }
}
