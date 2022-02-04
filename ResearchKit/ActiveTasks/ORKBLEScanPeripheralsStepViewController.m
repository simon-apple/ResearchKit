/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

// apple-internal

#if APPLE_INTERNAL

#import <ResearchKit/ORKFeatureFlags.h>

#if ORK_FEATURE_BLE_SCAN_PERIPHERALS

#import "ORKBLEScanPeripheralsStepViewController.h"
#import "ORKBLEScanPeripheralsStep.h"
#import "ORKBLEScanPeripheralsStepResult.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKInstructionStepContainerView.h"

#import "ORKHelpers_Internal.h"

@import CoreBluetooth;

static NSString * const ORKBLEScanPeripheralsSectionIdentifier = @"ORKBLEScanPeripheralsSectionIdentifier";
static NSString * const ORKBLEScanCellReuseIdentifier = @"ORKBLEScanCellReuseIdentifier";

static const NSUInteger ORK_BLE_MIN_CONNECTIONS_DEFAULT = 1;
static const NSUInteger ORK_BLE_MAX_ALLOWABLE_CONNECTIONS = 5;
static const NSTimeInterval ORK_BLE_CONNECTION_TIMEOUT = 5;

typedef NS_ENUM(NSUInteger, ORKBLEPeripheralState) {
    ORKBLEPeripheralStateDiscovered,
    ORKBLEPeripheralStatePending,
    ORKBLEPeripheralStateConnected,
    ORKBLEPeripheralStateUnavailable
};

typedef NS_ENUM(NSUInteger, ORKBLEScanPeripheralsStepPhase) {
    ORKBLEScanPeripheralsStepPhaseInvalidCentralManager = 0,
    ORKBLEScanPeripheralsStepPhaseIdle,
    ORKBLEScanPeripheralsStepPhaseScanning,
    ORKBLEScanPeripheralsStepPhaseDevicesAvailable,
    ORKBLEScanPeripheralsStepPhaseNoDevicesFound
};

API_AVAILABLE(ios(13.0))
@interface ORKBLEScanPeripheralsStepViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate>
@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic, assign) NSUInteger minConnections;
@property (nonatomic, assign) NSUInteger maxAllowableConnections;
@property (nonatomic, copy) NSString *deviceNameFilterArg;
@property (atomic, strong) NSMutableDictionary<CBPeripheral *, NSNumber *> *peripherals;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSObject<UITableViewDataSource> *dataSource;

@property (nonatomic, assign) ORKBLEScanPeripheralsStepPhase phase;
@end

@implementation ORKBLEScanPeripheralsStepViewController

- (void)setPhase:(ORKBLEScanPeripheralsStepPhase)phase {
    _phase = phase;
    
    switch (_phase) {
        case ORKBLEScanPeripheralsStepPhaseInvalidCentralManager:
            [self setStepTitle:ORKLocalizedString(@"BLE_UNABLE_TO_SCAN_TITLE", nil) stepDetailText:ORKLocalizedString(@"BLE_UNABLE_TO_SCAN_MSG", nil)];
            break;
        case ORKBLEScanPeripheralsStepPhaseIdle:
        case ORKBLEScanPeripheralsStepPhaseScanning:
            [self setStepTitle:ORKLocalizedString(@"BLE_SCANNING_TITLE", nil) stepDetailText:ORKLocalizedString(@"BLE_SCANNING_MSG", nil)];
            break;
        case ORKBLEScanPeripheralsStepPhaseDevicesAvailable:
            [self setStepTitle:ORKLocalizedString(@"BLE_DEVICES_AVAILABLE_TITLE", nil) stepDetailText:ORKLocalizedString(@"BLE_DEVICES_AVAILABLE_MSG", nil)];
            break;
        case ORKBLEScanPeripheralsStepPhaseNoDevicesFound:
            [self setStepTitle:ORKLocalizedString(@"BLE_NO_DEVICES_TITLE", nil) stepDetailText:ORKLocalizedString(@"BLE_NO_DEVICES_MSG", nil)];
            break;
    }
}

