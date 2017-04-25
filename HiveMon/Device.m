//
//  Device.m
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Device.h"

#define kName       @"Name"
#define kHiveName   @"HiveName"

@implementation Device

@synthesize name;
@synthesize hiveName;


- (id)init {
    self = [super init];
    if (self) {
        hiveName = @"";
        name = @"";
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [coder decodeObjectForKey: kName];
        hiveName = [coder decodeObjectForKey: kHiveName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:hiveName forKey:kHiveName];
}

@end
