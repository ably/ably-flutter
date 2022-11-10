import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// A generic Ably error object that contains an Ably-specific status code, and
/// a generic status code. Errors returned from the Ably server are compatible
/// with the `ErrorInfo` structure and should result in errors that inherit from
/// `ErrorInfo`.
/// ENDEDITED  CANONICAL DOCSTRING
class ErrorInfo {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Ably [error code](https://github.com/ably/ably-common/blob/main/protocol/errors.json).
  /// END EDITED CANONICAL DOCSTRING
  final int? code;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// This is included for REST responses to provide a URL for additional help
  /// on the error code.
  /// END EDITED CANONICAL DOCSTRING
  final String? href;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Additional message information, where available.
  /// END EDITED CANONICAL DOCSTRING
  final String? message;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Information pertaining to what caused the error where available.
  /// END EDITED CANONICAL DOCSTRING
  final ErrorInfo? cause;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// HTTP Status Code corresponding to this error, where applicable.
  /// END EDITED CANONICAL DOCSTRING
  final int? statusCode;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// If a request fails, the request ID must be included in the `ErrorInfo`
  /// returned to the user.
  /// END EDITED CANONICAL DOCSTRING
  final String? requestId;

  /// @nodoc
  /// instantiates a [ErrorInfo] with provided values
  ErrorInfo({
    this.cause,
    this.code,
    this.href,
    this.message,
    this.requestId,
    this.statusCode,
  });

  @override
  String toString() => 'ErrorInfo'
      ' message=$message'
      ' code=$code'
      ' statusCode=$statusCode'
      ' href=$href';
}
