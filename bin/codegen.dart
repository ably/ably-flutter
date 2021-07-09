import 'dart:io';

import 'codegen_context.dart' show context;
import 'templates/platformconstants.dart.dart' as dart_template;
import 'templates/platformconstants.h.dart' as objc_header_template;
import 'templates/platformconstants.java.dart' as java_template;
import 'templates/platformconstants.m.dart' as objc_impl_template;

typedef Template = String Function(Map<String, dynamic> context);

const String projectRoot = '../';

Map<Template, String> toGenerate = {
  // input template method vs output file path
  dart_template.$: '${projectRoot}lib/src/generated/platform_constants.dart',
  java_template.$:
      '${projectRoot}android/src/main/java/io/ably/flutter/plugin/generated/PlatformConstants.java',
  objc_header_template.$:
      '${projectRoot}ios/Classes/codec/AblyPlatformConstants.h',
  objc_impl_template.$:
      '${projectRoot}ios/Classes/codec/AblyPlatformConstants.m',
};

void main() {
  for (final entry in toGenerate.entries) {
    final source = entry.key(context).replaceAll(RegExp(r'\t'), '    ');
    File(entry.value).writeAsStringSync('''
//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

$source''');
    // ignore: avoid_print
    print('File written: ${entry.value} ✔');
  }
}
