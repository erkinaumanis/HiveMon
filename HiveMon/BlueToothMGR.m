//
//  BlueToothMGR.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Defines.h"
#import "BlueToothMGR.h"

@interface BlueToothMGR ()

@property (nonatomic, strong)   CBCentralManager *centralMGR;
@property (assign)              BOOL wantsScan;

@end

@implementation BlueToothMGR

@synthesize centralMGR;
@synthesize wantsScan;
@synthesize delegate;


- (id)init {
    self = [super init];
    if (self) {
        wantsScan = NO;
        centralMGR = [[CBCentralManager alloc]
                      initWithDelegate:self
                      queue:nil
                      options:@{
                                CBCentralManagerOptionRestoreIdentifierKey: kBlueToothRestoreKey
                            }];
    }
    return self;
}

- (void) stopScan {
    [centralMGR stopScan];
}

- (void) startScan {
    if (centralMGR.state == CBManagerStatePoweredOn) {
        [centralMGR scanForPeripheralsWithServices:nil options:nil];
        return;
    }
    // Wait for the powered-on state
    wantsScan = YES;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            if (wantsScan)
                [self startScan];
            break;
        case CBManagerStateUnknown:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
        case CBManagerStatePoweredOff:
            NSLog(@"      state: %ld", (long)central.state);
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
//    NSString *name = peripheral.name;
    
    Peripheral *pReported = [[Peripheral alloc] init];
    pReported.peripheral = peripheral;
    pReported.advertisementData = advertisementData;
    if (![pReported isBroodMinder]) {
        return;
    }

//    NSUUID *appleID = peripheral.identifier;
//    NSLog(@"%@  %3@  %@", appleID, RSSI, name);
//    NSLog(@"   ad: %@", advertisementData);
    [delegate discoveredBM:pReported];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray<CBPeripheral *> *)peripherals {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray<CBPeripheral *> *)peripherals {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

