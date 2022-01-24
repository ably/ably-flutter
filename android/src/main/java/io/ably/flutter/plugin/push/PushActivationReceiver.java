package io.ably.flutter.plugin.push;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.ably.lib.types.ErrorInfo;
import io.ably.lib.util.IntentUtils;

class PushActivationReceiver extends android.content.BroadcastReceiver {
    static final String PUSH_ACTIVATE_ACTION = "io.ably.broadcast.PUSH_ACTIVATE";
    static final String PUSH_DEACTIVATE_ACTION = "io.ably.broadcast.PUSH_DEACTIVATE";
    static final String PUSH_UPDATE_FAILED_ACTION = "io.ably.broadcast.PUSH_UPDATE_FAILED";

    interface Callback {
        void onReceive(String action, ErrorInfo errorInfo);
    }

    private Callback callback;

    public void register(@NonNull Context context, @NonNull Callback callback) {
        IntentFilter filter = new IntentFilter();
        filter.addAction(PUSH_ACTIVATE_ACTION);
        filter.addAction(PUSH_DEACTIVATE_ACTION);
        filter.addAction(PUSH_UPDATE_FAILED_ACTION);
        this.callback = callback;
        LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    public void unregister(Context context) {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(this);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        @Nullable ErrorInfo errorInfo = IntentUtils.getErrorInfo(intent);
        if (callback != null) {
            callback.onReceive(action, errorInfo);
        }
    }
}
