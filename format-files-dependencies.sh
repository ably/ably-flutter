
echo "Checking file formatting dependencies are installed..."

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

echo "  ✅ File formatting dependencies available.\n"