//
//  AsyncBlock.m
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncBlock.h"
#import "AsyncOption.h"
#import "AsyncBlockPool.h"

@implementation AsyncBlock
@synthesize name = _name, nicked = _nicked, block = _block, option = _option;

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block {
    return [AsyncBlock asyncBlock:block option:nil];
}

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block
                    option:(AsyncOption *)option {
    return [AsyncBlock asyncBlock:block named:nil option:option];
}

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block
                     named:(NSString *)name
                    option:(AsyncOption *)option {
    return [[AsyncBlock alloc] initWithBlock:block named:name option:option];
}

- (instancetype)initWithBlock:(AsyncFuncBlock)block
                        named:(NSString *)name
                       option:(AsyncOption *)option {
    self = [super init];
    if (self) {
        if (name) {
            _name = name;
            _nicked = NO;
        } else {
            _name = [[NSUUID UUID] UUIDString];
            _nicked = YES;
        }
        _block = [block copy];
        if (option) {
            _option = option;
        } else {
            _option = [AsyncOption defaultOption];
        }
    }
    return self;
}

- (void)dealloc {
}
@end
