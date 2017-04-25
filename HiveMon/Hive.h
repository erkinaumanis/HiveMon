//
//  Hive.h
//  HiveMon
//
//  Created by ches on 17/4/25.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Hive : NSObject {
    NSString *name;
    NSString *apiaryName;
    NSMutableArray *devices;
}

@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSString *apiaryName;
@property (nonatomic, strong)   NSMutableArray *devices;

- (id)initInApiary:(NSString *)an;

@end
