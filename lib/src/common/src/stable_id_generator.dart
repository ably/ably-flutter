import 'dart:math';

/// A utility class for generating stable IDs.
///
/// Each ID consists of two parts:
/// 1. First part: 4 last bytes of timestamp in milliseconds
/// 2. Second part: 4 bytes from Dart random generator
class StableIdGenerator {
  /// Random number generator for the second part of the ID
  static final Random _random = Random();

  /// Generates a stable ID.
  ///
  /// The ID consists of two parts:
  /// 1. First part: 4 last bytes of timestamp in milliseconds
  /// 2. Second part: 4 bytes from Dart random generator
  ///
  /// @return A stable ID as an integer
  static int generate() {
    // Get current timestamp in milliseconds
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Extract the last 4 bytes (32 bits) from the timestamp
    // We use bitwise AND with 0xFFFFFFFF to ensure we only get the last 32 bits
    final timestampPart = timestamp & 0xFFFFFFFF;

    // Generate 4 random bytes (32 bits)
    // The nextInt method generates a non-negative random integer
    // from 0 (inclusive) to max (exclusive)
    final randomPart = _random.nextInt(0x100000000); // 2^32

    // Combine both parts
    // Shift the timestamp part 32 bits to the left and add the random part
    return (timestampPart << 32) | randomPart;
  }
}
