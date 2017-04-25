//
//  DevicesVC.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothMGR.h"
#import "LocationMGR.h"

@interface DevicesVC : UITableViewController
    <UITableViewDelegate, UITableViewDataSource, BlueDelegate,
    AwaitLocationData> {
    BlueToothMGR *blueToothMGR;
}

@property (strong, nonatomic)   BlueToothMGR *blueToothMGR;

@end

