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
#define kIsScale    @"IsScale"

@implementation Device

@synthesize name;
@synthesize hiveName;
@synthesize lastReport;
@synthesize displayLabel;
@synthesize lastObservation;
@synthesize isScale;


- (id)init {
    self = [super init];
    if (self) {
        hiveName = @"";
        name = @"";
        displayLabel = @"";
        lastObservation = nil;
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
        isScale = [coder decodeBoolForKey:kIsScale];
        lastObservation = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:displayLabel forKey:kDisplayLabel];
    [coder encodeObject:lastReport forKey:kLastReport];
    [coder encodeObject:hiveName forKey:kHiveName];
    [coder encodeBool:isScale forKey:kIsScale];
}

@end
