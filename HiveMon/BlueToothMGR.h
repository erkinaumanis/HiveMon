//
//  BlueToothMGR.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BMData.h"


@protocol BlueDelegate <NSObject>

- (void) newData: (BMData *)data;
- (void) updateBluetoothStatus: (NSString *)error;
- (void) updatePeripheralStatus;

@end

@interface BlueToothMGR: NSObject
    <CBCentralManagerDelegate,
    CBPeripheralDelegate> {
    __unsafe_unretained id<BlueDelegate> blueDelegate;
}

@property (assign)  __unsafe_unretained id<BlueDelegate> blueDelegate;

- (void) startScan;
- (void) stopScan;
- (BOOL) scanable;

@end
