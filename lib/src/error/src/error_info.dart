import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// An [AblyException] encapsulates [ErrorInfo] which carries details
/// about information related to Ably-specific error [code],
/// generic [statusCode], error [message],
/// link to error related documentation as [href],
/// [requestId] and [cause] of this exception
///
/// https://docs.ably.com/client-lib-development-guide/features/#TI1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// A generic Ably error object that contains an Ably-specific status code, and
/// a generic status code. Errors returned from the Ably server are compatible
/// with the ErrorInfo structure and should result in errors that inherit from
/// ErrorInfo.
/// END CANONICAL DOCSTRING
class ErrorInfo {
  /// BEGIN LEGACY DOCSTRING
  /// ably specific error code
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Ably [error code](https://github.com/ably/ably-common/blob/main/protocol/errors.json).
  /// END CANONICAL DOCSTRING
  final int? code;

  /// BEGIN LEGACY DOCSTRING
  /// link to error related documentation as
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// This is included for REST responses to provide a URL for additional help
  /// on the error code.
  /// END CANONICAL DOCSTRING
  final String? href;

  /// BEGIN LEGACY DOCSTRING
  /// error message
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Additional message information, where available.
  /// END CANONICAL DOCSTRING
  final String? message;

  /// BEGIN LEGACY DOCSTRING
  /// cause for the error
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Information pertaining to what caused the error where available.
  /// END CANONICAL DOCSTRING
  final ErrorInfo? cause;

  /// BEGIN LEGACY DOCSTRING
  /// generic status code
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// HTTP Status Code corresponding to this error, where applicable.
  /// END CANONICAL DOCSTRING
  final int? statusCode;

  /// BEGIN LEGACY DOCSTRING
  /// request id which triggered this exception
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// If a request fails, the request ID must be included in the ErrorInfo
  /// returned to the user.
  /// END CANONICAL DOCSTRING
  final String? requestId;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates a [ErrorInfo] with provided values
  /// END LEGACY DOCSTRING
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
