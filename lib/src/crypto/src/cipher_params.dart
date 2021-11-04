import '../../../ably_flutter.dart';

/// params to configure encryption for a channel
///
/// Pass this as the cipher constructor argument of  [RestChannelOptions] or
/// [RealtimeChannelOptions]. Do not construct [CipherParams] yourself, as it
/// internally refers to an instance of [CipherParams] on the platform side
/// (Android / iOS).
///
/// This class does not expose algorithm, keyLength or mode because these fields
/// are private in Ably Java's Crypto.CipherParams.
///
/// https://docs.ably.com/client-lib-development-guide/features/#TZ1
abstract class CipherParams {}
