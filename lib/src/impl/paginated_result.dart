import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/platform_object.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;

class PaginatedResult<T> extends PlatformObject
    implements spec.PaginatedResultInterface<T> {

  int _pageHandle;

  /// sets platform object handle for PaginatedResult
  ///
  /// handle is updated after creating an instance as they are received
  /// as 2 properties of AblyMessage, and this instance is instantiated
  /// by the codec. So the platform method invoker is bound to update
  /// [_pageHandle].
  ///
  /// See [next] and [first] methods for usages
  void setPageHandle(int _handle){
    _pageHandle = _handle;
  }

  /// items contain page of results
  @override
  List<T> items;

  final bool _hasNext;

  /// Creates a PaginatedResult instance from items and a boolean indicating
  /// whether there is a next page
  PaginatedResult(this.items, bool hasNext) : _hasNext = hasNext;

  @override
  Future<int> createPlatformInstance() async => _pageHandle;

  /// returns a new PaginatedResult containing items of next page
  @override
  Future<PaginatedResult<T>> next() async {
    var message = await invoke<AblyMessage>(PlatformMethod.nextPage);
    var result = message.message as PaginatedResult<T>;
    result.setPageHandle(message.handle);
    return result;
  }

  /// returns a new PaginatedResult containing items of first page
  @override
  Future<PaginatedResult<T>> first() async {
    var message = await invoke<AblyMessage>(PlatformMethod.firstPage);
    var result = message.message as PaginatedResult<T>;
    result.setPageHandle(message.handle);
    return result;
  }

  /// returns whether there is a next page
  @override
  bool hasNext() => _hasNext;

  /// returns whether this is the last page
  @override
  bool isLast() => !_hasNext;
}
