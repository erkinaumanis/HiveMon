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
@property (strong,nonatomic)    NSMutableDictionary *peripherals;

@end

@implementation BlueToothMGR

@synthesize centralMGR;
@synthesize wantsScan;
@synthesize blueDelegate;
@synthesize peripherals;


- (id)init {
    self = [super init];
    if (self) {
        wantsScan = NO;
        blueDelegate = nil;
        self.peripherals = [[NSMutableDictionary alloc] init];
        centralMGR = [[CBCentralManager alloc]
                      initWithDelegate:self
                      queue:nil
                      options:@{
                                CBCentralManagerOptionRestoreIdentifierKey: kBlueToothManagerKey
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
    NSLog(@"%s: state: %ld", __PRETTY_FUNCTION__, (long)central.state);
    NSString *err = nil;
    switch (central.state) {
        case CBManagerStatePoweredOn:
            break;
        case CBManagerStateUnknown:
            err = @"Unknown bluetooth state";
            break;
        case CBManagerStateResetting:
            NSLog(@"Bluetooth resetting");
//            err = @"Bluetooth resetting";
            return; // they will get back to us
        case CBManagerStateUnsupported:
            err = @"Bluetooth unsupported";
            break;
        case CBManagerStateUnauthorized:
            err = @"Bluetooth access unauthorized";
            break;
        case CBManagerStatePoweredOff:
            err = @"Bluetooth powered off";
    }
    [blueDelegate updateBluetoothStatus: err];
}

- (BOOL) scanable {
    return centralMGR.state == CBManagerStatePoweredOn;
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    BMData *data = [[BMData alloc] initFrom:advertisementData
                               inPeripheral:peripheral];
    if (!data)
        return;
    data.rssi = RSSI;

    peripheral.delegate = self;
    [self.peripherals setObject:peripheral forKey:peripheral.identifier];
    [centralMGR connectPeripheral:peripheral options:nil];
    [blueDelegate newData:data];
}

- (NSString *)P: (CBPeripheral *)p {
    NSString *uuid = p.identifier.UUIDString;
    return [uuid substringFromIndex:MAX((int)[uuid length]-3, 0)];
}

- (NSString *)S: (CBService *)s {
    NSString *uuid = s.UUID.UUIDString;
    return [uuid substringFromIndex:MAX((int)[uuid length]-3, 0)];
}

- (NSString *)C: (CBCharacteristic *)c {
    NSString *uuid = c.UUID.UUIDString;
    return [uuid substringFromIndex:MAX((int)[uuid length]-3, 0)];
}

- (NSString *) PS: (CBPeripheral *)p
          service:(CBService *)s {
    return [NSString stringWithFormat:@"%@/%@",
            [self P:p], [self S:s]];
}

- (NSString *) PC: (CBPeripheral *)p
    characteristic:(CBCharacteristic *)c{
    return [NSString stringWithFormat:@"%@/   /%@",
            [self P:p], [self C:c]];
}

- (NSString *) PSC: (CBPeripheral *)p
           service:(CBService *)s
    characteristic:(CBCharacteristic *)c{
    return [NSString stringWithFormat:@"%@/%@/%@",
            [self P:p], [self S:s], [self C:c]];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connected to %@", [self P:peripheral]);
    [blueDelegate updatePeripheralStatus];
    if (![peripherals objectForKey:peripheral.identifier]) {
        NSLog(@"!!! surprise peripheral");
    }
    [peripheral discoverServices:NULL];
}

- (void)centralManager:(CBCentralManager *)central
  didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral
                 error:(nullable NSError *)error {
    NSLog(@"%s, %@ (%@)", __PRETTY_FUNCTION__, peripheral, [error localizedDescription]);
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error{
//    NSLog(@"%s *** %@: %@", __PRETTY_FUNCTION__, peripheral.identifier, peripheral);
    for (CBService *service in peripheral.services) {
        NSLog(@"DS  %@  %@", [self PS:peripheral service:service], service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error; {
    for (CBCharacteristic *characteristic in service.characteristics) {
        BOOL readable = characteristic.properties & CBCharacteristicPropertyRead;
        NSLog(@"DC  %@ %@ %@  value:%@", [self PSC:peripheral service:service characteristic:characteristic],
              readable ? @"   " : @" NR",
              characteristic.UUID,
              characteristic.value);
        if (readable)
            [peripheral readValueForCharacteristic:characteristic];
    }
}

int propertyList[] = {
    CBCharacteristicPropertyBroadcast,
    CBCharacteristicPropertyRead,
    CBCharacteristicPropertyWriteWithoutResponse,
    CBCharacteristicPropertyWrite,
    CBCharacteristicPropertyNotify,
    CBCharacteristicPropertyIndicate,
    CBCharacteristicPropertyAuthenticatedSignedWrites,
    CBCharacteristicPropertyExtendedProperties,
    CBCharacteristicPropertyNotifyEncryptionRequired,
    CBCharacteristicPropertyIndicateEncryptionRequired,
    0
};

- (NSString *) CP: (CBCharacteristicProperties) cp {
    NSString *s = @"BRQWNIAXEE";
    NSString *flags = @"";
    for (int i=0; propertyList[i]; i++) {
        NSString *ch = [s substringWithRange:NSMakeRange(i, 1)];
        NSString *f = (cp & propertyList[i]) ? ch : [ch lowercaseString];
        flags = [f stringByAppendingString:flags];
    }
    return [NSString stringWithFormat:@"%03x:%@", cp, flags];
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"UV  %@ %@ v:%@ %@ %@", [self PC:peripheral characteristic:characteristic],
          [self CP:characteristic.properties],
          characteristic.value,
          characteristic.isNotifying ? @"Y" : @"N",
          error ? [error localizedDescription] : @"");
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"UNS %@ %@ %@", [self PC:peripheral characteristic:characteristic], characteristic,
          error ? [error localizedDescription] : @"");
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"disconnect %@ %@", [self P:peripheral],
          error ? [error localizedDescription] : @"");
}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray<CBPeripheral *> *)peripherals {
    NSLog(@" YYYY %s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray<CBPeripheral *> *)peripherals {
    NSLog(@" YYYY %s", __PRETTY_FUNCTION__);
}

- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSLog(@" YYYY %s", __PRETTY_FUNCTION__);
}

@end

