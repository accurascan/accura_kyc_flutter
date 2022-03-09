#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint accura_kyc_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'accura_kyc_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*','Classes/Liveness.storyboard'
  s.dependency 'Flutter'
  s.dependency 'AccuraKYC','3.1.1'
  s.platform = :ios, '12.0'
  s.static_framework = true
  s.vendored_frameworks = 'AccuraOCR.framework'
  s.preserve_paths = 'AccuraOCR.framework'
  s.requires_arc = true
  s.swift_version = "5.0"
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  s.resource_bundles = {
      'accura_kyc_flutter' => ['Classes/**/*.{xib,storyboard,xcassets}'] }
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
