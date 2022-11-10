import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// A superset of [PaginatedResult] which represents a page of results plus
/// metadata indicating the relative queries available to it.
/// `HttpPaginatedResponse` additionally carries information about the
/// response to an HTTP request.
/// END EDITED CANONICAL DOCSTRING
abstract class HttpPaginatedResponse<T> extends PaginatedResult<T> {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [PaginatedResult._pageHandle] for identifying platform
  /// side of this result object so that [next] and [first] can be executed
  /// END LEGACY DOCSTRING
  HttpPaginatedResponse.fromAblyMessage(
    AblyMessage<PaginatedResult<dynamic>> message,
  ) : super.fromAblyMessage(message);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The HTTP status code of the response.
  /// END EDITED CANONICAL DOCSTRING
  int? statusCode;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether `statusCode` indicates success. This is equivalent to
  /// `200 <= statusCode < 300`.
  /// END EDITED CANONICAL DOCSTRING
  bool? success;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The error code if the `X-Ably-Errorcode` HTTP header is sent in the
  /// response.
  /// END EDITED CANONICAL DOCSTRING
  int? errorCode;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The error message if the `X-Ably-Errormessage` HTTP header is sent in the
  /// response.
  /// END EDITED CANONICAL DOCSTRING
  String? errorMessage;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The headers of the response.
  /// END EDITED CANONICAL DOCSTRING
  List<Map<String, String>>? headers;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [HttpPaginatedResponse], which is a page of results for message
  /// and presence history, stats, and REST presence requests, loaded with the
  /// next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Future<HttpPaginatedResponse<T>> next();

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [HttpPaginatedResponse], which is a page of results for message
  /// and presence history, stats, and REST presence requests, for the first
  /// page of results.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Future<HttpPaginatedResponse<T>> first();
}
