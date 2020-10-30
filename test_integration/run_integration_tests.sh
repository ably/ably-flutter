#!/bin/sh

set -e
# TODO(tiholic) for some unknown reason this does not execute all tests
# It only executes the first it finds
# flutter drive test_driver/*

flutter drive test_driver/all.dart
#flutter drive test_driver/realtime.dart
#flutter drive test_driver/rest_publish.dart
#flutter drive test_driver/test_helper.dart
#flutter drive test_driver/without_wifi.dart
