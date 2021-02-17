import '../../ably_flutter.dart';
import '../spec/spec.dart' as spec;
import 'message.dart';
import 'platform_object.dart';

class PaginatedResult<T> extends PlatformObject
    implements spec.PaginatedResultInterface<T> {

  /// stores page handle created by platform APIs
  ///
  /// handle is updated after creating an instance as they are received
  /// as 2 different properties of AblyMessage, and this instance is
  /// instantiated by the codec. So the code invoking platform method
  /// is bound to update this [_pageHandle]
  ///
  /// [PaginatedResult.fromAblyMessage] will act as a utility to update
  /// this property. See [next] and [first] for usages
  int _pageHandle;

  List<T> _items;

  /// items return page of results
  @override
  List<T> get items => _items;

  bool _hasNext;

  /// Creates a PaginatedResult instance from items and a boolean indicating
  /// whether there is a next page
  PaginatedResult(this._items, {bool hasNext})
      : _hasNext = hasNext,
        super(fetchHandle: false);

  PaginatedResult.fromAblyMessage(AblyMessage message)
      : super(fetchHandle: false) {
    final rawResult = message.message as PaginatedResult<Object>;
    _items = rawResult.items.map<T>((e) => e as T).toList();
    _hasNext = rawResult.hasNext();
    _pageHandle = message.handle;
  }

  @override
  Future<int> createPlatformInstance() async => _pageHandle;

  /// returns a new PaginatedResult containing items of next page
  @override
  Future<PaginatedResult<T>> next() async {
    final message = await invoke<AblyMessage>(PlatformMethod.nextPage);
    return PaginatedResult<T>.fromAblyMessage(message);
  }

  /// returns a new PaginatedResult containing items of first page
  @override
  Future<PaginatedResult<T>> first() async {
    final message = await invoke<AblyMessage>(PlatformMethod.firstPage);
    return PaginatedResult<T>.fromAblyMessage(message);
  }

  /// returns whether there is a next page
  @override
  bool hasNext() => _hasNext;

  /// returns whether this is the last page
  @override
  bool isLast() => !_hasNext;
}
