echo Updating packages
swift package resolve
swift package show-dependencies

echo Generating Xcode Projects
swift package generate-xcodeproj --output "Dependencies/Mac" --xcconfig-overrides "Configs/BookishModelMac.xcconfig"
swift package generate-xcodeproj --output "Dependencies/Mobile" --xcconfig-overrides "Configs/BookishModelMobile.xcconfig"

pushd Dependencies/Mac
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMac.xcodeproj
popd

pushd Dependencies/Mobile
ln -sf BookishModelDependencies.xcodeproj BookishModelDependenciesMobile.xcodeproj
popd

echo Update Done
