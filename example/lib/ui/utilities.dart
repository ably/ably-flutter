import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void logAndDisplayError(ably.ErrorInfo? errorInfo,
    {String prefixMessage = ' '}) {
  if (errorInfo == null) {
    return;
  }
  print(errorInfo.message);
  Fluttertoast.showToast(
      msg: 'Error: $prefixMessage. '
          '${errorInfo.message ?? 'No error message provided'}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16);
}

// This is a quick way to create a key from a password. In production,
// you should either create a random key or use a key derivation
// function (KDF) or other secure, attack-resistance mechanism instead.
// However, in the example app, we use this so that 2 devices running
// the example app can decrypt each other's message.
Uint8List keyFromPassword(String password) {
  final data = utf8.encode(password);
  final digest = sha256.convert(data);
  print('Length of digest: ${digest.bytes.length}');
  return Uint8List.fromList(digest.bytes);
}
