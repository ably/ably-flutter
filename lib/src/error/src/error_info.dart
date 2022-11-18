/// A generic Ably error object that contains an Ably-specific status code, and
/// a generic status code.
///
/// Errors returned from the Ably server are compatible with the `ErrorInfo`
/// structure and should result in errors that inherit from `ErrorInfo`.
class ErrorInfo {
  /// Ably [error code](https://github.com/ably/ably-common/blob/main/protocol/errors.json).
  final int? code;

  /// This is included for REST responses to provide a URL for additional help
  /// on the error code.
  final String? href;

  /// Additional message information, where available.
  final String? message;

  /// Information pertaining to what caused the error where available.
  final ErrorInfo? cause;

  /// HTTP Status Code corresponding to this error, where applicable.
  final int? statusCode;

  /// If a request fails, the request ID must be included in the `ErrorInfo`
  /// returned to the user.
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
