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
 * Stores instances created by Ably Java, by handle. This handle is passed to the Dart side
 * and keeps track of the instance on the Java side. When a platform method is called on the
 * Dart side, a string representing the method, and the handle representing the instance the method
 * is being called on is passed.
 *
 * For example, when @{Realtime#connect} is called on the dart side, we need to know which Realtime
 * client this method is being called on, as there might be more than one. We can get the realtime
 * client by calling @{AblyInstanceStore#getRealtime(final long handle)}.
 */
class AblyInstanceStore {
    private static final AblyInstanceStore instance = new AblyInstanceStore();

    // Android Studio warns against using HashMap with integer keys, and
    // suggests using LongSparseArray. More information at https://stackoverflow.com/a/31413003
    // It may be simpler to go back to HashMap because this is an unmeasured memory optimisation.
    // > the Hashmap and the SparseArray are very similar for data structure sizes under 1,000
    private final LongSparseArray<AblyRest> restInstances = new LongSparseArray<>();
    private final LongSparseArray<AblyRealtime> realtimeInstances = new LongSparseArray<>();
    private final LongSparseArray<AsyncPaginatedResult<Object>> paginatedResults = new LongSparseArray<>();
    private final HandleSequence handleSequence = new HandleSequence();

    static synchronized AblyInstanceStore getInstance() {
        return instance;
    }

    /**
     * A reserved client handle. Safe to be used from any thread.
     *
     * Instances support the creation of a single Rest or Realtime instance, where only one of the
     * create methods may be called and it may only be called once.
     */
    interface ClientHandle {
        /**
         * Get the handle that will be used to store this client when it is created, or the handle
         * that was used to store it when it was created.
         * This property may be read at any time, from any thread.
         */
        long getHandle();

        /**
         * Create an {@link AblyRest} instance and store it using this handle.
         * @param clientOptions The Ably client options for the new Rest instance.
         * @param applicationContext The Android application context to supply to the new Rest
         * instance using its {@link AblyRest#setAndroidContext(Context)} method.
         * @return The handle used to store the instance. Same as {@link #getHandle()}.
         * @throws IllegalStateException If this handle has already been used to create a Rest or
         * Realtime instance.
         * @throws AblyException If the {@link AblyRest} instance creation failed.
         */
        long createRest(ClientOptions clientOptions, Context applicationContext) throws AblyException;

        /**
         * Create an {@link AblyRealtime} instance and store it using this handle.
         * @param clientOptions The Ably client options for the new Realtime instance.
         * @param applicationContext The Android application context to supply to the new Realtime
         * instance using its {@link AblyRealtime#setAndroidContext(Context)} method.
         * @return The handle used to store the instance. Same as {@link #getHandle()}.
         * @throws IllegalStateException If this handle has already been used to create a Rest or
         * Realtime instance.
         * @throws AblyException If the {@link AblyRealtime} instance creation failed.
         */
        long createRealtime(ClientOptions clientOptions, Context applicationContext) throws AblyException;
    }

    private class ReservedClientHandle implements ClientHandle {
        private final long handle;
        private volatile boolean used = false;

        ReservedClientHandle(final long handle) {
            this.handle = handle;
        }

        @Override
        public long getHandle() {
            return handle;
        }

        @Override
        public synchronized long createRest(final ClientOptions clientOptions, final Context applicationContext) throws AblyException {
            final long handle = use();
            final AblyRest rest = new AblyRest(clientOptions);
            rest.setAndroidContext(applicationContext);
            restInstances.put(handle, rest);
            return handle;
        }

        @Override
        public synchronized long createRealtime(final ClientOptions clientOptions, final Context applicationContext) throws AblyException {
            final long handle = use();
            final AblyRealtime realtime = new AblyRealtime(clientOptions);
            realtime.setAndroidContext(applicationContext);
            realtimeInstances.put(handle, realtime);
            return handle;
        }

        synchronized long use() {
            if (used) {
                throw new IllegalStateException("Reserved handle has already been used to create a client instance (handle=" + handle + ").");
            }
            return handle;
        }
    }

    private static class HandleSequence {
        private volatile long nextHandle = 1;

        synchronized long next() {
            return nextHandle++;
        }
    }

    synchronized ClientHandle reserveClientHandle() {
        return new ReservedClientHandle(handleSequence.next());
    }

    synchronized AblyRest getRest(final long handle) {
        return restInstances.get(handle);
    }

    synchronized AblyRealtime getRealtime(final long handle) {
        return realtimeInstances.get(handle);
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
    synchronized AblyBase getAblyClient(final long handle) {
        AblyRealtime realtime = getRealtime(handle);
        return (realtime != null) ? realtime : getRest(handle);
    }
    
    synchronized Push getPush(final long handle) {
        AblyRealtime realtime = getRealtime(handle);
        return (realtime != null) ? realtime.push : getRest(handle).push;
    }
    
    synchronized PushChannel getPushChannel(final long handle, final String channelName) {
        return getAblyClient(handle)
                .channels
                .get(channelName).push;
    }

    synchronized long setPaginatedResult(AsyncPaginatedResult result, Integer handle) {
        long longHandle;
        if (handle == null) {
            longHandle = handleSequence.next();
        } else {
            longHandle = handle.longValue();
        }
        paginatedResults.put(longHandle, result);
        return longHandle;
    }

    synchronized AsyncPaginatedResult<Object> getPaginatedResult(long handle) {
        return paginatedResults.get(handle);
    }

    synchronized void reset() {
        for (int i = 0; i < realtimeInstances.size(); i++) {
            long key = realtimeInstances.keyAt(i);
            AblyRealtime r = realtimeInstances.get(key);
            try {
                r.close();
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        realtimeInstances.clear();
        restInstances.clear();
        paginatedResults.clear();
    }
}
