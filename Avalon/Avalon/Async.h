//
//  Async.h
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AsyncStatusChanged @"AsyncStatusChanged"

#define AsyncInitStatus     @"AsyncInitStatus"
#define AsyncCancelStatus   @"AsyncCancelStatus"
#define AsyncSuccessStatus  @"AsyncSuccessStatus"
#define AsyncErrorStatus    @"AsyncErrorStatus"

@class Async;
@class AsyncBlock;
@class AsyncOption;

typedef void (^AsyncFuncBlock) (__weak Async *, id);

@interface Async : NSObject {
@protected
    NSString            *_status;
    NSMutableDictionary *_blockDic;
    Async               *_child;
}
@property(atomic, readonly)NSString     *identify;
@property(atomic, readonly)NSString     *status;

+ (Async *)async:(AsyncFuncBlock)func option:(AsyncOption *)option;
+ (Async *)asyncWithBlock:(AsyncBlock *)block;
+ (Async *)asyncWithBlockName:(NSString *)name;

- (Async *(^)(NSString *, AsyncFuncBlock, AsyncOption *))match;
- (Async *(^)(id))commit;
- (void (^)(NSString *, id))next;
- (void)cancel;
- (void)reset;

- (AsyncBlock *)getAsyncBlock;

- (Async *(^)(AsyncFuncBlock, AsyncOption *, id))dispatch;

- (Async *)dispatchWithBlockName:(NSString *)name
                         context:(id)context;
@end
