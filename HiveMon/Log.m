//
//  Log.m
//  HiveMon
//
//  Created by ches on 17/4/30.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

// The beelog stores all the information we gather from hives, plus some device
// information.


#import "Defines.h"
#import "Log.h"


#define kLatestTimeInLog    @"LatestTimeInLog"

@interface Log ()

@property (strong, nonatomic)   NSFileHandle *logFileHandle;
@property (nonatomic, strong)   NSDateFormatter *dateFormatter;

@end

@implementation Log

@synthesize dateFormatter;
@synthesize logFileHandle;


- (id)init {
    self = [super init];
    if (self) {
        NSFileManager *mgr = [NSFileManager defaultManager];
#ifdef CLEAR_FILES
        [mgr removeItemAtPath:BEEMON_LOG error:nil];
#endif
        if(![mgr fileExistsAtPath:BEEMON_LOG]) {
            if (DEBUG) NSLog(@"Creating log...");
            [mgr createFileAtPath:BEEMON_LOG contents:nil attributes:nil];
        }
        logFileHandle = [NSFileHandle fileHandleForWritingAtPath:BEEMON_LOG];
        [logFileHandle seekToEndOfFile];
        
        if (![mgr createFileAtPath:BEEMON_LOG contents:NULL attributes:nil]) {
            NSLog(@"%s: Bee log creation failed", __PRETTY_FUNCTION__);
            return nil;
        }
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return self;
}

- (void) logIPhoneStatus {
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    NSString *bs;
    switch (device.batteryState) {
        case UIDeviceBatteryStateFull:
            bs = @"F";
            break;
        case UIDeviceBatteryStateCharging:
            bs = @"C";
            break;
        case UIDeviceBatteryStateUnplugged:
            bs = @"U";
            break;
        default:
            bs = @"?";
    }
    NSString *logEntry = [NSString stringWithFormat:@"%@,%@,%@,%@,%.2f",
                          @"B",     // beemonitor
                          device.name,
                          device.model,
                          bs,
                          device.batteryLevel];
    [self add: logEntry];
    [device setBatteryMonitoringEnabled:NO];
}

- (void) add: (NSString *)data {
    NSString *logInfo = [NSString stringWithFormat:@"%@,%@\n",
                         [dateFormatter stringFromDate:[NSDate date]],
                         data];
    NSLog(@"log: %@", logInfo);
    [logFileHandle
     writeData:[logInfo dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) close {
    [logFileHandle closeFile];
    logFileHandle = nil;
}
@end
