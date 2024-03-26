Pod::Spec.new do |s|
  s.name             = 'TruvSDK'
  s.version          = '1.2.3'
  s.summary          = 'The TruvSDK for iOS.'
  s.description      = <<-DESC
    The TruvSDK for iOS streamlines the integration of the Truv Bridge with your app. The integration allows end users to verify income, do direct deposit switch or share earned wages in a matter of seconds.
                       DESC

  s.homepage         = 'https://github.com/truvhq/ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Truv' => 'https://truv.com' }
  s.source           = { :git => 'https://github.com/truvhq/ios-sdk.git', :tag => s.version.to_s }

  s.vendored_frameworks = "TruvSDK.xcframework"
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.requires_arc = true

end
