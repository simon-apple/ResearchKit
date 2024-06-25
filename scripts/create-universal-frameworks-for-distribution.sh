# This is a function that can create a distributable XCFramework
# We will run this function on a few RK Targets
# ResearchKit, ResearchKitActiveTask, ResearchKitUI
# By Building the ResearchKitAllTargets target, this will be run automatically
# The XCFrameworks will be available in the xcframeworks folder
function build_and_create_xcframework() {
  local SCHEME_NAME=$1
  local FRAMEWORK_NAME=$2
  SIMULATOR_ARCHIVE_PATH="$BUILD_DIR/${CONFIGURATION}/${FRAMEWORK_NAME}-iphonesimulator.xcarchive"
  DEVICE_ARCHIVE_PATH="$BUILD_DIR/${CONFIGURATION}/${FRAMEWORK_NAME}-iphoneos.xcarchive"
  OUTPUT_DIC="./xcframework/"
  # Build simulator xcarchive
  xcodebuild archive \
    -scheme "${SCHEME_NAME}" \
    -archivePath "${SIMULATOR_ARCHIVE_PATH}" \
    -sdk iphonesimulator \
    SKIP_INSTALL=NO
  # Build device xcarchive
  xcodebuild archive \
    -scheme "${SCHEME_NAME}" \
    -archivePath "${DEVICE_ARCHIVE_PATH}" \
    -sdk iphoneos \
    SKIP_INSTALL=NO

  # Create xcframework
  xcodebuild -create-xcframework \
    -framework "${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${OUTPUT_DIC}/${FRAMEWORK_NAME}.xcframework"
}

# Clean up old output directory
rm -rf "./xcframework/"

build_and_create_xcframework ResearchKit ResearchKit
build_and_create_xcframework ResearchKitActiveTask ResearchKitActiveTask
build_and_create_xcframework ResearchKitUI ResearchKitUI
