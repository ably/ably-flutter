import 'package:ably_flutter/ably_flutter.dart';

/// The response from an HTTP request containing an empty or
/// JSON-encodable object response
///
/// [T] can be a [Map] or [List]
///
/// https://docs.ably.com/client-lib-development-guide/features/#HP1
abstract class HttpPaginatedResponse<T> extends PaginatedResult<T> {
  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [_pageHandle] for identifying platform side of this
  /// result object so that [next] and [first] can be executed
  HttpPaginatedResponse.fromAblyMessage(
    AblyMessage<PaginatedResult<dynamic>> message,
  ) : super.fromAblyMessage(message);

  /// HTTP status code for the response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP4
  int? statusCode;

  /// indicates whether the request is successful
  ///
  /// true when 200 <= [statusCode] < 300
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP5
  bool? success;

  /// Value from X-Ably-Errorcode HTTP header, if available in response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP6
  int? errorCode;

  /// Value from X-Ably-Errormessage HTTP header, if available in response
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP7
  String? errorMessage;

  /// Array of key value pairs of each response header
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#HP8
  List<Map<String, String>>? headers;

  /// returns a new HttpPaginatedResponse loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#HP2
  @override
  Future<HttpPaginatedResponse<T>> next();

  /// returns a new HttpPaginatedResponse with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#HP2
  @override
  Future<HttpPaginatedResponse<T>> first();
}
