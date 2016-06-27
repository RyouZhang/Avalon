//
//  AsyncAll.m
//  Avalon
//
//  Created by RyouZhang on 6/26/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncAll.h"
#import "AsyncBlock.h"
#import "AsyncOption.h"

@interface AsyncAll() {
}
@property(strong, atomic)NSMutableArray *asyncArray;
@property(strong, atomic)NSMutableArray *resultArray;
@property(assign, atomic)NSInteger      validCount;
@end

@implementation AsyncAll
+ (AsyncAll *)asyncAll:(NSArray *)asyncArray {
    AsyncAll * async = [[AsyncAll alloc] initWithArray:asyncArray];
    return async;
}

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
                    [weakRef processBlockCallback:that context:context];
                }, [AsyncOption defaultOption].resource(weakRef.identify));
                
                async.match(AsyncErrorStatus, ^(Async *__weak that, id context){
                    [weakRef processBlockCallback:that context:context];
                }, [AsyncOption defaultOption].resource(weakRef.identify));
                
                async.commit([context objectAtIndex:index]);
            }
        }];
        [_blockDic setObject:ab forKey:AsyncInitStatus];
    }
    return self;
}

- (void)processBlockCallback:(Async __weak *)async context:(id)context {
    _validCount++;
    NSInteger index = [_asyncArray indexOfObject:async];
    [_resultArray replaceObjectAtIndex:index withObject:context];
    
    if (_validCount == [_asyncArray count]) {
        self.next(AsyncSuccessStatus, _resultArray);
    }
}

- (void)cancel {
    [super cancel];
    for (Async *async in _asyncArray) {
        [async cancel];
    }
}

- (void)dealloc {
    NSLog(@"AsyncAll dealloc %@", self.identify);
}
@end
