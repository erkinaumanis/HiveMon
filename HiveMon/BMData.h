//
//  BMData.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMData : NSObject {
    NSDate *timeStamp;
    int battery;
    int samples;
    int temperature;
    int humidity;
    int leftWeight;     // Scales...
    int rightWeight;    // ... only
}

@property (strong, nonatomic)  NSDate *timeStamp;
@property (assign)  int battery;
@property (assign)  int samples;
@property (assign)  int temperature;
@property (assign)  int humidity;
@property (assign)  int leftWeight;
@property (assign)  int rightWeight;

@end
