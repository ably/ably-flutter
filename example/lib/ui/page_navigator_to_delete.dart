Widget getPageNavigator<T>({
  required String name,
  required ably.PaginatedResult<T> page,
  required Future<ably.PaginatedResult<T>> Function() query,
  required Function(ably.PaginatedResult<T> result) onUpdate,
}) =>
    FlatButton(
      onPressed: () async {
        print('$name: getting ${page.hasNext() ? 'next' : 'first'} page');
        try {
          if (page.items.isEmpty) {
            onUpdate(await query());
          } else if (page.hasNext()) {
            onUpdate(await page.next());
          } else {
            onUpdate(await page.first());
          }
        } on ably.AblyException catch (e) {
          print('failed to get $name:: $e :: ${e.errorInfo}');
        }
      },
      onLongPress: () async {
        onUpdate(await query());
      },
      color: Colors.yellow,
      child: Text('Get $name'),
    );
