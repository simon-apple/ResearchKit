/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import XCTest

final class SettingsAppScreens {
    
    static let app = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    
    /// Activate and terminate Settings app to start from the known state
    func terminateAndLaunchApp() -> Self {
        Self.app.activate()
        Self.app.terminate()
        Self.app.activate()
        return self
    }
    
    static var bluetoothCell: XCUIElement {
        app.cells.staticTexts["Bluetooth"]
    }
    
    static var bluetoothNavigationButton: XCUIElement {
        app.buttons["Bluetooth"]
    }
    
    /// Provides descriptive failure message if headphones not connected
    func getConnectedDevicesLabels() -> String {
        navigateToBluetoothFromSettingsScreen()
        let allCells = Self.app.cells.allElementsBoundByIndex
        var connectedDevices: [XCUIElement] = []
        for cell in allCells {
            if let cellValue = cell.value as? String {
                if cellValue == "Connected" {
                    connectedDevices.append(cell)
                }
            }
        }
        if connectedDevices.isEmpty {
            return "No headphones connected"
        }
        var message = "Found the following connected devices: "
        for (n, connectedDevice) in connectedDevices.enumerated() {
            message += "\(n+1). \(connectedDevice.label)"
        }
        return message
    }
    
    /// Bluetooth connected devices list screen
    /// Taps blue info button for connected device
    func tapConnectedDeviceInfoButton() {
        let allCells = Self.app.cells.allElementsBoundByIndex
        for cell in allCells {
            if let cellValue = cell.value as? String {
                if cellValue == "Connected" {
                    let infoButton = cell.buttons.element.firstMatch
                    infoButton.tap()
                    return
                }
            }
        }
        XCTFail("No connected devices found")
    }
    
    func applyHeadphonesSettings(disableAutomaticEarDetection: Bool, enableNoiseCancellation: Bool, headphoneType: HeadphoneDetectStepScreen.HeadphoneType) {
        navigateToBluetoothFromSettingsScreen()
        tapConnectedDeviceInfoButton()
        
        if disableAutomaticEarDetection {
            disableAutomaticEarDetectionIfEnabled(headphoneType: headphoneType)
        }
        if enableNoiseCancellation {
            enableAirPodsMode(mode: .noiseCancellation)
        }
        navigateToBluetoothFromConnectedDevice()
    }
    
    enum AirPodsMode: String {
        case transparency = "Transparency"
        case noiseCancellation = "Noise Cancellation"
    }
    
    func enableAirPodsMode(mode: AirPodsMode) {
        let requiredModeButton = Self.app.buttons[mode.rawValue].firstMatch
        if requiredModeButton.waitForExistence(timeout: 20) {
            requiredModeButton.tap()
            wait(for: requiredModeButton, toBeSelected: true)
        }
    }

    func turnOnAirPodsModeFromSettingsScreen(mode: AirPodsMode) {
        navigateToBluetoothFromSettingsScreen()
        tapConnectedDeviceInfoButton()
        enableAirPodsMode(mode: mode)
        navigateToBluetoothFromConnectedDevice()
    }

    /// Makes sure "Automatic Ear Detection" is disabled
    /// "Automatic Ear Detection"  should be off because it's required to run test without having to wear headphones
    func disableAutomaticEarDetectionIfEnabled(headphoneType: HeadphoneDetectStepScreen.HeadphoneType) {
        let automaticEarDetectionSwitch = Self.app.switches["Automatic Ear Detection"].firstMatch
        guard automaticEarDetectionSwitch.waitForExistence(timeout: 20) else {
            navigateToBluetoothFromConnectedDevice()
            /// Add a list of connected devices in the failure message when the required headphones are not detected as connected
            let connectedDevicesFailureMessage = getConnectedDevicesLabels()
            XCTFail("\(headphoneType.rawValue) not connected. List of connected devices: \(connectedDevicesFailureMessage)")
            return
        }
        var switchValue = automaticEarDetectionSwitch.value as? String
        guard let switchCurrentValue = switchValue else {
            XCTFail("Automatic Ear Detection Switch value found to be nil")
            return
        }
        if switchCurrentValue != "0" {
            automaticEarDetectionSwitch.tap()
            sleep(3) /// Allow ui view to settle
        }
        switchValue = automaticEarDetectionSwitch.value as? String
        XCTAssertEqual(switchValue ?? "", "0", "The switch should be off")
    }

