#!/bin/sh
flutter drive test_driver/*

# TODO(zoechi) for some unknown reason this is not executed by the above command
# Renaming so that the base name does not contain `test` did not help.
flutter drive test_driver/test_helper.dart
