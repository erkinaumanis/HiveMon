//
//  BMData.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "BMData.h"

@implementation BMData

@synthesize timeStamp;
@synthesize battery, samples;
@synthesize temperature, humidity;
@synthesize leftWeight, rightWeight;


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

@end
