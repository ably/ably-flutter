import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../op_state.dart';

class FourModeActionButton extends StatelessWidget {
  String actionText;
  VoidCallback onPressed;
  OpState opState;

  // bool? isLoading;
  // bool? isFailed;
  // bool? isSuccessful;
  // bool disabled;

  FourModeActionButton(
      {required this.actionText, required this.onPressed, required this.opState
      // this.isLoading,
      // this.isFailed,
      // this.isSuccessful,
      // this.disabled = false
      });

  Color getStateColor() {
    switch (opState) {
      case OpState.notStarted:
        return const Color.fromARGB(255, 192, 192, 255);
      case OpState.inProgress:
        return const Color.fromARGB(255, 192, 192, 192);
      case OpState.succeeded:
        return const Color.fromARGB(255, 128, 255, 128);
      case OpState.failed:
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
    // TODO: implement build
    return TextButton(
      child: Text(actionText, style: TextStyle(color: Colors.black)),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(getStateColor()),
      ),
      onPressed: (opState == OpState.notStarted || opState == OpState.failed)
          ? onPressed
          : null,
    );
  }

  String getDescription(String actionDescription, String operatingDescription,
      String doneDescription) {
    switch (opState) {
      case OpState.notStarted:
        return actionDescription;
      case OpState.inProgress:
        return '$operatingDescription...';
      case OpState.succeeded:
        return doneDescription;
      case OpState.failed:
        return 'Failed to $actionDescription';
    }
  }
}
