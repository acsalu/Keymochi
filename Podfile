source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Keymochi' do
    pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'Parse'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SwiftHEXColors'
end

target 'KeymochiTests' do
    pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'Quick', git: 'https://github.com/Quick/Quick.git', branch: 'swift-3.0'
    pod 'Nimble', git: 'https://github.com/Quick/Nimble.git', branch: 'swift-3.0'
end

target 'KeymochiUITests' do
    pod 'Quick', git: 'https://github.com/Quick/Quick.git', branch: 'swift-3.0'
    pod 'Nimble', git: 'https://github.com/Quick/Nimble.git', branch: 'swift-3.0'
end

target 'Keyboard' do
    pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
    pod 'SwiftHEXColors'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
