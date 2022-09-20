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
class ErrorInfo {
  /// BEGIN LEGACY DOCSTRING
  /// ably specific error code
  /// END LEGACY DOCSTRING
  final int? code;

  /// BEGIN LEGACY DOCSTRING
  /// link to error related documentation as
  /// END LEGACY DOCSTRING
  final String? href;

  /// BEGIN LEGACY DOCSTRING
  /// error message
  /// END LEGACY DOCSTRING
  final String? message;

  /// BEGIN LEGACY DOCSTRING
  /// cause for the error
  /// END LEGACY DOCSTRING
  final ErrorInfo? cause;

  /// BEGIN LEGACY DOCSTRING
  /// generic status code
  /// END LEGACY DOCSTRING
  final int? statusCode;

  /// BEGIN LEGACY DOCSTRING
  /// request id which triggered this exception
  /// END LEGACY DOCSTRING
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
