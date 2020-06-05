import 'dart:io';
import 'codegencontext.dart' show context;
import 'templates/platformconstants.dart.dart' as dart_template;
import 'templates/platformconstants.java.dart' as java_template;
import 'templates/platformconstants.h.dart' as objc_header_template;
import 'templates/platformconstants.m.dart' as objc_impl_template;


typedef String Template(Map<String, dynamic> context);

String projectRoot = "../";

Map<Template, String> toGenerate = {
  // input template method vs output file path
  dart_template.$: "${projectRoot}lib/src/generated/platformconstants.dart",
  java_template.$: "${projectRoot}android/src/main/java/io/ably/flutter/plugin/generated/PlatformConstants.java",
  objc_header_template.$: "${projectRoot}ios/Classes/codec/AblyPlatformConstants.h",
  objc_impl_template.$: "${projectRoot}ios/Classes/codec/AblyPlatformConstants.m",
};

void main() async {
  for(MapEntry<Template, String> entry in toGenerate.entries){
    String source = entry.key(context);
    File(entry.value).writeAsStringSync(
        '''//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

${source}'''
    );
    print("File written: ${entry.value} ✔");
  }
}
