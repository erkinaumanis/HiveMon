//
//  DevicesVC.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderedDictionary.h"
#import "BlueToothMGR.h"
#import "LocationMGR.h"
#import "Log.h"

@interface DevicesVC : UITableViewController
    <UITableViewDelegate,
    UITableViewDataSource,
    BlueDelegate,
    AwaitLocationData,
    UIPickerViewDelegate,
    UIPickerViewDataSource> {
        NSMutableArray *apiaries;
        OrderedDictionary *devices;
}

@property (strong, nonatomic)   NSMutableArray *apiaries;
@property (strong, nonatomic)   OrderedDictionary *devices;

- (void) goingToBackground;
- (void) doBackgroundIdleCycles;
- (void) leftBackground;

@end