- (void)setStepTitle:(NSString * _Nullable)stepTitle stepDetailText:(NSString * _Nullable)stepDetailText {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (stepTitle) {
            self.stepView.stepTitle = [stepTitle copy];
        }
        if (stepDetailText) {
            self.stepView.stepDetailText = [stepDetailText copy];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phase = ORKBLEScanPeripheralsStepPhaseIdle;
    
    NSMutableDictionary *centralOptions = [[NSMutableDictionary alloc] initWithDictionary:@{CBCentralManagerOptionShowPowerAlertKey : @(YES)}];
    
    NSString *restorationIdentifier = (NSString *)[[self scanStep] scanOptions][ORKBLEScanPeripheralsRestorationIdentifierKey];
    
    if (restorationIdentifier != nil) {
        [centralOptions setValue:restorationIdentifier forKey:CBCentralManagerOptionRestoreIdentifierKey];
    }
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
                                                             options:centralOptions];
    
    self.maxAllowableConnections = [(NSNumber *)[[self scanStep] scanOptions][ORKBLEScanPeripheralsCapacityKey] unsignedIntegerValue];
    if (self.maxAllowableConnections == 0 || self.maxAllowableConnections > ORK_BLE_MAX_ALLOWABLE_CONNECTIONS) {
        self.maxAllowableConnections = ORK_BLE_MAX_ALLOWABLE_CONNECTIONS;
    }
    
    self.minConnections = [(NSNumber *)[[self scanStep] scanOptions][ORKBLEScanPeripheralsMinimumConnectionCountKey] unsignedIntegerValue];
    if (self.minConnections < ORK_BLE_MIN_CONNECTIONS_DEFAULT) {
        self.minConnections = ORK_BLE_MIN_CONNECTIONS_DEFAULT;
    }
    
    self.deviceNameFilterArg = (NSString *)[[self scanStep] scanOptions][ORKBLEScanPeripheralsFilterDeviceNameKey];
    
    [self setContinueButtonEnabled:NO];
}

- (ORKBLEScanPeripheralsStep * _Nullable)scanStep {
    
    if ([[self step] isKindOfClass:[ORKBLEScanPeripheralsStep class]]) {
        return (ORKBLEScanPeripheralsStep *)[self step];
    }
    
    return nil;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:sResult.results];
    
    ORKBLEScanPeripheralsStepResult *scanResult = [[ORKBLEScanPeripheralsStepResult alloc] initWithIdentifier:self.step.identifier];
    scanResult.connectedPeripherals = [self.peripherals.allKeys copy];
    scanResult.centralManager = self.centralManager;
    
    [results addObject:scanResult];
    
    sResult.results = [results copy];
    
    return sResult;
}

- (void)loadTableView {
        
    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ORKBLEScanCellReuseIdentifier];
    }

    self.stepView.customContentView = self.tableView;
    self.stepView.customContentFillsAvailableSpace = YES;
    
    if (@available(iOS 13.0, *)) {
        self.dataSource = [self diffableDataSource];
    }
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
}

- (UITableViewDiffableDataSource *)diffableDataSource API_AVAILABLE(ios(13.0)) {
   
    __weak typeof(self) weakSelf = self;
    
    return [[UITableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf && ![itemIdentifier isEmpty]) { return nil; }
            
        CBPeripheral *peripheral = [[strongSelf.peripherals allKeys] objectAtIndex:(NSUInteger)indexPath.row];
        ORKBLEPeripheralState state = [[strongSelf.peripherals objectForKey:peripheral] unsignedIntValue];
            
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ORKBLEScanCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // TODO: This belongs in a seperate UITableViewCell
        if (peripheral.name) {
            cell.textLabel.text = peripheral.name;
        } else {
            cell.textLabel.text = [peripheral.identifier UUIDString];
        }
        
        cell.accessoryView = nil;
        
        switch (state) {
            case ORKBLEPeripheralStatePending:
            {
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                cell.accessoryView = activityView;
                [activityView startAnimating];
                break;
            }
            case ORKBLEPeripheralStateConnected:
            {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle"]];
                cell.accessoryView.tintColor = [UIColor systemGreenColor];
                break;
            }
            case ORKBLEPeripheralStateUnavailable:
            {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"exclamationmark.triangle"]];
                cell.accessoryView.tintColor = [UIColor systemOrangeColor];
                break;
            }
            default:
                cell.accessoryView = nil;
                break;
        }
        

        return cell;
    }];
}

