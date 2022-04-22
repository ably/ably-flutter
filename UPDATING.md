# Updating / Migration Guide

This guide lists the changes needed to upgrade from one version of Ably to a newer one when there are breaking changes.

## [Upgrading from v1.2.13]

- `RestHistoryParams` and `RealtimeHistoryParams` now use `HistoryDirection` enum instead of `String` value for `direction`

## [Upgrading from v1.2.12]

- `TokenDetails`, `TokenParams` and `TokenRequest` classes are now immutable, parameters have to be passed through constructor

## [Upgrading from v1.2.8]

Changes made at v1.2.9:

- `ably.Push.pushEvents` is renamed to `ably.Push.activationEvents`, to be more meaningful. It provides access to events related to setting up push notification, such as activation, deactivation and notification permission. This was done to help future users clearly distinguish between `activationEvents` and `notificationEvents`.
- When instantiating `Rest` or `Realtime` with an API key, replace `ably.Rest(key: yourApiKey)` with `ably.Rest.fromKey(yourApiKey)`. This was done because using `ably.Rest(key: yourApiKey, options: clientOptions)` was misleading (`yourApiKey` was ignored).
