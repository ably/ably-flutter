/// PaginatedResult [TG1](https://docs.ably.com/client-lib-development-guide/features/#TG1)
///
/// A type that represents page results from a paginated query.
/// The response is accompanied by metadata that indicates the
/// relative queries available.
abstract class PaginatedResultInterface<T> {
  /// items contain page of results
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG3
  List<T> get items;

  /// returns a new PaginatedResult loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG4
  Future<PaginatedResultInterface<T>> next();

  /// returns a new PaginatedResult with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.com/client-lib-development-guide/features/#TG5
  Future<PaginatedResultInterface<T>> first();

  /// returns true if there are further pages
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG6
  bool hasNext();

  /// returns true if this page is the last page
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TG7
  bool isLast();
}