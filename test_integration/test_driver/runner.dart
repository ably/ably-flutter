import 'package:args/args.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'tests_abstract.dart';
import 'tests_config.dart';

void main(List<String> args) {
  final parser = ArgParser();

  parser
    ..addMultiOption(
      'modules',
      abbr: 'm',
      allowed: TestModules.values.map(EnumToString.convertToString).toSet(),
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help content',
    );

  final argv = parser.parse(args);

  if (argv['help'] as bool) {
    print(parser.usage);
    return;
  }

  final selectedModules = _parseModulesStringIntoTestModules(
      argv['modules'] as List<String>);

  if (selectedModules.isEmpty) {
    runTests(all: true);
  } else if (selectedModules is Iterable) {
    runTests(testModules: selectedModules);
  }
}

Iterable<TestModules> _parseModulesStringIntoTestModules(
    List<String> modulesStrings) {
  final modules = modulesStrings
      .map((module) => EnumToString.fromString(TestModules.values, module))
      .whereType<TestModules>().toSet();
  return TestModules.values.toSet().intersection(modules);
}