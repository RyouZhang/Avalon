//
//  AsyncOption.m
//  Avalon
//
//  Created by RyouZhang on 6/9/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AsyncOption.h"

@interface AsyncOption() {
@private
    ThreadType      _threadType;
    NSMutableSet    *_resourceSet;
}
@end

@implementation AsyncOption
@synthesize threadType = _threadType, resourceSet = _resourceSet;
+ (AsyncOption *)defaultOption {
    AsyncOption *opt = [AsyncOption new];
    return opt;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _threadType = Background_Thread;
        _resourceSet = [NSMutableSet new];
    }
    return self;
}

- (AsyncOption *(^)(ThreadType))thread {
    return ^(ThreadType type){
        _threadType = type;
        return self;
    };
}

- (AsyncOption *(^)(NSString*))resource {
    return ^(NSString *resourceKey){
        if (resourceKey) {
            [_resourceSet addObject:resourceKey];
        }
        return self;
    };
}
@end
