//
//  LocationMGR.h
//  FanifyMe
//
//  Created by ches on 17/3/19.
//  Copyright © 2017 William Cheswick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol AwaitLocationData
@optional
- (void) locationDataAvailable: (CLLocation *)loc;
- (void) locationDenied;
@end

@interface LocationMGR : NSObject
<CLLocationManagerDelegate> {
    CLLocation *location;
    BOOL locationDenied;
}

@property (nonatomic, strong)   CLLocation *location;
@property (assign)              BOOL locationDenied;

- (void) initLocationServices;
- (void) awaitLocationData: (id<AwaitLocationData>)delegate;

extern LocationMGR *locationMGR;

@end
