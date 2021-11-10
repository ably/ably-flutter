package io.ably.flutter.plugin;

import android.content.Context;
import android.util.LongSparseArray;

import io.ably.lib.push.Push;
import io.ably.lib.push.PushChannel;
import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.rest.AblyBase;
import io.ably.lib.rest.AblyRest;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.AsyncPaginatedResult;
import io.ably.lib.types.ClientOptions;

/**
 * Manages [Rest] and [Realtime] client instances by numeric handle. This handle is passed
 * to the Dart side to reference a platform side (Android) instance. When the user calls a method
 * on a client, the handle is used to get the instance. This allows ably-flutter to call
 * methods on the correct client.
 */
class AblyClientStore {

    private static AblyClientStore _instance;
    private long _nextHandle = 1;
    final private Context applicationContext;

    private AblyClientStore(Context applicationContext) {
        this.applicationContext = applicationContext;
    }

    static synchronized AblyClientStore getInstance(Context applicationContext) {
        if (null == _instance) {
            _instance = new AblyClientStore(applicationContext);
        }
        return _instance;
    }

    // Android Studio warns against using HashMap with integer keys, and
    // suggests using LongSparseArray. More information at https://stackoverflow.com/a/31413003
    // It may be simpler to go back to HashMap because this is an unmeasured memory optimisation.
    // > the Hashmap and the SparseArray are very similar for data structure sizes under 1,000
    private final LongSparseArray<AblyRest> _restInstances = new LongSparseArray<>();
    private final LongSparseArray<Object> _restTokenData = new LongSparseArray<>();

    private final LongSparseArray<AblyRealtime> _realtimeInstances = new LongSparseArray<>();
    private final LongSparseArray<Object> _realtimeTokenData = new LongSparseArray<>();

    private final LongSparseArray<AsyncPaginatedResult<Object>> _paginatedResults = new LongSparseArray<>();

    long getCurrentHandle() {
        return _nextHandle;
    }

    long createRest(final ClientOptions clientOptions) throws AblyException {
        final AblyRest rest = new AblyRest(clientOptions);
        rest.setAndroidContext(applicationContext);
        _restInstances.put(_nextHandle, rest);
        return _nextHandle++;
    }

    AblyRest getRest(final long handle) {
        return _restInstances.get(handle);
    }

    void setRestToken(long handle, Object tokenDetails) {
        _restTokenData.put(handle, tokenDetails);
    }

    Object getRestToken(long handle) {
        Object token = _restTokenData.get(handle);
        _restTokenData.remove(handle);
        return token;
    }


    long createRealtime(final ClientOptions clientOptions) throws AblyException {
        final AblyRealtime realtime = new AblyRealtime(clientOptions);
        realtime.setAndroidContext(applicationContext);
        _realtimeInstances.put(_nextHandle, realtime);
        return _nextHandle++;
    }

    AblyRealtime getRealtime(final long handle) {
        return _realtimeInstances.get(handle);
    }

    /**
     * Gets the Ably client (either REST or Realtime) when the interface being
     * used is the same (e.g. When using Push from AblyBase / when it does
     * not matter).
     *
     * This method relies on the fact handles are unique between all Ably clients,
     * (both rest and realtime).
     * @param handle integer handle to either AblyRealtime or AblyRest
     * @return AblyBase
     */
    AblyBase getAblyClient(final long handle) {
        AblyRealtime realtime = getRealtime(handle);
        return (realtime != null) ? realtime : getRest(handle);
    }
    
    Push getPush(final long handle) {
        AblyRealtime realtime = getRealtime(handle);
        return (realtime != null) ? realtime.push : getRest(handle).push;
    }
    
    PushChannel getPushChannel(final long handle, final String channelName) {
        return getAblyClient(handle)
                .channels
                .get(channelName).push;
    }

    void setRealtimeToken(long handle, Object tokenDetails) {
        _realtimeTokenData.put(handle, tokenDetails);
    }

    Object getRealtimeToken(long handle) {
        Object token = _realtimeTokenData.get(handle);
        _realtimeTokenData.remove(handle);
        return token;
    }

    long setPaginatedResult(AsyncPaginatedResult result, Integer handle) {
        long longHandle;
        if (handle == null) {
            longHandle = _nextHandle++;
        } else {
            longHandle = handle.longValue();
        }
        _paginatedResults.put(longHandle, result);
        return longHandle;
    }

    AsyncPaginatedResult<Object> getPaginatedResult(long handle) {
        return _paginatedResults.get(handle);
    }

    void dispose() {
        for (int i = 0; i < _realtimeInstances.size(); i++) {
            long key = _realtimeInstances.keyAt(i);
            AblyRealtime r = _realtimeInstances.get(key);
            try {
                r.close();
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        _realtimeInstances.clear();
        _restInstances.clear();
    }
}
