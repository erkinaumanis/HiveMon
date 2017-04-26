//
//  BMData.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Observation.h"

typedef enum BMdevice_t {
    BMScale,
    BMSensor,
    BMUnknown,
} BMdevice_t;

@interface BMData : NSObject {
    CBPeripheral *peripheral;
    NSDate *timeStamp;
    NSNumber *rssi;
    BMdevice_t type;
    int battery;
    int samples;
    int temperature;
    int humidity;
    double leftWeight;     // Scales...
    double rightWeight;    // ... only
}

@property (strong, nonatomic)   CBPeripheral *peripheral;
@property (strong, nonatomic)   NSDate *timeStamp;
@property (strong, nonatomic)   NSNumber *rssi;
@property (assign)              BMdevice_t type;
@property (assign)              int battery;
@property (assign)              int samples;
@property (assign)              int temperature;
@property (assign)              int humidity;
@property (assign)              double leftWeight;
@property (assign)              double rightWeight;

- (id)initFrom: (NSDictionary <NSString *,id> *)advertisementData
        inPeripheral:(CBPeripheral *) p;
- (NSString *) internalName;
- (BOOL) isScale;
- (Observation *) makeObservation;

@end
