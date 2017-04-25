//
//  Device.h
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hive.h"

@interface Device : NSObject {
    NSString *name;
    NSString *hiveName;
}

@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSString *hiveName;

@end
