source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.2'

pod 'Bedrock/Core', :git => 'https://github.com/nickbolton/PBBedrock.git', :branch=>'master'
pod 'Bedrock/AutoLayout', :git => 'https://github.com/nickbolton/PBBedrock.git', :branch=>'master'
pod 'MMWormhole', '~> 1.1'
pod 'FlurrySDK', '~> 5.4'

target 'ToiletTime WatchKit Extension' do
    platform :ios, '8.2'
    pod 'MMWormhole', '~> 1.1'
    pod 'FlurrySDK', '~> 5.4'
    pod 'Bedrock/Core', :git => 'https://github.com/nickbolton/PBBedrock.git', :branch=>'master'
end

inhibit_all_warnings!

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_IDENTITY'] = 'iPhone Developer'
    end
  end
end
