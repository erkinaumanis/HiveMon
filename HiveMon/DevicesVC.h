//
//  DevicesVC.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothMGR.h"

@interface DevicesVC : UITableViewController
    <UITableViewDelegate, BlueDelegate> {
    BlueToothMGR *blueToothMGR;
}

@property (strong, nonatomic)   BlueToothMGR *blueToothMGR;

@end

