source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'AZ Holistic Sport Clinic' do
  pod 'SQLite.swift', '~> 0.11.5'
  pod 'SwiftyJSON', '~> 4.3.0'
  pod 'RSBarcodes_Swift', '~> 4.2.1'
  pod 'KeychainAccess', '~> 3.1.2'
  pod 'SwiftHTTP', '~> 3.0.1'
  pod 'FMDB', '~> 2.7.12'
  pod 'SCLAlertView', '~> 0.8'
  pod 'SwipeMenuViewController', '~> 3.0.0'
  pod 'ScrollableGraphView', '~> 4.0.5'
  pod 'Reusable', '~> 4.0.5'
  pod 'Cosmos', '~> 18.0'
  pod 'DropDown', '~> 2.3.12'
  pod 'ReachabilitySwift', '~> 5.2.4'
  pod 'ANLoader',  :git => 'https://github.com/ANSCoder/ANLoader.git'
  pod 'Charts'
  pod 'SDWebImage', '~> 5.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'  # required by simple_permission
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
