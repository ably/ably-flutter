import 'dart:convert';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/data.dart';
import '../../utils/encoders.dart';

Future<Map<String, dynamic>> testRestCapabilities({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  final capabilitySpec = <String, List>{};
  final combinations = getAllSubsets(['publish', 'history', 'subscribe'])
      .where((spec) => spec.isNotEmpty)
      .toList();

  for (var i = 0; i < combinations.length; i++) {
    capabilitySpec['channel-$i'] = combinations[i];
  }
  final appKey = await provision('sandbox-', {
    'keys': [
      {'capability': jsonEncode(capabilitySpec)},
    ],
  });

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
  );

  final matrix = <Map>[];
  for (final entry in capabilitySpec.entries) {
    Map<String, dynamic> publishException;
    Map<String, dynamic> historyException;
    Map<String, dynamic> presenceException;
    Map<String, dynamic> presenceHistoryException;

    final channel = rest.channels.get(entry.key);
    try {
      await channel.publish();
    } on AblyException catch (exception) {
      publishException = encodeAblyException(exception);
    }
    try {
      await channel.history();
    } on AblyException catch (exception) {
      historyException = encodeAblyException(exception);
    }
    try {
      await channel.presence.get();
    } on AblyException catch (exception) {
      presenceException = encodeAblyException(exception);
    }
    try {
      await channel.presence.history();
    } on AblyException catch (exception) {
      presenceHistoryException = encodeAblyException(exception);
    }
    matrix.add({
      'channelCapabilities': entry.value,
      'publishException': publishException,
      'historyException': historyException,
      'presenceException': presenceException,
      'presenceHistoryException': presenceHistoryException,
    });
  }

  return {'matrix': matrix};
}
