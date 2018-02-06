source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, ‘11.0’

abstract_target 'WD' do
    pod 'SnapKit', '~> 4.0.0'
    pod 'Fritz', '~> 1.0.0-beta'

    target 'WhatDog' do
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4'
        end
    end
end
