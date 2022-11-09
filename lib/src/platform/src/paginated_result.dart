import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// PaginatedResult [TG1](https://docs.ably.com/client-lib-development-guide/features/#TG1)
///
/// A type that represents page results from a paginated query.
/// The response is accompanied by metadata that indicates the
/// relative queries available.
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains a page of results for message or presence history, stats, or REST
/// presence requests. A `PaginatedResult` response from a REST API paginated
/// query is also accompanied by metadata that indicates the relative queries
/// available to the `PaginatedResult` object.
/// END EDITED CANONICAL DOCSTRING
class PaginatedResult<T> extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// stores page handle created by platform APIs
  ///
  /// handle is updated after creating an instance as they are received
  /// as 2 different properties of AblyMessage, and this instance is
  /// instantiated by the codec. So the code invoking platform method
  /// is bound to update this [_pageHandle]
  ///
  /// [PaginatedResult.fromAblyMessage] will act as a utility to update
  /// this property. See [next] and [first] for usages
  /// END LEGACY DOCSTRING
  int? _pageHandle;

  late final List<T> _items;

  /// BEGIN LEGACY DOCSTRING
  /// items contain page of results
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Contains the current page of results; for example, an array of
  /// [Message] or [PresenceMessage] objects for a channel history request.
  /// END EDITED CANONICAL DOCSTRING
  List<T> get items => _items;

  final bool _hasNext;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Creates a PaginatedResult instance from items and a boolean indicating
  /// whether there is a next page
  /// END LEGACY DOCSTRING
  PaginatedResult(this._items, {required bool hasNext})
      : _hasNext = hasNext,
        super(fetchHandle: false);

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [_pageHandle] for identifying platform side of this
  /// result object so that [next] and [first] can be executed
  /// END LEGACY DOCSTRING
  PaginatedResult.fromAblyMessage(AblyMessage<PaginatedResult<dynamic>> message)
      : _hasNext = message.message.hasNext(),
        _items = message.message.items.map<T>((e) => e as T).toList(),
        _pageHandle = message.handle,
        super(fetchHandle: false);

  @override
  Future<int?> createPlatformInstance() async => _pageHandle;

  /// BEGIN LEGACY DOCSTRING
  /// returns a new PaginatedResult loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [PaginatedResult], which is a page of results for message
  /// and presence history, stats, and REST presence requests, loaded with the
  /// next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<T>> next() async {
    final message =
        await invokeRequest<AblyMessage<dynamic>>(PlatformMethod.nextPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// BEGIN LEGACY DOCSTRING
  /// returns a new PaginatedResult with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG5
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a new [PaginatedResult], which is a page of results for message
  /// and presence history, stats, and REST presence requests, for the first
  /// page of results.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<T>> first() async {
    final message =
        await invokeRequest<AblyMessage<dynamic>>(PlatformMethod.firstPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// BEGIN LEGACY DOCSTRING
  /// returns true if there are further pages
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG6
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether there are more pages available by calling next. Return
  /// false if this page is the last page available.
  /// END EDITED CANONICAL DOCSTRING
  bool hasNext() => _hasNext;

  /// BEGIN LEGACY DOCSTRING
  /// returns true if this page is the last page
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG7
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether this page is the last page. Returns false if there are
  /// more pages available by calling next available.
  /// END EDITED CANONICAL DOCSTRING
  bool isLast() => !_hasNext;
}
