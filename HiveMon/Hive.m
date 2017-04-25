//
//  Hive.m
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Hive.h"

#define kName       @"Name"
#define kApiaryName     @"ApiaryName"
#define kDevices    @"Devices"

@implementation Hive

@synthesize name;
@synthesize apiaryName;
@synthesize devices;

- (id)initInApiary:(NSString *)an {
    self = [super init];
    if (self) {
        apiaryName = an;
        devices = [[NSMutableArray alloc] init];
        name = @"";
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [coder decodeObjectForKey: kName];
        apiaryName = [coder decodeObjectForKey: kApiaryName];
        devices = [coder decodeObjectForKey: kDevices];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:apiaryName forKey:kApiaryName];
    [coder encodeObject:devices forKey:kDevices];
}

@end
