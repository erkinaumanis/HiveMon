//
//  Peripheral.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//
// A low power bluetooth device that we have discovered in our neighborhood

#import "Peripheral.h"

@implementation Peripheral

@synthesize peripheral;
@synthesize advertisementData;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL) isBroodMinder {
    NSData *manData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (!manData || manData.length < 10)
        return NO;
    NSLog(@"%@", manData);
    const u_char *buf = (u_char *)manData.bytes;
    NSLog(@"%.02x %.02x", buf[0], buf[1]);
    if (buf[0] != 0x8d || buf[1] != 0x02)
        return NO; // wrong manufacturer
    return YES;
}

@end
