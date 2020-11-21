platform :ios, '13.5'
use_frameworks!
inhibit_all_warnings!

def firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.22.0'
  pod 'Firebase/Auth', '~> 6.22.0'
  pod 'Firebase/Functions', '~> 6.22.0'
  pod 'Firebase/Storage', '~> 6.22.0'
  pod 'Firebase/RemoteConfig', '~> 6.22.0'
  pod 'Firebase/Analytics', '~> 6.22.0'
end

target "eRouska Dev" do
  firebase_pods
end

target "eRouska Prod" do
  firebase_pods
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
    end
  end
end
