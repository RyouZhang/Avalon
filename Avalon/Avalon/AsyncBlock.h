//
//  AsyncBlock.h
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Async;
@class AsyncOption;

typedef void (^AsyncFuncBlock) (__weak Async *, id);

@interface AsyncBlock : NSObject {
@protected
    NSString        *_name;
    BOOL            _nicked;
    AsyncFuncBlock  _block;
    AsyncOption     *_option;
}
@property(atomic, readonly)NSString         *name;
@property(atomic, readonly)BOOL             nicked;
@property(atomic, readonly)AsyncFuncBlock   block;
@property(atomic, readonly)AsyncOption      *option;

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block;

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block
                    option:(AsyncOption *)option;

+ (AsyncBlock *)asyncBlock:(AsyncFuncBlock)block
                     named:(NSString *)name
                    option:(AsyncOption *)option;
@end
