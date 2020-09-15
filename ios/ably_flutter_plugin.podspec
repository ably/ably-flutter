#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ably_flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ably_flutter_plugin'
  s.version          = '0.0.3'
  s.summary          = 'Ably Cocoa platform support for our Flutter plugin.'
  s.homepage         = 'https://www.ably.io/'
  s.license          = 'Apache 2.0'
  s.author           = { 'Ably' => 'support@ably.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Ably'
  s.platform = :ios
  s.ios.deployment_target  = '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
