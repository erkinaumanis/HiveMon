//
//  LocationMGR.m
//  FanifyMe
//
//  Created by ches on 17/3/19.
//  Copyright © 2017 William Cheswick. All rights reserved.
//

#import "LocationMGR.h"

@interface LocationMGR ()

@property (nonatomic, strong)   CLLocationManager *systemLocationMgr;
@property (assign)              id awaitingLocation;

@end


@implementation LocationMGR

@synthesize systemLocationMgr;
@synthesize awaitingLocation;
@synthesize location;
@synthesize locationDenied;

- (id)init {
    self = [super init];
    if (self) {
        self.location = nil;    // no location data available
        self.locationDenied = NO;
        self.systemLocationMgr = nil;
        awaitingLocation = nil;
   }
    return self;
}

// XXXX need location status denied, pending

- (void) awaitLocationData: (id<AwaitLocationData>)delegate {
    if (location) {
        [delegate locationDataAvailable: location];
        return;
    }
    NSLog(@"await location data ...");
    self.awaitingLocation = delegate;
    if (location) {    // race condition, only send msg once
        [awaitingLocation locationDataAvailable: location];
        self.awaitingLocation = nil;
        return;
    }
}

// for iOS 8, specific user level permission is required,
// "when-in-use" authorization grants access to the user's location
//
// important: be sure to include NSLocationWhenInUseUsageDescription along with its
// explanation string in your Info.plist or startUpdatingLocation will not work.
//

- (void) initLocationServices {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:    // XXXX error message?
            locationDenied = YES;
            NSLog(@"*** location denied, status: %d", [CLLocationManager authorizationStatus]);
            return;
        default:
            NSLog(@"--- starting location mgr");
            self.systemLocationMgr = [[CLLocationManager alloc] init];
            systemLocationMgr.delegate = self;
            systemLocationMgr.distanceFilter = 1;
            systemLocationMgr.desiredAccuracy = kCLLocationAccuracyBest;
            locationDenied = NO;
            
            if ([systemLocationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                NSLog(@"--- requesting location authorization");
                [systemLocationMgr requestWhenInUseAuthorization];
            }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (location == nil)
        NSLog(@"... location updates started");
    self.location = newLocation;
    if (awaitingLocation) {
        [awaitingLocation locationDataAvailable: location];
        self.awaitingLocation = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    NSLog(@"... %s", __PRETTY_FUNCTION__);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [systemLocationMgr startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied: {
            locationDenied = YES;
            break;
        }
        default:
            NSLog(@"----- didChangeAuthorizationStatus, unexpected status: %d", status);
    }
}

- (void) startUpdatingLocation {
    [systemLocationMgr startUpdatingLocation];
}

- (void) stopUpdatingLocation {
    [systemLocationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s didFailWithError", __PRETTY_FUNCTION__);
    switch (error.code) {
        case kCLErrorLocationUnknown:
            if (awaitingLocation) {
                [awaitingLocation locationDataAvailable: nil];
                self.awaitingLocation = nil;
            }
            break;
        case kCLErrorRegionMonitoringDenied:
        case kCLErrorDenied:    // user says no, stop using it
            [manager stopMonitoringSignificantLocationChanges];
            NSLog(@"location is not available");
            locationDenied = YES;
            if (awaitingLocation) {
                [awaitingLocation locationDataAvailable: nil];
                self.awaitingLocation = nil;
            }
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    //    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
    //                                       newHeading.trueHeading : newHeading.magneticHeading);
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    NSLog(@"location didDetermineState %ld, region %@", (long)state, region);
}

@end
