//
//  AsyncSeries.h
//  Avalon
//
//  Created by RyouZhang on 7/1/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Avalon/Async.h>

@interface AsyncSeries : Async {
}
@end


@interface Async(Series)
+ (Async *)series:(NSArray *)blockArray;
@end