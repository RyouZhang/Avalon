//
//  AsyncBlockPool.h
//  Avalon
//
//  Created by RyouZhang on 6/23/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncBlock;

@interface AsyncBlockPool : NSObject {
}
+ (AsyncBlockPool *)getInstance;

- (void)registerAsyncBlock:(AsyncBlock *)asyncBlock;
- (void)unregisterAsyncBlock:(NSArray *)names;

- (AsyncBlock *)findAsyncBlock:(NSString *)name;

- (void)clearAll;
@end
