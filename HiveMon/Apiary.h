//
//  Apiary.h
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Hive.h"

#define DEFAULT_APIARY_NAME @"(default)"

@interface Apiary : NSObject {
    NSString *name;
    CLLocation *location;
    NSMutableArray *hives;  // array of hives
}

@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSMutableArray *hives;
@property (nonatomic, retain)   CLLocation *location;

- (void) makeDefaultApiary;

@end
