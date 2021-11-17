import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// PaginatedResult [TG1](https://docs.ably.com/client-lib-development-guide/features/#TG1)
///
/// A type that represents page results from a paginated query.
/// The response is accompanied by metadata that indicates the
/// relative queries available.
class PaginatedResult<T> extends PlatformObject {
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

  /// items contain page of results
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG3
  @override
  List<T> get items => _items;

  final bool _hasNext;

  /// Creates a PaginatedResult instance from items and a boolean indicating
  /// whether there is a next page
  PaginatedResult(this._items, {required bool hasNext})
      : _hasNext = hasNext,
        super(fetchHandle: false);

  /// Instantiates by extracting result from [AblyMessage] returned from
  /// platform method.
  ///
  /// Sets appropriate [_pageHandle] for identifying platform side of this
  /// result object so that [next] and [first] can be executed
  PaginatedResult.fromAblyMessage(AblyMessage<PaginatedResult> message)
      : _items = message.message.items.map<T>((e) => e as T).toList(),
        _hasNext = message.message.hasNext(),
        _pageHandle = message.handle,
        super(fetchHandle: false);

  @override
  Future<int?> createPlatformInstance() async => _pageHandle;

  /// returns a new PaginatedResult loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG4
  Future<PaginatedResult<T>> next() async {
    final message = await invokeRequest<AblyMessage>(PlatformMethod.nextPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  /// returns a new PaginatedResult with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG5
  Future<PaginatedResult<T>> first() async {
    final message = await invokeRequest<AblyMessage>(PlatformMethod.firstPage);
    return PaginatedResult<T>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  /// returns true if there are further pages
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG6
  bool hasNext() => _hasNext;

  /// returns true if this page is the last page
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG7
  bool isLast() => !_hasNext;
}
