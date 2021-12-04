#!/bin/zsh

set -e

MY_PATH=$(dirname "$0")

# Pre-requisites
# 1. You should have Flutter installed (e.g. in `/opt/flutter`) and on your PATH. This provides the Dart formatting tool, `flutter format`.
if ! [ -x "$(command -v flutter)" ]; then
  echo "🚨 FAILURE: Missing dependency, you must install Flutter, download it from https://docs.flutter.dev/get-started/install/macos" >&2
  exit 1
fi

# 2. Download the release from https://github.com/google/google-java-format/releases, and update your environment variable. This provides the Java formatting tool.
if [ "$GOOGLE_JAVA_FORMAT_PATH" = "" ]; then
  echo "🚨 FAILURE: You must download https://github.com/google/google-java-format/releases and set GOOGLE_JAVA_FORMAT_PATH to the jar you downloaded.";
  exit 1;
fi

# 3. Install using brew by running `brew install swiftformat`. This provides the Swift formatting tool.
if ! [ -x "$(command -v swiftformat)" ]; then
  echo "🚨 FAILURE: Missing dependency, you must install swiftformat, e.g. run 'brew install swiftformat'" >&2
  exit 1
fi

echo "Formatting Dart 🐣 files..."
flutter format $MY_PATH
echo "Formatted Dart 🐥 files.\n"

echo "Formatting Java 🌰 files..."
JAVA_FILES=$(find $MY_PATH/android -name "*java" -type f -exec ls {} \;)
echo $JAVA_FILES | xargs java \
  --add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED \
  -jar $GOOGLE_JAVA_FORMAT_PATH --replace
echo "Formatted Java ☕️ files.\n"

echo "Formatting Swift 💨 files..."
SWIFT_VERSION=5.5
swiftformat --swiftversion $SWIFT_VERSION $MY_PATH
echo "Formatted Swift 🌬 files.\n"
