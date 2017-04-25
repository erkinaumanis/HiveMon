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

@end

@interface BlueToothMGR: NSObject
<CBCentralManagerDelegate> {
    __unsafe_unretained id<BlueDelegate> delegate;
}

@property (assign)  __unsafe_unretained id<BlueDelegate> delegate;

- (void) startScan;
- (void) stopScan;

@end
