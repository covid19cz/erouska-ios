platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.22.0'
  pod 'Firebase/Auth', '~> 6.22.0'
  pod 'Firebase/Functions', '~> 6.22.0'
  pod 'Firebase/Storage', '~> 6.22.0'
  pod 'Firebase/RemoteConfig', '~> 6.22.0'
end

target "eRouska Dev" do
  firebase_pods
end

target "eRouska Prod" do
  firebase_pods
end

target "eRouska Mac" do

end
