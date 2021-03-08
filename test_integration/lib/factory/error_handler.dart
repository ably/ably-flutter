import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class ErrorHandler {
  void Function(Map<String, String> message) callback;

  ErrorHandler(this.callback);

  void onFlutterError(FlutterErrorDetails details) {
    print('Caught FlutterError::\n'
        'exception: ${details.exception}\n'
        'stack: ${details.stack}');

    callback({
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    });
  }

  static Map<String, String> encodeException(Object error, StackTrace stack) {
    print(error);
    print(stack);
    print('Caught Exception::\n'
        'error: $error\n'
        'stack: $stack');

    return {
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    };
  }
}
