import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void logAndDisplayError(ably.ErrorInfo? errorInfo,
    {String prefixMessage = ' '}) {
  if (errorInfo == null) {
    return;
  }
  print(errorInfo.message);
  Fluttertoast.showToast(
      msg:
          'Error: $prefixMessage. ${errorInfo.message ?? 'No error message provided'}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16);
}
