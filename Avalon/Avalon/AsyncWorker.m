//
//  AsyncWorker.m
//  Avalon
//
//  Created by RyouZhang on 5/21/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncWorker.h"

@interface AsyncWorker() {
}
@end

@implementation AsyncWorker
- (void)main {
    @autoreleasepool {
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(onTriggerTimer:)
                                               userInfo:nil
                                                repeats:YES];
        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
        while (self.cancelled == NO &&
               [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
}

- (void)onTriggerTimer:(id)sender {
    //for hold thread
}

- (void)cancel {
    [super cancel];
}
@end
