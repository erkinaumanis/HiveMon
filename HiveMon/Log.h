//
//  Log.h
//  HiveMon
//
//  Created by ches on 17/4/30.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Weight  @"W"
#define Sensor  @"S"
#define Monitor @"M"
#define TimeStamp   @"T"

@interface Log : NSObject

- (void) add:(NSString *)data;
- (void) close;
- (void) logIPhoneStatus;

@end
