swift package update

swift package generate-xcodeproj --output "Dependencies/Mac" --xcconfig-overrides "Configs/BookishModelMac.xcconfig"
swift package generate-xcodeproj --output "Dependencies/Mobile" --xcconfig-overrides "Configs/BookishModelMobile.xcconfig"


ln -sf BookishModelDependencies.xcodeproj Dependencies/Mac/BookishModelDependenciesMac.xcodeproj
ln -sf BookishModelDependencies.xcodeproj Dependencies/Mobile/BookishModelDependenciesMobile.xcodeproj

