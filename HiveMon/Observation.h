//
//  Observation.h
//  HiveMon
//
//  Created by ches on 17/4/26.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Observation : NSObject {
    NSNumber *rssi;
    int battery;
    int samples;
    int temperature;
    int humidity;
    double weight;     // Scales  only
}

@property (strong, nonatomic)   NSNumber *rssi;
@property (assign)              int battery;
@property (assign)              int samples;
@property (assign)              int temperature;
@property (assign)              int humidity;
@property (assign)              double weight;

@end
