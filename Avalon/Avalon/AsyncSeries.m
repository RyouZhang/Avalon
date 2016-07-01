//
//  AsyncSeries.m
//  Avalon
//
//  Created by RyouZhang on 7/1/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncSeries.h"
#import "AsyncBlock.h"
#import "AsyncOption.h"

@interface AsyncSeries() {
}
@property(strong, atomic)NSMutableArray *asyncArray;
@property(assign, atomic)NSUInteger     index;
@end

@implementation AsyncSeries
- (instancetype)initWithArray:(NSArray *)asyncArray {
    self = [super init];
    if (self) {
        _asyncArray = [[NSMutableArray alloc] initWithArray:asyncArray];
        _index = 0;
        
        __weak typeof(self)weakRef = self;
        
        for (Async *async in _asyncArray) {
            async.match(AsyncSuccessStatus, ^(Async *__weak that, id context){
                [weakRef processBlockSuccessCallback:that context:context];
            }, [AsyncOption defaultOption].resource(weakRef.identify));
            
            async.match(AsyncErrorStatus, ^(Async *__weak that, id context){
                [weakRef processBlockErrorCallback:that context:context];
            }, [AsyncOption defaultOption].resource(weakRef.identify));
        }
        
        AsyncBlock *ab = [AsyncBlock asyncBlock:^(Async *__weak this, id context) {
            Async *async = [weakRef.asyncArray objectAtIndex:_index];
            async.commit(context);
        }];
        [_blockDic setObject:ab forKey:AsyncInitStatus];
    }
    return self;
}

- (void)processBlockSuccessCallback:(Async __weak *)async context:(id)context {
    _index++;
    if (_index >= [_asyncArray count]) {
        self.next(AsyncSuccessStatus, context);
    } else {
        Async *child = [_asyncArray objectAtIndex:_index];
        child.commit(context);
    }
}

- (void)processBlockErrorCallback:(Async __weak *)async context:(id)context {
    for (Async *child in _asyncArray) {
        [child cancel];
    }
    self.next(AsyncErrorStatus, context);
}

- (void)cancel {
    [super cancel];
    for (Async *async in _asyncArray) {
        [async cancel];
    }
}

- (void)dealloc {
}
@end


@implementation Async(Series)
+ (Async *)series:(NSArray *)blockArray {
    if (blockArray == nil || [blockArray count] == 0) {
        return nil;
    }
    AsyncSeries *async = [[AsyncSeries alloc] initWithArray:blockArray];
    return async;
}
@end