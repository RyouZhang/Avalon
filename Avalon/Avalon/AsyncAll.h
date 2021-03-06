//
//  AsyncAll.h
//  Avalon
//
//  Created by RyouZhang on 7/1/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Avalon/Async.h>

@interface AsyncAll : Async {
}
+ (AsyncAll *)all:(NSArray *)blockArray;

- (AsyncAll *(^)(NSArray *))commit;
@end


@interface Async(All)
+ (Async *)all:(NSArray *)blockArray;
@end