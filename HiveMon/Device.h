//
//  Device.h
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Hive.h"
#import "Observation.h"

@interface Device : NSObject {
    NSDate *lastReport;     // when we last sent info about this
    NSString *name;
    NSString *displayLabel; // not used for lookups
    BOOL isScale;
    NSString *hiveName;
    NSString *apiaryName;
    Observation *lastObservation;
    CBPeripheral *peripheral;   // not saved between sessions
}

@property (nonatomic, strong)   NSDate *lastReport;
@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSString *displayLabel;
@property (assign)              BOOL isScale;
@property (nonatomic, strong)   NSString *hiveName;
@property (nonatomic, strong)   NSString *apiaryName;
@property (nonatomic, strong)   Observation *lastObservation;
@property (nonatomic, strong)   CBPeripheral *peripheral;

- (NSString *) statusString;
- (NSString *) detailStatus;

@end
