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
    private AblyLibrary(){}

    static synchronized AblyLibrary getInstance() {
        if (null == _instance) {
            _instance = new AblyLibrary();
        }
        return _instance;
    }

    //    using LongSparseArray as suggested by Studio
    //    and as per this answer https://stackoverflow.com/a/31413003
    private final LongSparseArray<AblyRest> _restInstances = new LongSparseArray<>();
    private final LongSparseArray<AblyRealtime> _realtimeInstances = new LongSparseArray<>();

    long createRealtime(final ClientOptions clientOptions) throws AblyException {
        final AblyRealtime realtime = new AblyRealtime(clientOptions);
        _realtimeInstances.put(_nextHandle, realtime);
        return _nextHandle++;
    }

    long createRest(final ClientOptions clientOptions) throws AblyException {
        final AblyRest rest = new AblyRest(clientOptions);
        _restInstances.put(_nextHandle, rest);
        return _nextHandle++;
    }

    AblyRealtime getRealtime(final long handle) {
        return _realtimeInstances.get(handle);
    }

    AblyRest getRest(final long handle){
        return _restInstances.get(handle);
    }

    void dispose() {
        for(int i=0; i<_realtimeInstances.size(); i++){
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
