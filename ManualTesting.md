This document aims to list our all the inputs from how some features are tested manually
and feasible tests can be converted to automated tests. 

This document currently targets **RTN14** and **RTN15**
 sections of the [spec](https://docs.ably.io/client-lib-development-guide/features/#idl), partially

## [RTN14](https://docs.ably.io/client-lib-development-guide/features/#RTN14)

### RTN14a ✅

**Actions performed**
1. Create realtime using an Invalid API Key
2. attach `connectionStateChange` listeners and `channelStateChange` listeners
3. connect to realtime instance using `realtime.connect()`

Logs
```js
2020-07-31 17:31:29.424647 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 17:31:30.115235 : ConnectionStateChange event: ConnectionEvent.failed
                             Reason: ErrorInfo message=Invalid key in request: asdf_d231:fawefsd-afwesd. (See https://help.ably.io/error/40005 for help.) code=40005 statusCode=400 href=https://help.ably.io/error/40005
```

Result: As expected

### RTN14b, RTN14g  ⛔ 
Ignoring as these spec items for now as they revolve around `ProtocolMessage`

### RTN14c, RTN14d, RTN14e, RTN14f ✅ 

**Turning wifi off** - reconnect triggers every 15 seconds

loops between states: `connecting` and `disconnected` every 15s for 60s (i.e., until the default `connectionStateTtl`)
there-further, state changes between `connecting` and `suspended` continuously.

logs
```js
2020-07-31 16:44:48.912345 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:44:48.965277 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:45:03.950481 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:45:04.014063 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:45:18.988102 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:45:19.062352 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:45:34.020740 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:45:34.109471 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:45:49.056232 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:45:49.127278 : ConnectionStateChange event: ConnectionEvent.suspended
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:46:49.101562 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:46:49.178212 : ConnectionStateChange event: ConnectionEvent.suspended
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
2020-07-31 16:47:49.139349 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 16:47:49.213962 : ConnectionStateChange event: ConnectionEvent.suspended
                             Reason: ErrorInfo message=sandbox-realtime.ably.io code=80000 statusCode=503 href=https://help.ably.io/error/80000
```
result: As expected

### RTN15h, RTN15h1, RTN15h2  ✅ 

#### Temporary key ✅ 

Created a temporary key on web console and deleted that after connection is established.
Connection disconnected, and eventually status changed to failed after 1 retry. 

```js
2020-07-31 18:25:05.070597 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 18:25:05.296538 : ConnectionStateChange event: ConnectionEvent.connected
                             Reason: null
2020-07-31 18:25:12.123308 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=Key/token status changed (revoke). (See https://help.ably.io/error/40131 for help.) code=40131 statusCode=401 href=https://help.ably.io/error/40131
2020-07-31 18:25:12.126130 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 18:25:12.408257 : ConnectionStateChange event: ConnectionEvent.failed
                             Reason: ErrorInfo message=Key revoked. (See https://help.ably.io/error/40131 for help.) code=40131 statusCode=401 href=https://help.ably.io/error/40131
```
result: As expected

#### Temporary app ✅ 

Created a temporary app on web console and deleted that after connection is established.
Connection disconnected, and eventually status changed to failed after 1 retry.

```js
2020-07-31 18:14:26.818151 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 18:14:27.057491 : ConnectionStateChange event: ConnectionEvent.connected
                             Reason: null
2020-07-31 18:14:51.896204 : ConnectionStateChange event: ConnectionEvent.disconnected
                             Reason: ErrorInfo message=Application lEu0Vg disabled. (See https://help.ably.io/error/40300 for help.) code=40300 statusCode=403 href=https://help.ably.io/error/40300
2020-07-31 18:14:52.612866 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 18:14:52.926823 : ConnectionStateChange event: ConnectionEvent.failed
                             Reason: ErrorInfo message=Application lEu0Vg disabled. (See https://help.ably.io/error/40300 for help.) code=40300 statusCode=403 href=https://help.ably.io/error/40300
```
result: As expected

#### Restricted API key ✅ 

Trying to attach to a channel with an API key with restricted access

```js
2020-07-31 19:40:59.586416 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 19:41:00.463867 : ConnectionStateChange event: ConnectionEvent.connected
                             Reason: null
//Here, trying to attach to channel that is not allowed with this API key
                             Attaching to channel test-channel: Current state ChannelState.initialized
                             ChannelStateChange: ChannelState.attaching
                             Reason: null
                             ChannelStateChange: ChannelState.suspended
                             Reason: ErrorInfo message=Channel denied access based on given capability; channelId = test-channel. (See https://help.ably.io/error/40160 for help.) code=40160 statusCode=401 href=https://help.ably.io/error/40160
                             Unable to attach to channel: ErrorInfo message=Channel denied access based on given capability; channelId = test-channel. (See https://help.ably.io/error/40160 for help.) code=40160 statusCode=401 href=https://help.ably.io/error/40160
```
result: As expected

#### Un-restricting the above API Key, and manually re-connecting ❓ 

The above, with updated API key settings to remove restrictions and trying a fresh connection again by `realtime.connect()` on same realtime instance:

```js
2020-07-31 19:45:58.041846 : ConnectionStateChange event: ConnectionEvent.connecting
                             Reason: null
2020-07-31 19:45:58.315391 : ConnectionStateChange event: ConnectionEvent.connected
                             Reason: ErrorInfo message=Connection unavailable code=80002 statusCode=503 href=https://help.ably.io/error/80002
                             Attaching to channel test-channel: Current state ChannelState.suspended
```

result: **Unexpected behavior** ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ 
reason:
`ConnectionState` changes to `connected` but with a reason **"Connection Unavailable"**.
This isn't expected


If a fresh realtime instance is used to connect, it connects as expected.

#### Another observation ❗

If a channel is already connected, it can publish and subscribe to/from that channel
even if API Key settings are updated with new restricted permissions.

### RTN15a ✅ 

Token has expired => re-authenticates automatically. Calls authCallback if configured

### RTN15g (RTN15g1, RTN15g2, RTN15g3) ✅ 

These items are closely related with logs shared under heading `RTN14c, RTN14d, RTN14e, RTN14f` above

### RTN15i, RTN15b (RTN15b1, RTN15b2), RTN15c (RTN15c1, RTN15c2, RTN15c3, RTN15c4), RTN15e ⛔ 

Ignoring as these spec items for now as they revolve around `ProtocolMessage`

### RTN15f ⛔ 

Ignoring as these spec items for now as they revolve around `ACK` and `NACK`

### RTN15d ⛔ 

Integration Tests - unsure of the priority on integration tests at the moment.
