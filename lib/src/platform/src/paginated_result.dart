import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Contains a page of results for message or presence history, stats, or REST
/// presence requests.
///
/// A `PaginatedResult` response from a REST API paginated query is also
/// accompanied by metadata that indicates the relative queries available to the
/// `PaginatedResult` object.
class PaginatedResult<T> extends PlatformObject {
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
  int? _pageHandle;

  late final List<T> _items;

  /// Contains the current page of results; for example, an array of
  /// [Message] or [PresenceMessage] objects for a channel history request.
  List<T> get items => _items;

  final bool _hasNext;

  /// @nodoc
  /// Creates a PaginatedResult instance from items and a boolean indicating
  /// whether there is a next page
  PaginatedResult(this._items, {required bool hasNext})
      : _hasNext = hasNext,
        super(fetchHandle: false);

  /// @nodoc
  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [_pageHandle] for identifying platform side of this
  /// result object so that [next] and [first] can be executed
  PaginatedResult.fromAblyMessage(AblyMessage<PaginatedResult<dynamic>> message)
      : _hasNext = message.message.hasNext(),
        _items = message.message.items.map<T>((e) => e as T).toList(),
        _pageHandle = message.handle,
        super(fetchHandle: false);

  /// @nodoc
  @override
  Future<int?> createPlatformInstance() async => _pageHandle;

  /// Returns a new [PaginatedResult], which is a page of results for message
  /// and presence history, stats, and REST presence requests, loaded with the
  /// next page of results.
  ///
  /// If there are no further pages, then null is returned.
  Future<PaginatedResult<T>> next() async {
    final message =
        await invokeRequest<AblyMessage<dynamic>>(PlatformMethod.nextPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// Returns a new [PaginatedResult], which is a page of results for message
  /// and presence history, stats, and REST presence requests, for the first
  /// page of results.
  Future<PaginatedResult<T>> first() async {
    final message =
        await invokeRequest<AblyMessage<dynamic>>(PlatformMethod.firstPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// Whether there are more pages available by calling next.
  ///
  /// Returns false if this page is the last page available.
  bool hasNext() => _hasNext;

  /// Whether this page is the last page.
  ///
  /// Returns false if there are more pages available by calling next available.
  bool isLast() => !_hasNext;
}
