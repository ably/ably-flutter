import 'package:ably_flutter/ably_flutter.dart';

/// A superset of [PaginatedResult] which represents a page of results plus
/// metadata indicating the relative queries available to it.
///
/// `HttpPaginatedResponse` additionally carries information about the
/// response to an HTTP request.
abstract class HttpPaginatedResponse<T> extends PaginatedResult<T> {
  /// @nodoc
  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [PaginatedResult._pageHandle] for identifying platform
  /// side of this result object so that [next] and [first] can be executed
  HttpPaginatedResponse.fromAblyMessage(
    AblyMessage<PaginatedResult<dynamic>> message,
  ) : super.fromAblyMessage(message);

  /// The HTTP status code of the response.
  int? statusCode;

  /// Whether `statusCode` indicates success.
  ///
  /// This is equivalent to `200 <= statusCode < 300`.
  bool? success;

  /// The error code if the `X-Ably-Errorcode` HTTP header is sent in the
  /// response.
  int? errorCode;

  /// The error message if the `X-Ably-Errormessage` HTTP header is sent in the
  /// response.
  String? errorMessage;

  /// The headers of the response.
  List<Map<String, String>>? headers;

  /// Returns a new [HttpPaginatedResponse], which is a page of results for
  /// message and presence history, stats, and REST presence requests, loaded
  /// with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  @override
  Future<HttpPaginatedResponse<T>> next();

  /// Returns a new [HttpPaginatedResponse], which is a page of results for
  /// message and presence history, stats, and REST presence requests, for the
  /// first page of results.
  @override
  Future<HttpPaginatedResponse<T>> first();
}
