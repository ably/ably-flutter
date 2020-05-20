import 'dart:io';
import 'codegencontext.dart' show context;

String projectRoot = "../";
String templatesRoot = "./templates/";

Map<String, String> toGenerate = {
  //input template path vs output file path
  "${templatesRoot}platformconstants.dart.hbs": "${projectRoot}lib/src/gen/platformconstants.dart",
  "${templatesRoot}platformconstants.java.hbs": "${projectRoot}android/src/main/java/io/ably/flutter/plugin/gen/PlatformConstants.java",
  "${templatesRoot}platformconstants.h.hbs": "${projectRoot}ios/Classes/codec/AblyPlatformConstants.h",
  "${templatesRoot}platformconstants.m.hbs": "${projectRoot}ios/Classes/codec/AblyPlatformConstants.m",
};

void main() async {
  for(MapEntry entry in toGenerate.entries){
    String source = getContent(File(entry.key).readAsStringSync(), context);
    File(entry.value).writeAsStringSync(
        "//\n// Generated code. Do not modify.\n// source: ${entry.key.replaceAll('./', 'bin/')} \n//\n\n${source}"
    );
    print("File written: ${entry.value} ✔");
  }
}

//{{hello}}, {{ hi_there  }}
final variableRegExp = RegExp("{{\\s*([a-zA-Z\$_][a-zA-Z0-9\$_]*)\\s*}}");

//{{#each xyz}}{{name}}{{/each}}
final iteratorRegexp = RegExp("{{#each\\s+([a-zA-Z\$_][a-zA-Z0-9\$_]*)\\s*}}([.\\s\\S]*?){{\\\s*\\/each\\s*}}");

String getContent(String templateStr, Map<String, dynamic> context){
  //matching loops
  Iterable<RegExpMatch> matches = iteratorRegexp.allMatches(templateStr);
  if(matches!=null){
    for(RegExpMatch match in matches){
      String fullMatch = match.group(0);
      String iteratorContext = match.group(1);
      String iterable = match.group(2);
      List<Map<String, dynamic>> iteratingContext = context[iteratorContext];
      templateStr = templateStr.replaceFirst(fullMatch, iteratingContext.map((Map<String, dynamic> _context)=>getContent(iterable, _context)).join(""));
    }
  }

  //replacing variables
  return templateStr.replaceAllMapped(variableRegExp, (match){
    return context[match.group(1)].toString();
  });
}
