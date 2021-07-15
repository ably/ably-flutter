import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'stage_button_stage.dart';

class StageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final StageButtonStage stage;

  const StageButton(
      {required this.text,
      required this.onPressed,
        required this.stage,
      });

  Color getStateColor() {
    switch (stage) {
      case StageButtonStage.notStarted:
        return const Color.fromARGB(255, 192, 192, 255);
      case StageButtonStage.inProgress:
        return const Color.fromARGB(255, 192, 192, 192);
      case StageButtonStage.succeeded:
        return const Color.fromARGB(255, 128, 255, 128);
      case StageButtonStage.failed:
        return const Color.fromARGB(255, 255, 128, 128);
    }

    // if (disabled) {
    //   return Colors.grey;
    // }
    //
    // if (isFailed != null && isFailed!) {
    //   return const Color.fromARGB(255, 255, 128, 128);
    // }
    //
    // if (isSuccessful != null && isSuccessful!) {
    //   return const Color.fromARGB(255, 128, 255, 128);
    // }
    //
    // if (isLoading != null && isLoading!) {
    //   return const Color.fromARGB(255, 192, 192, 192);
    // }
    //
    // return const Color.fromARGB(255, 192, 192, 255);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(_getDescription(text), style: TextStyle(color: Colors.black)),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(getStateColor()),
      ),
      onPressed: (stage == StageButtonStage.notStarted || stage == StageButtonStage.failed)
          ? onPressed
          : null,
    );
  }

  String _getDescription(String text) {
    switch (stage) {
      case StageButtonStage.notStarted:
        return text;
      case StageButtonStage.inProgress:
        return 'Running: $text';
      case StageButtonStage.succeeded:
        return 'Success: $text';
      case StageButtonStage.failed:
        return 'Failed: $text';
    }
  }
}
