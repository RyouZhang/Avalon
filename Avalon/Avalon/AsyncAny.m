//
//  AsyncAny.m
//  Avalon
//
//  Created by RyouZhang on 7/1/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncAny.h"
#import "AsyncBlock.h"
#import "AsyncOption.h"

@interface AsyncAny(){
}
@property(strong, atomic)NSMutableArray *asyncArray;
@property(strong, atomic)NSMutableArray *resultArray;
@property(assign, atomic)NSInteger      validCount;
@end

@implementation AsyncAny
- (instancetype)initWithArray:(NSArray *)asyncArray {
    self = [super init];
    if (self) {
        _asyncArray = [[NSMutableArray alloc] initWithArray:asyncArray];
        _resultArray = [NSMutableArray new];
        for (NSInteger index = 0; index < [_asyncArray count]; index++) {
            [_resultArray addObject:[NSNull null]];
        }
        
        _validCount = 0;
        
        __weak typeof(self)weakRef = self;
        AsyncBlock *ab = [AsyncBlock asyncBlock:^(Async *__weak this, id context) {
            for (Async *async in weakRef.asyncArray) {
                NSInteger index = [weakRef.asyncArray indexOfObject:async];
                
                async.match(AsyncSuccessStatus, ^(Async *__weak that, id context){
                    [weakRef processBlockSuccessCallback:that context:context];
                }, [AsyncOption defaultOption].resource(weakRef.identify));
                
                async.match(AsyncErrorStatus, ^(Async *__weak that, id context){
                    [weakRef processBlockErrorCallback:that context:context];
                }, [AsyncOption defaultOption].resource(weakRef.identify));
                
                async.commit([context objectAtIndex:index]);
            }
        }];
        [_blockDic setObject:ab forKey:AsyncInitStatus];
    }
    return self;
}

- (void)processBlockSuccessCallback:(Async __weak *)async context:(id)context {
    for (Async *child in _asyncArray) {
        [child cancel];
    }
    self.next(AsyncSuccessStatus, context);
}

- (void)processBlockErrorCallback:(Async __weak *)async context:(id)context {
    _validCount++;
    NSInteger index = [_asyncArray indexOfObject:async];
    [_resultArray replaceObjectAtIndex:index withObject:context];
    
    if (_validCount == [_asyncArray count]) {
        self.next(AsyncErrorStatus, _resultArray);
    }
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


@implementation Async(Any)
+ (Async *)any:(NSArray *)blockArray {
    if (blockArray == nil || [blockArray count] == 0) {
        return nil;
    }
    AsyncAny * async = [[AsyncAny alloc] initWithArray:blockArray];
    return async;
}
@end