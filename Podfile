# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'CNotifySDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CNotifySDK
  # pod 'Firebase/Core'
  pod 'Firebase/Messaging'

  target 'CNotifySDKTests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
    end
  end

end
