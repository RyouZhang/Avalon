//
//  AsyncAny.h
//  Avalon
//
//  Created by RyouZhang on 7/1/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Avalon/Async.h>

@interface AsyncAny : Async {
}
@end

@interface Async(Any)
+ (Async *)any:(NSArray *)blockArray;
@end
