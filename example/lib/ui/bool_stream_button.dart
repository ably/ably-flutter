import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';

/// [BoolStreamButton] makes sure that all Stream<bool> passed to it
/// has a true value before enabling the button. If any stream has a false
/// value, it will be disabled.
///
/// Pass it either 1 stream (using [this.stream])
/// or multiple (using [this.streams]). To convert your stream of objects
/// into a bool use a map.
class BoolStreamButton extends StatelessWidget {
  final Stream<bool>? stream;
  final List<Stream<bool>>? streams;
  final VoidCallback onPressed;
  final Widget child;

  BoolStreamButton({
    required this.onPressed,
    required this.child,
    this.stream,
    this.streams,
    Key? key,
  }) : super(key: key) {
    if (stream != null && streams != null) {
      throw Exception('Use either streams or stream argument, not both');
    }
  }

  /// Combines all streams into one, which has a true value if all
  /// streams have true values, otherwise it returns false.
  Stream<bool> combineStreams(List<Stream<bool>> streams) {
    final first = streams.first;
    final others = <Stream<bool>>[...streams.skip(1)];
    return first
        .combineLatestAll(others)
        .map((boolList) => !boolList.contains(false));
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: (streams != null) ? combineStreams(streams!) : stream,
        builder: (context, snapshot) => TextButton(
          onPressed:
              (snapshot.hasData && snapshot.data == true) ? onPressed : null,
          child: child,
        ),
      );
}
