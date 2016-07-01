//
//  AsyncParallel.h
//  Avalon
//
//  Created by RyouZhang on 6/26/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Avalon/Async.h>

@interface AsyncParallel : Async {
}
@end

@interface Async(Parallel)
+ (Async *)parallel:(NSArray *)blockArray;
@end