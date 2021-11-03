/// params to configure encryption for a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TZ1
abstract class CipherParams {
  String algorithm;
  int keyLength;
  String mode;

  CipherParams({required this.algorithm, required this.keyLength, required this.mode});
}
