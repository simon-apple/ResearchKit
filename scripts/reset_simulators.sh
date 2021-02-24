killall "Simulator" 2> /dev/null || true
echo "== Deleting All Simulators =="
xcrun simctl delete all
echo "== Creating Simulators =="
# You can get a list of devicetype ids and runtime ids by running: `xcrun simctl list devicetypes runtimes`
# YukonB
xcrun simctl create "iPhone YukonB" com.apple.CoreSimulator.SimDeviceType.iPhone-XR com.apple.CoreSimulator.SimRuntime.iOS-13-2
# Auzl and Hunter, Hunter is the first version that supports XCTest on watch
AZUL_IPHONE_UUID=$(xcrun simctl create "iPhone Azul" com.apple.CoreSimulator.SimDeviceType.iPhone-XR)
HUNTER_WATCH_UUID=$(xcrun simctl create "Apple Watch Hunter" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-6-44mm)
xcrun simctl pair $AZUL_IPHONE_UUID $HUNTER_WATCH_UUID
# USF Simualtors
xcrun simctl create "iPhone Xs" com.apple.CoreSimulator.SimDeviceType.iPhone-XS com.apple.CoreSimulator.SimRuntime.iOS-13-2
xcrun simctl create "iPhone Xs" com.apple.CoreSimulator.SimDeviceType.iPhone-XS
# Legacy Simulators
xcrun simctl create "iPhone Xʀ" com.apple.CoreSimulator.SimDeviceType.iPhone-XR com.apple.CoreSimulator.SimRuntime.iOS-13-2
xcrun simctl create "iPhone Xʀ" com.apple.CoreSimulator.SimDeviceType.iPhone-XR
echo "== Results =="
# Print out the devices and pairings for review
xcrun simctl list devices pairs
