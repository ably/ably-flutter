import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/widgets.dart';

import 'stage_button_stage.dart';
import '../provisioning.dart' as provisioning;
import '../service/ably_service.dart';
import 'stage_button.dart';

class AblyClientsSliver extends StatefulWidget {
  AblyService ablyService;
  void Function(String exceptionMessage) showExceptionMessageToUser;

  AblyClientsSliver(this.ablyService, this.showExceptionMessageToUser, {Key? key}) : super(key: key);

  @override
  _AblyClientsSliverState createState() => _AblyClientsSliverState();
}

class _AblyClientsSliverState extends State<AblyClientsSliver> {
  StageButtonStage _provisioningState = StageButtonStage.notStarted;
  String? _appKey;

  StageButtonStage _realtimeCreationStage = StageButtonStage.notStarted;
  StageButtonStage _restCreationState = StageButtonStage.notStarted;
  ably.ConnectionState? _realtimeConnectionState;
  ably.ChannelState? _realtimeChannelState;

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  Future<void> asyncInitState() async {
    try {
      await widget.ablyService.initializeRestClient();
      await widget.ablyService.initializeRealtimeClient();
    } catch (error) {
      widget.showExceptionMessageToUser('Error setting up Ably: $error');
    }
  }

  Future<void> provisionAbly() async {
    setState(() {
      _provisioningState = StageButtonStage.inProgress;
    });

    try {
      String appKey = await provisioning.createTemporaryApiKey('sandbox-');
      print('App key acquired! `$appKey`');
      setState(() {
        _appKey = appKey;
        _provisioningState = StageButtonStage.succeeded;
      });
    } on Exception catch (error) {
      print('Error provisioning Ably: $error');
      setState(() {
        _provisioningState = StageButtonStage.failed;
      });
      return;
    }
  }

  Future<void> initializeAblyRestClient() async {
    setState(() {
      _restCreationState = StageButtonStage.inProgress;
    });

    try {
      await widget.ablyService.initializeRestClient();
      setState(() {
        _restCreationState = StageButtonStage.succeeded;
      });
    } on Exception catch (error) {
      print('Error creating Ably Rest: $error');
      setState(() {
        _restCreationState = StageButtonStage.failed;
      });
      rethrow;
    }
  }

  Future<void> initializeAblyRealtimeClient() async {
    setState(() {
      _realtimeCreationStage = StageButtonStage.inProgress;
    });

    try {
      await widget.ablyService.initializeRealtimeClient();
      setState(() {
        _realtimeCreationStage = StageButtonStage.succeeded;
      });

      await widget.ablyService.subscribeToRealtimeConnectionStateChanges(
          (connectionStateChange) async {
        print('${DateTime.now()}:'
            ' ConnectionStateChange event: ${connectionStateChange.event}'
            '\nReason: ${connectionStateChange.reason}');
        setState(() {
          _realtimeConnectionState = connectionStateChange.current;
        });
      });

      await widget.ablyService
          .subscribeToRealtimeChannelStateChanges((channelStateChange) async {
        print('ChannelStateChange: ${channelStateChange.current}'
            '\nReason: ${channelStateChange.reason}');
        setState(() {
          _realtimeChannelState = channelStateChange.current;
        });
      });
    } on Exception catch (error) {
      print('Error creating Ably Realtime: $error');
      setState(() {
        _realtimeCreationStage = StageButtonStage.failed;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ably Clients',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        StageButton(
            text: "Initialize Ably Realtime client",
            onPressed: initializeAblyRealtimeClient,
            stage: _realtimeCreationStage),
        StageButton(
          text: "Initialize Ably Rest client",
          onPressed: initializeAblyRestClient,
          stage: _restCreationState,
        ),
      ],
    );
  }
}
