//
//  SendMail.h
//  HiveMon
//
//  Created by ches on 17/4/27.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SendMailProto <NSObject>

- (NSString *) mailCompleted;   // returns status or nil of ok

@end
@interface SendMail : NSObject
    <NSStreamDelegate> {
}

- (NSString *) sendMail: (NSString *) dest
                   message:(NSString *)mess
               delegate:(id<SendMailProto>) del;

@end
