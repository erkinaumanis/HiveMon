//
//  Peripheral.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Peripheral : NSObject {
    CBPeripheral *peripheral;
    NSDictionary<NSString *,id> *advertisementData;
    NSNumber *rssi;
}

@property (strong, nonatomic)   CBPeripheral *peripheral;
@property (strong, nonatomic)   NSDictionary<NSString *,id> *advertisementData;
@property (strong, nonatomic)   NSNumber *rssi;

- (BOOL) isBroodMinder;
- (BOOL) isScale;
- (NSString *) internalName;
- (float) battery;
- (int) temperature;
- (int) humidity;

@end
