//
//  SendMail.h
//  HiveMon
//
//  Created by ches on 17/4/27.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum snmp_status {
    SNMP_OK = 200,
    SNMP_TMP_FAIL = 400,
    SNMP_PERM_ERR = 500,
} snmp_status;

@protocol SendMailProto <NSObject>

- (NSString *) mailCompleted: (snmp_status)
status message:(NSString *)message ;   // returns status or nil of ok

@end
@interface SendMail : NSObject
    <NSStreamDelegate> {
}

- (NSString *) sendMail: (NSString *) dest
                   message:(NSString *)mess
               delegate:(id<SendMailProto>) del;

@end
