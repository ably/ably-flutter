#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ably_flutter.podspec' to validate before publishing.
#
require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

if defined?($FirebaseSDKVersion)
  Pod::UI.puts "#{pubspec['name']}: Using user specified Firebase SDK version '#{$FirebaseSDKVersion}'"
  firebase_sdk_version = $FirebaseSDKVersion
else
  firebase_core_script = File.join(File.expand_path('..', File.expand_path('..', File.dirname(__FILE__))), 'firebase_core/ios/firebase_sdk_version.rb')
  if File.exist?(firebase_core_script)
    require firebase_core_script
    firebase_sdk_version = firebase_sdk_version!
    Pod::UI.puts "#{pubspec['name']}: Using Firebase SDK version '#{firebase_sdk_version}' defined in 'firebase_core'"
  end
end

Pod::Spec.new do |s|
  s.name             = 'ably_flutter'
  s.version          = '0.0.5'
  s.summary          = 'Ably Cocoa platform support for our Flutter plugin.'
  s.homepage         = 'https://www.ably.com/'
  s.license          = 'Apache 2.0'
  s.author           = { 'Ably' => 'support@ably.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  
  s.dependency 'Flutter'
  s.dependency 'Ably', '1.2.4'
  
#  s.dependency 'firebase_core'
#  s.dependency 'firebase_messaging'
#  s.static_framework = true # Required to avoid error: [!] The 'Pods-Runner' target has transitive dependencies that include statically linked binaries: (firebase_core)
s.dependency 'Firebase/Messaging', firebase_sdk_version


  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'GCC_PREPROCESSOR_DEFINITIONS' => "LIBRARY_VERSION=\\@\\\"#{library_version}\\\" LIBRARY_NAME=\\@\\\"flutter-fire-fcm\\\""
  }
end
