//
//  AsyncScheduler.h
//  Avalon
//
//  Created by RyouZhang on 5/21/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Async;
@class AsyncContext;

@interface AsyncScheduler : NSObject
+ (AsyncScheduler *)getInstance;

- (void)run:(Async *)async args:(id)args;
@end
