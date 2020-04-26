platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def common_pods
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa', '~> 5.1.1'
  pod 'RxDataSources', '~> 4.0.1'
  pod 'RxKeyboard', '~> 1.0.0'

  pod 'CSV.swift', '~> 2.4.3'

  pod 'DeviceKit', '~> 3.1.0'

  pod "ReachabilitySwift", '~> 5.0.0'

  pod 'SwiftyMarkdown', '~> 1.2.1'

  pod 'AlamofireImage', '~> 4.1.0'
end

def firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.22.0'
  pod 'Firebase/Auth', '~> 6.22.0'
  pod 'Firebase/Functions', '~> 6.22.0'
  pod 'Firebase/Storage', '~> 6.22.0'
  pod 'Firebase/RemoteConfig', '~> 6.22.0'
end

target "eRouska Dev" do
  common_pods
  firebase_pods
end

target "eRouska Prod" do
  common_pods
  firebase_pods
end

target "eRouska Mac" do
  common_pods
  firebase_pods
end
