//
//  AsyncScheduler.m
//  Avalon
//
//  Created by RyouZhang on 5/21/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncScheduler.h"
#import "Async.h"
#import "AsyncBlock.h"
#import "AsyncOption.h"
#import "AsyncWorker.h"
#import "AsyncBlockPool.h"

#define Max_Worker_Thread   sysconf(_SC_NPROCESSORS_CONF)

@interface AsyncScheduler() {
    AsyncWorker         *_coreThread;
    NSMutableArray      *_workerArray;
    
    NSMutableArray      *_waittingArray;
    NSMutableArray      *_suspendArray;
    
    NSMutableArray      *_penddingArray;
    NSMutableSet        *_resourceSet;
}
@end

@implementation AsyncScheduler
static AsyncScheduler * _AsyncScheduler_Instance = nil;
+ (AsyncScheduler *)getInstance {
    @synchronized (self) {
        if (_AsyncScheduler_Instance == nil) {
            _AsyncScheduler_Instance = [AsyncScheduler new];
        }
    }
    return _AsyncScheduler_Instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _coreThread = [AsyncWorker new];
        [_coreThread setName:@"AsyncScheduler"];
        [_coreThread start];
        
        _workerArray = [NSMutableArray new];
        for (NSInteger index = 0; index < Max_Worker_Thread; index++) {
            AsyncWorker *worker = [AsyncWorker new];
            [_workerArray addObject:worker];
            [worker setName:[NSString stringWithFormat:@"AsyncWorker_%d", index]];
            [worker start];
        }
        
        _resourceSet = [NSMutableSet new];
        _waittingArray = [NSMutableArray new];
        _suspendArray = [NSMutableArray new];
        _penddingArray = [NSMutableArray new];
    }
    return self;
}


- (void)run:(Async *)async args:(id)args {
    [self performSelector:@selector(runWithContext:)
                 onThread:_coreThread
               withObject:@[async, args]
            waitUntilDone:NO];
}

- (void)runWithContext:(NSArray *)args {
    [_waittingArray addObject:args];
    [self performSelector:@selector(scheduler)
                 onThread:_coreThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)scheduler {
    [self awakeSuspendArray];
    [self processWaittingArray];
}

- (void)awakeSuspendArray {
    if ([_suspendArray count] == 0) {
        return;
    }
    
    NSInteger index = 0;
    while (index < [_suspendArray count]) {
        if ([_workerArray count] == 0) {
            return;
        }
        NSArray *args = [_suspendArray objectAtIndex:index];
        
        Async *async = [args firstObject];
        AsyncBlock *block = [async getAsyncBlock];
        assert(block != nil);
        if (NO == [self applyResourceDemand:block.option]) {
            index++;
            continue;
        }
        
        AsyncWorker *worker = nil;
        switch (block.option.threadType) {
            case Main_Thread:
                worker = [NSThread mainThread];
                break;
            default:
                worker = [_workerArray firstObject];
                [_workerArray removeObject:worker];
                break;
        }
        
        [self performSelector:@selector(executeAsync:)
                     onThread:worker
                   withObject:@[block, async, [args lastObject]]
                waitUntilDone:NO];
        [self performSelector:@selector(executeFinish:)
                     onThread:_coreThread
                   withObject:worker
                waitUntilDone:NO];
        
        [_suspendArray removeObject:args];
    }
}

- (void)processWaittingArray {
    if ([_workerArray count] == 0) {
        return;
    }

    while ([_waittingArray count] > 0) {
        if ([_workerArray count] == 0) {
            return;
        }
        NSArray *args = [_waittingArray firstObject];
        Async *async = (Async *)[args firstObject];        
        AsyncBlock *block = [async getAsyncBlock];
        if (block == nil) {
            [_waittingArray removeObject:args];
            continue;
        }
        if (NO == [self applyResourceDemand:block.option]) {
            [_suspendArray addObject:args];
            [_waittingArray removeObject:args];
            continue;
        }
        AsyncWorker *worker = nil;
        switch (block.option.threadType) {
            case Main_Thread:
                worker = [NSThread mainThread];
                break;
            default:
                worker = [_workerArray firstObject];
                [_workerArray removeObject:worker];
                break;
        }
        [self performSelector:@selector(executeAsync:)
                     onThread:worker
                   withObject:@[block, async, [args lastObject]]
                waitUntilDone:NO];
        [self performSelector:@selector(executeFinish:)
                     onThread:_coreThread
                   withObject:worker
                waitUntilDone:NO];
        [_waittingArray removeObject:args];
    }
}

- (BOOL)applyResourceDemand:(AsyncOption *)opt {
    if ([opt.resourceSet count] == 0) {
        return YES;
    }
    if ([_resourceSet count] == 0) {
        [_resourceSet unionSet:opt.resourceSet];
        return YES;
    }
    for (NSString *resource in opt.resourceSet) {
        if ([_resourceSet containsObject:resource]) {
            return NO;
        }
    }
    [_resourceSet unionSet:opt.resourceSet];
    return YES;
}

- (void)revertResourceDemand:(AsyncOption *)opt {
    if ([opt.resourceSet count] > 0) {
        [_resourceSet minusSet:opt.resourceSet];
    }
}

- (void)executeAsync:(NSArray *)args {
    AsyncBlock *asyncBlock = [args objectAtIndex:0];
    Async *async = [args objectAtIndex:1];
    if(NO == [async.status isEqualToString:AsyncSuccessStatus] &&
       NO == [async.status isEqualToString:AsyncErrorStatus] &&
       NO == [async.status isEqualToString:AsyncCancelStatus]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(asyncStatusChanged:)
                                                     name:AsyncStatusChanged
                                                   object:async];
        [_penddingArray addObject:async];
    }
    
    __weak typeof(async) weakRef = async;
    asyncBlock.block(weakRef, [args lastObject]);
    
    [self performSelector:@selector(revertResourceDemand:)
                 onThread:_coreThread
               withObject:asyncBlock.option
            waitUntilDone:NO];
    [self performSelector:@selector(scheduler)
                 onThread:_coreThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)asyncStatusChanged:(NSNotification *)notify {
    Async *async = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AsyncStatusChanged
                                                  object:async];
    [_penddingArray removeObject:async];
    
    if ([async getAsyncBlock] == nil) {
        return;
    }
    [self performSelector:@selector(runWithContext:)
                 onThread:_coreThread
               withObject:@[async, [notify userInfo]]
            waitUntilDone:NO];
}

- (void)executeFinish:(AsyncWorker *)worker {
    if ([[worker name] hasPrefix:@"AsyncWorker_"]) {
        [_workerArray addObject:worker];
    }
    [self scheduler];
}

- (void)dealloc {
}
@end