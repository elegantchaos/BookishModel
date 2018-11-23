echo Updating packages
xcrun swift package resolve

echo Generating Xcode Projects
xcrun swift package generate-xcodeproj --output "Dependencies/Mac" --xcconfig-overrides "Configs/BookishModelMac.xcconfig"
xcrun swift package generate-xcodeproj --output "Dependencies/Mobile" --xcconfig-overrides "Configs/BookishModelMobile.xcconfig"

pushd Dependencies/Mac
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMac.xcodeproj
popd

pushd Dependencies/Mobile
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMobile.xcodeproj
popd

echo Update Done
