#!/bin/zsh

set -e

MY_PATH=$(dirname "$0")

bash $MY_PATH/format-files-dependencies.sh

echo "Formatting Dart files..."
flutter format $MY_PATH
echo "✅ Formatted Dart files.\n"

echo "Formatting Java files..."
JAVA_FILES=$(find $MY_PATH/android -name "*java" -type f -exec ls {} \;)
echo $JAVA_FILES | xargs java \
  --add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED \
  --add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED \
  -jar $GOOGLE_JAVA_FORMAT_PATH --replace
echo "✅ Formatted Java files.\n"

echo "Formatting Swift files..."
SWIFT_VERSION=5.5
swiftformat --swiftversion $SWIFT_VERSION $MY_PATH
echo "✅ Formatted Swift files.\n"
