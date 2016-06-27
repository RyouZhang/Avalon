//
//  AsyncAll.h
//  Avalon
//
//  Created by RyouZhang on 6/26/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Avalon/Async.h>

@interface AsyncAll : Async {
}
+ (AsyncAll *)asyncAll:(NSArray *)blockArray;

- (AsyncAll *(^)(NSArray *))commit;
@end
