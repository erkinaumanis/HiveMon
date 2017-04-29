//
//  SendMail.m
//  HiveMon
//
//  Created by ches on 17/4/27.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//
// This routine sends a simple text mail message to a given server.
// It doesn't handle encryption, MIME, or any of that other cruft.  It
// is SMTP from the 1980s.


#define BEEMON_WEB_SERVER   @"beemon.cheswick.com"
#define BEEMON_MAIL_SERVER  @"farmmail.cheswick.com"    // XXXX must be user-supplied

#define BEEMON_SENDER       @"beemon"

#define SMTP_PORT   25

#include <unistd.h>

#import "SendMail.h"

@interface SendMail ()

@property (strong, nonatomic)   NSInputStream *inputStream;
@property (strong, nonatomic)   NSOutputStream *outputStream;
@property (strong, nonatomic)   id<SendMailProto> delegate;
@property (strong, nonatomic)   NSString *destination;
@property (strong, nonatomic)   NSString *message;

@end


@implementation SendMail

@synthesize inputStream, outputStream;
@synthesize delegate;
@synthesize destination;
@synthesize message;

- (id)init {
    self = [super init];
    if (self) {
        u_char name[200];
        int rc = gethostname(&name, sizeof(name));
        NSLog(@"hostname = %s, %d", name, rc);
    }
    return self;
}

- (NSString *) sendMail: (NSString *) dest
                   message:(NSString *) mess
               delegate:(id<SendMailProto>) del {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)BEEMON_MAIL_SERVER, SMTP_PORT,
                                       &readStream, &writeStream);
    
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    if (inputStream.streamError) {
        return [NSString stringWithFormat:@"input stream open error: %@",
                [inputStream.streamError localizedDescription]];
    }
    [outputStream open];
    if (inputStream.streamError) {
        return [NSString stringWithFormat:@"output stream open error: %@",
                [inputStream.streamError localizedDescription]];
    }
    
    self.delegate = del;
    self.message = mess;
    self.destination = dest;
    [self doHELO];
    return nil;
}

- (void) doHELO {
    
}

- (void) csend: (NSString *) cmd {
    
}


@end
