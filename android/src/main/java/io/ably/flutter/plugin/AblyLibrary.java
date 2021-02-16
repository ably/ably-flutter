package io.ably.flutter.plugin;

import android.util.LongSparseArray;

import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.rest.AblyRest;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.AsyncPaginatedResult;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.PaginatedResult;

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
    private final LongSparseArray<Object> _restTokenData = new LongSparseArray<>();

    private final LongSparseArray<AblyRealtime> _realtimeInstances = new LongSparseArray<>();
    private final LongSparseArray<Object> _realtimeTokenData = new LongSparseArray<>();

    private final LongSparseArray<AsyncPaginatedResult<Object>> _paginatedResults = new LongSparseArray<>();

    long getCurrentHandle() {
        return _nextHandle;
    }

    long createRest(final ClientOptions clientOptions) throws AblyException {
        final AblyRest rest = new AblyRest(clientOptions);
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
        _realtimeInstances.put(_nextHandle, realtime);
        return _nextHandle++;
    }

    AblyRealtime getRealtime(final long handle) {
        return _realtimeInstances.get(handle);
    }

    void setRealtimeToken(long handle, Object tokenDetails) {
        _realtimeTokenData.put(handle, tokenDetails);
    }

    Object getRealtimeToken(long handle) {
        Object token = _realtimeTokenData.get(handle);
        _realtimeTokenData.remove(handle);
        return token;
    }

    long setPaginatedResult(AsyncPaginatedResult result, Integer handle){
        long longHandle;
        if(handle==null){
            longHandle = _nextHandle++;
        }else {
            longHandle = handle.longValue();
        }
        _paginatedResults.put(longHandle, result);
        return longHandle;
    }

    AsyncPaginatedResult<Object> getPaginatedResult(long handle){
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
