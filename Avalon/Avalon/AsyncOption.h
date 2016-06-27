//
//  AsyncOption.h
//  Avalon
//
//  Created by RyouZhang on 6/9/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Background_Thread   = 0,
    Main_Thread         = 1
}ThreadType;

@interface AsyncOption : NSObject {
}
@property(atomic, readonly)ThreadType     threadType;
@property(atomic, readonly)NSMutableSet   *resourceSet;


+ (AsyncOption *)defaultOption;

- (AsyncOption *(^)(ThreadType))thread;

- (AsyncOption *(^)(NSString*))resource;
@end
