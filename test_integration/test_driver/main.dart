import 'package:args/args.dart';

import 'tests_abstract.dart';
import 'tests_config.dart';

void main(List<String> args) {
  final parser = ArgParser();
  final allowedModules = TestCategory.values
      .map((group) => group.toString().split('.')[1])
      .toList();
  parser
    ..addMultiOption(
      'modules',
      abbr: 'm',
      allowed: allowedModules,
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

  final modules = argv['modules'] as List;
  if (modules.isEmpty) {
    runTests(all: true);
  } else {
    runTests(
        groups: modules
            .map((module) =>
                TestCategory.values[allowedModules.indexOf(module as String)])
            .toList());
  }
}
