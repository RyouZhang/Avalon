//
//  Async.m
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "Async.h"
#import "AsyncBlock.h"
#import "AsyncBlockPool.h"
#import "AsyncScheduler.h"

@interface Async() {
}
@end

@implementation Async
@synthesize status = _status;

+ (Async *)async:(AsyncFuncBlock)func option:(AsyncOption *)option {
    return [Async asyncWithBlock:[AsyncBlock asyncBlock:func option:option]];
}

+ (Async *)asyncWithBlock:(AsyncBlock *)block {
    return [[Async alloc] initWithBlock:block];
}

+ (Async *)asyncWithBlockName:(NSString *)name {
    AsyncBlock *ab = [[AsyncBlockPool getInstance] findAsyncBlock:name];
    assert(ab != nil);
    return [Async asyncWithBlock:ab];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _identify = [[NSUUID UUID] UUIDString];
        _status = AsyncInitStatus;
        _blockDic = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithBlock:(AsyncBlock *)block {
    self = [super init];
    if (self) {
        _identify = [[NSUUID UUID] UUIDString];
        _status = AsyncInitStatus;
        _blockDic = [NSMutableDictionary new];
        [_blockDic setObject:block forKey:AsyncInitStatus];
    }
    return self;
}
                    

- (Async *(^)(NSString *, AsyncFuncBlock, AsyncOption *))match {
    return ^(NSString *status, AsyncFuncBlock func, AsyncOption *option) {
        AsyncBlock *ab = [AsyncBlock asyncBlock:func option:option];
        [_blockDic setObject:ab forKey:status];
        return self;
    };
}

- (AsyncBlock *)getAsyncBlock {
    return [_blockDic objectForKey:_status];
}

- (Async *(^)(id))commit {
    return ^(id context){
       [[AsyncScheduler getInstance] run:self args:context];
        return self;
    };
}

- (void)reset {
    @synchronized (self) {
        if ([_status isEqualToString:AsyncCancelStatus] ||
            [_status isEqualToString:AsyncSuccessStatus] ||
            [_status isEqualToString:AsyncCancelStatus]) {
            _status = AsyncInitStatus;
        }
    }
}

- (void)cancel {
    if (_child) {
        [_child cancel];
    }
    self.next(AsyncCancelStatus, nil);
}

- (void (^)(NSString *, id))next {
    return ^(NSString *status, id context){
        @synchronized (self) {
            if ([_status isEqualToString:AsyncCancelStatus] ||
                [_status isEqualToString:AsyncSuccessStatus] ||
                [_status isEqualToString:AsyncCancelStatus]) {
                return;
            }
            _status = status;
            [[NSNotificationCenter defaultCenter] postNotificationName:AsyncStatusChanged object:self userInfo:context];
        }
    };
}

- (Async *(^)(AsyncFuncBlock, AsyncOption *, id))dispatch {
    return ^(AsyncFuncBlock func, AsyncOption *option, id context) {
        Async *child = [Async async:func option:option];
        _child = child;
        return child.commit(context);
    };
}

- (Async *)dispatchWithBlockName:(NSString *)name context:(id)context {
    AsyncBlock *ab = [[AsyncBlockPool getInstance] findAsyncBlock:name];
    assert(ab != nil);
    Async *child = [[Async alloc] initWithBlock:ab];
    _child = child;
    return child.commit(context);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_blockDic removeAllObjects];
    _child = nil;
}
@end
