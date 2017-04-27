//
//  Apiary.m
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Apiary.h"

#define kName           @"Name"
#define kLocation       @"Location"
#define kDevices        @"Devices"
#define kHives          @"Hives"

@implementation Apiary

@synthesize name;
@synthesize location;
@synthesize hives;
@synthesize devices;


- (id)init {
    self = [super init];
    if (self) {
        hives = [[NSMutableArray alloc] init];
        devices = [[OrderedDictionary alloc] init];
        name = @"";
    }
    return self;
}

#define NORTH_POLE_LAT  90.0
#define NORTH_POLE_LONG -74.400985    // MH, NJ, because it is fun

- (void) makeDefaultApiary {
    name = DEFAULT_APIARY_NAME;
    location = [[CLLocation alloc]
                initWithLatitude:NORTH_POLE_LAT longitude: NORTH_POLE_LONG];
}

- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [coder decodeObjectForKey: kName];
        location = [coder decodeObjectForKey: kLocation];
        hives = [coder decodeObjectForKey: kHives];
        devices = [coder decodeObjectForKey: kDevices];
        if (!devices)
            devices = [[OrderedDictionary alloc] init]; // for older data
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:location forKey:kLocation];
    [coder encodeObject:hives forKey:kHives];
    if (!devices)
        devices = [[OrderedDictionary alloc] init]; // for older data
    [coder encodeObject:devices forKey:kDevices];
}

@end