#pragma mark - WIP Potential Delegate Decoupling

- (void)startScanningWithCentral:(CBCentralManager *)central {
    
    [central scanForPeripheralsWithServices:nil options:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.phase = ORKBLEScanPeripheralsStepPhaseScanning;
        [self loadTableView];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ORK_BLE_CONNECTION_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.peripherals count] == 0) {
            self.phase = ORKBLEScanPeripheralsStepPhaseNoDevicesFound;
        }
    });
}

- (NSUInteger)connectedPeripheralsCount {
    NSUInteger connectionCount = 0;

    for (NSNumber *state in self.peripherals.allValues) {
        if (state.unsignedIntValue == ORKBLEPeripheralStateConnected) {
            connectionCount = connectionCount + 1;
        }
    }
    
    return connectionCount;
}

- (BOOL)shouldStopScaning {
    return [self connectedPeripheralsCount] >= self.maxAllowableConnections;
}

- (BOOL)shouldAllowContinue {
    return [self connectedPeripheralsCount] >= self.minConnections;
}

- (void)stopScanningWithCentral:(CBCentralManager *)central {
    [central stopScan];
}

- (void)addPeripheral:(CBPeripheral *)peripheral to:(NSMutableDictionary<CBPeripheral *, NSNumber *> *)peripherals {
    
    NSUInteger index = [peripherals.allKeys indexOfObjectPassingTest:^BOOL(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.name isEqualToString:peripheral.name] || [obj.identifier isEqual:peripheral.identifier]) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    }];
    
    if (index == NSNotFound) {
            
        [peripherals setObject:@(ORKBLEPeripheralStateDiscovered) forKey:peripheral];
        [peripheral setDelegate:self];
            
        if (@available(iOS 13.0, *)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[peripherals copy]];
            });
        }
    }
    
    if (self.peripherals.count > 0) {
        self.phase = ORKBLEScanPeripheralsStepPhaseDevicesAvailable;
    }
}

