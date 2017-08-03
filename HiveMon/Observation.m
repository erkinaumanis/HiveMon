//
//  Observation.m
//  HiveMon
//
//  Created by ches on 17/4/26.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Observation.h"

#define kTimeStamp  @"TimeStamp"
#define kRSSI       @"RSSI"
#define kBattery    @"Battery"
#define kSamples    @"Samples"
#define kTemp       @"Temp"
#define kHumidity   @"Humidity"
#define kWeight     @"Weight"

@implementation Observation

@synthesize timeStamp;
@synthesize rssi;
@synthesize battery;
@synthesize samples;
@synthesize temperature;
@synthesize humidity;
@synthesize weight;


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        timeStamp = [coder decodeObjectForKey:kTimeStamp];
        rssi = [coder decodeObjectForKey: kRSSI];
        battery = [coder decodeIntForKey:kBattery];
        samples = [coder decodeIntForKey: kSamples];
        temperature = [coder decodeIntForKey: kTemp];
        humidity = [coder decodeIntForKey: kHumidity];
        weight = [coder decodeDoubleForKey: kWeight];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:timeStamp forKey:kTimeStamp];
    [coder encodeObject:rssi forKey:kRSSI];
    [coder encodeInt:battery forKey:kBattery];
    [coder encodeInt:samples forKey:kSamples];
    [coder encodeInt:temperature forKey:kTemp];
    [coder encodeInt:humidity forKey:kHumidity];
    [coder encodeDouble:weight forKey:kWeight];
}

// {w|S},battery,samples,temp,humidity

- (NSString *) formatForLogging: (NSString *)deviceName {
    NSString *logInfo = [NSString stringWithFormat:@"%@,%d,%d,%d,%d",
                         deviceName, battery, samples, temperature, humidity];
    if (weight)    // not a scale
        logInfo = [NSString stringWithFormat:@"%@,%.2f", logInfo,weight];
    return [NSString stringWithFormat:@"%@,%@",
            weight ? @"W" : @"S",
            logInfo];
}

@end