    func navigateToBluetoothFromSettingsScreen() {
        terminateAndLaunchApp()
        wait(for: Self.bluetoothCell)
        Self.bluetoothCell.tap()
        wait(for: Self.bluetoothCell) /// Bluetooth screen
    }
    
    func navigateToBluetoothFromConnectedDevice() {
        Self.bluetoothNavigationButton.tap() /// Tap "Bluetooth" navigation button to go back to list of connected devices
        wait(for: Self.bluetoothCell)
    }

    @discardableResult
    private func navigateToPrivacyandSecurityInSettings() -> Self {
        let privacyAndSecurityCellIdentifier = "Privacy"
        let privacyAndSecurityCell = Self.app.cells[privacyAndSecurityCellIdentifier].firstMatch
        if privacyAndSecurityCell.waitForExistence(timeout: 20) {
            privacyAndSecurityCell.tap()
            // Verify that app is navigated to "Privacy and Security"
            let privacyView = Self.app.navigationBars["Privacy & Security"].firstMatch
            if !privacyView.waitForExistence(timeout: 15) {
                privacyAndSecurityCell.tap()
            }
        }
        return self
    }

    @discardableResult
    private func navigateToLocationServicesInPrivacyandSecurity() -> Self {
        let locationServicesLabelIdentifier = "LOCATION"
        let locationServicesLabel = Self.app.staticTexts[locationServicesLabelIdentifier].firstMatch
        if locationServicesLabel.waitForExistence(timeout: 20) {
            locationServicesLabel.tap()
        }
        return self
    }

    @discardableResult
    private func enableLocationServicesInPrivacyandSecurity() -> Self {
        let locationServicesSwitch = Self.app.cells["Location Services"].switches.firstMatch
        XCTAssert(locationServicesSwitch.waitForExistence(timeout: 20))
        guard let locationSwitchCurrentValue = locationServicesSwitch.value as? String else {
            XCTFail("Unable to retrieve Location Services switch value. It is found to be nil")
            return self
        }
        if locationSwitchCurrentValue != "1" {
            locationServicesSwitch.tap() // enable switch
            sleep(5) // Allow UI to settle
            guard let locationSwitchToggledValue = locationServicesSwitch.value as? String else {
                XCTFail("Unable to retrieve Location Services switch value. It is found to be nil")
                return self
            }
            XCTAssertEqual(locationSwitchToggledValue, "1", "Location Services switch should be on")
        }
        return self
    }

    /// Enable Location Services in "Privacy & Security"
    /// We need to enable Location Services when running UI Test in Xcode Cloud Environment on device compute devices
    /// Note: XCTestInternal has an API to adjust location services for an app:
    /// https://docs.apple.com/access/general/documentation/xctestinternal/xctiapplication/setlocationservices(tostate:)
    /// XCTIDevice.current.setLocationServices(toState:, forBundleIdentifier:) or
    /// XCTIDevice.current.doCommand(withLaunchPath: "/usr/local/bin/loctool", command: ["authorize", "bundleID", "1"])
    @discardableResult
    func enableLocationServices() -> Self {
        // Tap "Privacy & Security" cell in Settings
        self.navigateToPrivacyandSecurityInSettings()

        // Tap "Location Services" cell in "Privacy & Security"
        self.navigateToLocationServicesInPrivacyandSecurity()

        // Enable "Location Services" switch
        self.enableLocationServicesInPrivacyandSecurity()
        return self
    }
}
