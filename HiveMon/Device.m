//
//  Device.m
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Device.h"

#define kName       @"Name"
#define kDisplayLabel   @"DisplayLabel"
#define kLastReport @"LastReport"
#define kHiveName   @"HiveName"
#define kApiaryName @"ApiaryName"
#define kIsScale    @"IsScale"

@implementation Device

@synthesize name;
@synthesize hiveName;
@synthesize apiaryName;
@synthesize lastReport;
@synthesize displayLabel;
@synthesize lastObservation;
@synthesize isScale;
@synthesize peripheral;


- (id)init {
    self = [super init];
    if (self) {
        hiveName = @"";
        apiaryName = @"";
        name = @"";
        displayLabel = @"";
        lastObservation = nil;
        peripheral = nil;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [coder decodeObjectForKey: kName];
        displayLabel = [coder decodeObjectForKey: kDisplayLabel];
        lastReport = [coder decodeObjectForKey: kLastReport];
        hiveName = [coder decodeObjectForKey: kHiveName];
        apiaryName = [coder decodeObjectForKey: kApiaryName];
        isScale = [coder decodeBoolForKey:kIsScale];
        lastObservation = nil;
        peripheral = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:displayLabel forKey:kDisplayLabel];
    [coder encodeObject:lastReport forKey:kLastReport];
    [coder encodeObject:hiveName forKey:kHiveName];
    [coder encodeObject:apiaryName forKey:kApiaryName];
    [coder encodeBool:isScale forKey:kIsScale];
}

@end
