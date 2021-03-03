killall "Simulator" 2> /dev/null || true
echo "== Deleting All Simulators =="
xcrun simctl delete all
echo "== Creating Simulators =="
# examples:
# iPhone 12 with the latest iOS runtime
# xcrun simctl create "iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-12
# iPhone 11 with a specific iOS runtime
# xcrun simctl create "iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-11 com.apple.CoreSimulator.SimRuntime.iOS-14-3
# You can get a list of devicetype ids and runtime ids by running: `xcrun simctl list devicetypes runtimes`
xcrun simctl create "iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-XR
echo "== Results =="
# Print out the devices and pairings for review
xcrun simctl list devices pairs
