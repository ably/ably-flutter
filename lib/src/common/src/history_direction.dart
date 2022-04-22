import 'dart:core';

/// Used to indicate direction of entries in Realtime and REST history
// ignore_for_file: public_member_api_docs
enum HistoryDirection {
  forwards,
  backwards,
}

extension Value on HistoryDirection {
  /// Returns enum value as String
  String value() {
    switch (this) {
      case HistoryDirection.forwards:
        return 'forwards';
      case HistoryDirection.backwards:
        return 'backwards';
    }
  }
}
