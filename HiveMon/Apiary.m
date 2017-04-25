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
#define kHives          @"Hives"

@implementation Apiary

@synthesize name;
@synthesize location;
@synthesize hives;


- (id)init {
    self = [super init];
    if (self) {
        hives = [[NSMutableArray alloc] init];
        name = @"";
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [coder decodeObjectForKey: kName];
        location = [coder decodeObjectForKey: kLocation];
        hives = [coder decodeObjectForKey: kHives];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:kName];
    [coder encodeObject:location forKey:kLocation];
    [coder encodeObject:hives forKey:kHives];
}

@end
