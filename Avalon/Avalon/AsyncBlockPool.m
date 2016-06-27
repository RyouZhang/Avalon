//
//  AsyncBlockPool.m
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncBlockPool.h"
#import "AsyncBlock.h"

@interface AsyncBlockPool() {
@private
    NSMutableDictionary *_asyncBlockDic;
}
@end

@implementation AsyncBlockPool
static AsyncBlockPool *_AsyncBlockPool_Instance = nil;
+ (AsyncBlockPool *)getInstance {
    @synchronized (self) {
        if (_AsyncBlockPool_Instance == nil) {
            _AsyncBlockPool_Instance = [AsyncBlockPool new];
        }
        return _AsyncBlockPool_Instance;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _asyncBlockDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerAsyncBlock:(AsyncBlock *)asyncBlock {
    if ([_asyncBlockDic objectForKey:asyncBlock.name]) {
        return;
    }
    [_asyncBlockDic setObject:asyncBlock
                       forKey:asyncBlock.name];
}

- (void)unregisterAsyncBlock:(NSArray *)names {
    for (NSString *name in names) {
        AsyncBlock *block = [_asyncBlockDic objectForKey:name];
        if (block && [block nicked]) {
            [_asyncBlockDic removeObjectForKey:name];
        }
    }
}

- (AsyncBlock *)findAsyncBlock:(NSString *)name {
    return [_asyncBlockDic objectForKey:name];
}

- (void)clearAll {
    [_asyncBlockDic removeAllObjects];
}

- (void)dealloc {
}
@end
