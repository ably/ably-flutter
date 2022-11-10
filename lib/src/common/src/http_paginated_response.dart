import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// The response from an HTTP request containing an empty or
/// JSON-encodable object response
///
/// [T] can be a [Map] or [List]
///
/// https://docs.ably.com/client-lib-development-guide/features/#HP1
/// END LEGACY DOCSTRING

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

  /// BEGIN LEGACY DOCSTRING
  /// HTTP status code for the response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The HTTP status code of the response.
  /// END EDITED CANONICAL DOCSTRING
  int? statusCode;

  /// BEGIN LEGACY DOCSTRING
  /// indicates whether the request is successful
  ///
  /// true when 200 <= [statusCode] < 300
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP5
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether `statusCode` indicates success. This is equivalent to
  /// `200 <= statusCode < 300`.
  /// END EDITED CANONICAL DOCSTRING
  bool? success;

  /// BEGIN LEGACY DOCSTRING
  /// Value from X-Ably-Errorcode HTTP header, if available in response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP6
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The error code if the `X-Ably-Errorcode` HTTP header is sent in the
  /// response.
  /// END EDITED CANONICAL DOCSTRING
  int? errorCode;

  /// BEGIN LEGACY DOCSTRING
  /// Value from X-Ably-Errormessage HTTP header, if available in response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP7
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The error message if the `X-Ably-Errormessage` HTTP header is sent in the
  /// response.
  /// END EDITED CANONICAL DOCSTRING
  String? errorMessage;

  /// BEGIN LEGACY DOCSTRING
  /// Array of key value pairs of each response header
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP8
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The headers of the response.
  /// END EDITED CANONICAL DOCSTRING
  List<Map<String, String>>? headers;

  /// BEGIN LEGACY DOCSTRING
  /// returns a new HttpPaginatedResponse loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#HP2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [HttpPaginatedResponse], which is a page of results for message
  /// and presence history, stats, and REST presence requests, loaded with the
  /// next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Future<HttpPaginatedResponse<T>> next();

  /// BEGIN LEGACY DOCSTRING
  /// returns a new HttpPaginatedResponse with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#HP2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [HttpPaginatedResponse], which is a page of results for message
  /// and presence history, stats, and REST presence requests, for the first
  /// page of results.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Future<HttpPaginatedResponse<T>> first();
}
