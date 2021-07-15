import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../service/ably_service.dart';

class RestSliver extends StatefulWidget {
  final AblyService ablyService;

  const RestSliver(this.ablyService, {Key? key}) : super(key: key);

  @override
  _RestSliverState createState() => _RestSliverState();
}

class _RestSliverState extends State<RestSliver> {
  ably.PaginatedResult<ably.Message>? _restHistory;
  int msgCounter = 0;

  Widget createReleaseRestChannelButton() => TextButton(
        onPressed: () => widget.ablyService.releaseRestChannel(),
        child: const Text('Release Rest channel'),
      );

  Widget createGetRestChannelHistoryButton() => getPageNavigator<ably.Message>(
      name: 'Rest history',
      page: _restHistory,
      query: () async =>
          _rest!.channels.get(defaultChannel).history(ably.RestHistoryParams(
                direction: 'forwards',
                limit: 10,
              )),
      onUpdate: (result) {
        setState(() {
          _restHistory = result;
        });
      });

  Widget createPublishRestMessageButton() => TextButton(
        onPressed: () async {
                try {
                  await widget.ablyService.publishMessageUsingRestClient(
                      'Rest message $msgCounter');
                  msgCounter += 1;
                } on ably.AblyException catch (e) {
                  print('Rest message sending failed:: $e :: ${e.errorInfo}');
                }
              },
        child: Text('Publish message: "Rest message $msgCounter"'),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Rest',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        // TODO show connection status of button.
        createPublishRestMessageButton(),
        createGetRestChannelHistoryButton(),
        ..._restHistory?.items
                .map((m) => Text('${m.name}:${m.data?.toString()}'))
                .toList() ??
            [],
      ],
    );
  }
}
