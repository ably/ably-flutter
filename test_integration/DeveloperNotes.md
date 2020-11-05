# Developer Notes

As this is a plugin


### Folder Structure

`/lib/test/*_test.dart` contains the widgets in which tests will be run

Any other files in `/lib/test/` are helpers/utilities for the test files

`test_driver` contains the test files that act as initiators for running the tests on emulator

`test_driver/test_implementation` contains the source which interacts with emulator
via flutter driver


### Writing new tests

1. Make an entry in [lib/test/test_names.dart](lib/test/test_names.dart)
2. Write test widget file in `lib/test/<new-feature>_test.dart`. Make sure to follow the same
 fashion like other widgets
3. Link the test name and test widget in [lib/test/test_factory.dart](lib/test/test_factory.dart)
4. Write test invoking function in [test_driver/test_implementation](test_driver/test_implementation)
5. Update the configuration variable `_tests` by linking the function written in step 4
 along with appropriate test message in [test_driver/tests_config.dart](test_driver/tests_config.dart)
6. Run `flutter drive all.dart` to confirm if the new test is being run.
