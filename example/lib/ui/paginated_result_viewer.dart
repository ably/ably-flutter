import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Displays a column of Widgets built from a [PaginatedResult.items], and
/// allows users to navigate between others pages of a [PaginatedResult]
/// by going to the next page, and going back to the first page.
class PaginatedResultViewer<T> extends HookWidget {
  final String title;

  ably.PaginatedResult<T>? firstPaginatedResult;
  final ValueWidgetBuilder<T> builder;
  final Future<ably.PaginatedResult<T>> Function() query;

  PaginatedResultViewer(
      {required this.title, required this.query, required this.builder});

  // : firstPaginatedResult = paginatedResult;

  Future<void> getFirstPaginatedResult(
      ValueNotifier<ably.PaginatedResult<T>?> currentPaginatedResult) async {
    final result = await query();
    firstPaginatedResult = result;
    currentPaginatedResult.value = result;
  }

  @override
  Widget build(BuildContext context) {
    final pageNumber = useState<int>(1);
    final currentPaginatedResult = useState<ably.PaginatedResult<T>?>(null);
    final items = currentPaginatedResult.value?.items ?? [];

    useEffect(() {
      if (currentPaginatedResult.value == null) {
        return;
      }
      if (pageNumber.value == 1) {
        currentPaginatedResult.value!
            .first()
            .then((result) => currentPaginatedResult.value = result);
      } else if (currentPaginatedResult.value!.hasNext()) {
        currentPaginatedResult.value!.next().then((result) {
          currentPaginatedResult.value = result;
        });
      }
    }, [pageNumber.value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => getFirstPaginatedResult(currentPaginatedResult),
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (items.isEmpty)
              ? [const Text('No messages')]
              : items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: builder(context, item, null),
              )).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextRow('Page', '#${pageNumber.value}'),
            TextButton(
              onPressed:
                  pageNumber.value != 1 ? () => pageNumber.value = 1 : null,
              child: const Text('Go to first page'),
            ),
            TextButton(
              onPressed: currentPaginatedResult.value?.hasNext() ?? false
                  ? () {
                      pageNumber.value += 1;
                    }
                  : null,
              child: const Text('Next page'),
            ),
          ],
        )
      ],
    );
  }
}
