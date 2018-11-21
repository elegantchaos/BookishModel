cd Dependencies
swift package update
rm -rf ".build/xcode"

#swift package generate-xcodeproj --xcconfig-overrides "Configs/BookishCoreMac.xcconfig"
#mv BookishModelDependencies.xcodeproj BookishModelDependenciesMac.xcodeproj
#swift package generate-xcodeproj --xcconfig-overrides "Configs/BookishCoreMobile.xcconfig"
#mv BookishModelDependencies.xcodeproj BookishModelDependenciesMobile.xcodeproj

swift package generate-xcodeproj --output ".build/xcode/mac" --xcconfig-overrides "Configs/BookishCoreMac.xcconfig"
swift package generate-xcodeproj --output ".build/xcode/mobile" --xcconfig-overrides "Configs/BookishCoreMobile.xcconfig"

#ln -sf "$PWD/.build/xcode/mac/BookishModelDependencies.xcodeproj" ../BookishModelDependenciesMac.xcodeproj
#ln -sf "$PWD/.build/xcode/mobile/BookishModelDependencies.xcodeproj" ../BookishModelDependenciesMobile.xcodeproj

pushd .build/xcode/mac
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMac.xcodeproj
popd

pushd .build/xcode/mobile
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMobile.xcodeproj
popd