- (void)diffableDataSource:(UITableViewDiffableDataSource *)dataSource applySnapshotForNewPeripherals:(NSDictionary<CBPeripheral *, NSNumber *> *)peripherals API_AVAILABLE(ios(13.0)) {
    
    NSDiffableDataSourceSnapshot *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];

    [snapshot appendSectionsWithIdentifiers:@[ORKBLEScanPeripheralsSectionIdentifier]];
    
    [dataSource applySnapshot:snapshot animatingDifferences:NO];
    
    for (CBPeripheral *peripheral in peripherals.allKeys) {
        [snapshot appendItemsWithIdentifiers:@[peripheral.identifier] intoSectionWithIdentifier:ORKBLEScanPeripheralsSectionIdentifier];
        [snapshot reloadItemsWithIdentifiers:@[peripheral.identifier]];
    }
    
    [dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)showConnectionAlertForPeripheral:(CBPeripheral *)peripheral {
    
    if (ORKBLEPeripheralStateConnected == [[self.peripherals objectForKey:peripheral] unsignedIntValue]) { return; }
        
    [self.peripherals setObject:@(ORKBLEPeripheralStateUnavailable) forKey:peripheral];
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContinueButtonEnabled:[self shouldAllowContinue]];
    });
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"BLE_NOT_CONNECTED_TITLE", nil) message:ORKLocalizedString(@"BLE_NOT_CONNECTED_MSG", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OK", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:^{
        
        [self.centralManager cancelPeripheralConnection:peripheral];
        
        [self.peripherals removeObjectForKey:peripheral];
        
        if (@available(iOS 13.0, *)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
            });
        }
        
        self.phase = self.peripherals.count > 0 ? ORKBLEScanPeripheralsStepPhaseDevicesAvailable : ORKBLEScanPeripheralsStepPhaseNoDevicesFound;
    }];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    
    [self.centralManager cancelPeripheralConnection:peripheral];
    
    [self.peripherals removeObjectForKey:peripheral];
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [self startScanningWithCentral:central];
            break;
        default:
            [self stopScanningWithCentral:central];
            self.phase = ORKBLEScanPeripheralsStepPhaseInvalidCentralManager;
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
        
    if (![(NSNumber *)advertisementData[CBAdvertisementDataIsConnectable] boolValue]) {
        return;
    }
        
    if (!(peripheral.name || advertisementData[CBAdvertisementDataLocalNameKey])) {
        return;
    }
        
    if (self.peripherals == nil) {
        self.peripherals = [[NSMutableDictionary alloc] init];
    }
        
    if (self.deviceNameFilterArg) {
            
        NSString *peripheralNameGAP = peripheral.name;
        NSString *peripheralNameAdv = advertisementData[CBAdvertisementDataLocalNameKey];
            
        if ([peripheralNameGAP containsString:self.deviceNameFilterArg] || [peripheralNameAdv containsString:self.deviceNameFilterArg]) {
            [self addPeripheral:peripheral to:self.peripherals];
        }
        
    } else {
        [self addPeripheral:peripheral to:self.peripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self.peripherals setObject:@(ORKBLEPeripheralStateConnected) forKey:peripheral];
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
    
    if ([self shouldStopScaning]) {
        [self stopScanningWithCentral:central];
        self.phase = ORKBLEScanPeripheralsStepPhaseIdle;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContinueButtonEnabled:[self shouldAllowContinue]];
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self.peripherals setObject:@(ORKBLEPeripheralStateUnavailable) forKey:peripheral];
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
            
            [self showConnectionAlertForPeripheral:peripheral];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContinueButtonEnabled:[self shouldAllowContinue]];
    });
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self.peripherals removeObjectForKey:peripheral];
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContinueButtonEnabled:[self shouldAllowContinue]];
    });
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
}

#pragma mark - UITableViewDelegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *disconnectAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                   title:ORKLocalizedString(@"BLE_DISCONNECT", nil)
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CBPeripheral *peripheral = [[self.peripherals allKeys] objectAtIndex:(NSUInteger)indexPath.row];
        ORKBLEPeripheralState state = [[self.peripherals objectForKey:peripheral] unsignedIntegerValue];
        if (state == ORKBLEPeripheralStateConnected) {
            [self disconnectPeripheral:peripheral];
        }
        completionHandler(true);
    }];
    
    if (@available(iOS 13.0, *)) {
        disconnectAction.image = [UIImage systemImageNamed:@"minus.circle.fill"];
    }
    
    return [UISwipeActionsConfiguration configurationWithActions:@[disconnectAction]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheral = [[self.peripherals allKeys] objectAtIndex:(NSUInteger)indexPath.row];
    ORKBLEPeripheralState state = [[self.peripherals objectForKey:peripheral] unsignedIntValue];
    
    switch (state) {
        case ORKBLEPeripheralStateDiscovered:
        {
            [self.peripherals setObject:@(ORKBLEPeripheralStatePending) forKey:peripheral];
            [self.centralManager connectPeripheral:peripheral options:nil];
            __weak typeof(peripheral) weakPeripheral = peripheral;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ORK_BLE_CONNECTION_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (@available(iOS 13.0, *)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakPeripheral) {
                            [self showConnectionAlertForPeripheral:weakPeripheral];
                        }
                    });
                }
            });
            break;
        }
        case ORKBLEPeripheralStatePending:
        case ORKBLEPeripheralStateConnected:
            break;
        case ORKBLEPeripheralStateUnavailable:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showConnectionAlertForPeripheral:peripheral];
            });
            break;
        }
    }
    
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self diffableDataSource:(UITableViewDiffableDataSource *)self.dataSource applySnapshotForNewPeripherals:[self.peripherals copy]];
        });
    }
}

@end

#endif

#endif
