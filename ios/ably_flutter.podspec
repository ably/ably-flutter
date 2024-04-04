#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ably_flutter.podspec` to validate before publishing.
#
require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
flutter_package_plugin_version = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = 'ably_flutter'
  s.version          = flutter_package_plugin_version
  s.summary          = 'Ably Cocoa platform support for our Flutter plugin.'
  s.homepage         = 'https://www.ably.com/'
  s.license          = 'Apache 2.0'
  s.author           = { 'Ably' => 'support@ably.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Ably', '1.2.29'
  s.platform = :ios
  s.ios.deployment_target  = '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'GCC_PREPROCESSOR_DEFINITIONS' => "FLUTTER_PACKAGE_PLUGIN_VERSION=\\@\\\"#{flutter_package_plugin_version}\\\""
  }
  s.swift_version = '5.0'
end
