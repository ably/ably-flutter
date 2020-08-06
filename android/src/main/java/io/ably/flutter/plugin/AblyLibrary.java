package io.ably.flutter.plugin;

import android.util.LongSparseArray;

import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.rest.AblyRest;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;

class AblyLibrary {

    private static AblyLibrary _instance;
    private long _nextHandle = 1;

    // privatizing default constructor to enforce usage of getInstance
    private AblyLibrary() {
    }

    static synchronized AblyLibrary getInstance() {
        if (null == _instance) {
            _instance = new AblyLibrary();
        }
        return _instance;
    }

    //    using LongSparseArray as suggested by Studio
    //    and as per this answer https://stackoverflow.com/a/31413003
    private final LongSparseArray<AblyRest> _restInstances = new LongSparseArray<>();
    private final LongSparseArray<Object> _restTokens = new LongSparseArray<>();

    private final LongSparseArray<AblyRealtime> _realtimeInstances = new LongSparseArray<>();
    private final LongSparseArray<Object> _realtimeTokens = new LongSparseArray<>();

    long getCurrentHandle(){
        return _nextHandle;
    }

    long createRest(final ClientOptions clientOptions) throws AblyException {
        final AblyRest rest = new AblyRest(clientOptions);
        _restInstances.put(_nextHandle, rest);
        return _nextHandle++;
    }

    AblyRest getRest(final long handle){
        return _restInstances.get(handle);
    }

    void setRestToken(long handle, Object tokenDetails){
        _restTokens.put(handle, tokenDetails);
    }

    Object getRestToken(long handle){
        Object token = _restTokens.get(handle);
        _restTokens.remove(handle);
        return token;
    }


    long createRealtime(final ClientOptions clientOptions) throws AblyException {
        final AblyRealtime realtime = new AblyRealtime(clientOptions);
        _realtimeInstances.put(_nextHandle, realtime);
        return _nextHandle++;
    }

    AblyRealtime getRealtime(final long handle) {
        return _realtimeInstances.get(handle);
    }

    void setRealtimeToken(long handle, Object tokenDetails){
        _realtimeTokens.put(handle, tokenDetails);
    }

    Object getRealtimeToken(long handle){
        Object token = _realtimeTokens.get(handle);
        _realtimeTokens.remove(handle);
        return token;
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
