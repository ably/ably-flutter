/// An [AblyException] encapsulates [ErrorInfo] which carries details
/// about information related to Ably-specific error [code],
/// generic [statusCode], error [message],
/// link to error related documentation as [href],
/// [requestId] and [cause] of this exception
///
/// https://docs.ably.com/client-lib-development-guide/features/#TI1
class ErrorInfo {
  /// ably specific error code
  final int? code;

  /// link to error related documentation as
  final String? href;

  /// error message
  final String? message;

  /// cause for the error
  final ErrorInfo? cause;

  /// generic status code
  final int? statusCode;

  /// request id which triggered this exception
  final String? requestId;

  /// instantiates a [ErrorInfo] with provided values
  ErrorInfo({
    this.code,
    this.href,
    this.message,
    this.cause,
    this.statusCode,
    this.requestId,
  });

  @override
  String toString() => 'ErrorInfo'
      ' message=$message'
      ' code=$code'
      ' statusCode=$statusCode'
      ' href=$href';
}