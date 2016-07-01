//
//  AppDelegate.m
//  AvalonDemo
//
//  Created by RyouZhang on 5/22/16.
//  Copyright © 2016 RyouZhang. All rights reserved.
//

#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <Avalon/Avalon.h>

@interface AppDelegate () {
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[AsyncBlockPool getInstance] registerAsyncBlock:[AsyncBlock asyncBlock:^(__weak Async *this, id context){
        context = [NSString stringWithFormat:@"%@_Test1", context];
        this.next(AsyncSuccessStatus, context);
    } named:@"Test1" option:[AsyncOption defaultOption]]];
    
    [[AsyncBlockPool getInstance] registerAsyncBlock:[AsyncBlock asyncBlock:^(__weak Async *this, id context){
        context = [NSString stringWithFormat:@"%@_Test2", context];
        this.next(AsyncSuccessStatus, context);
    } named:@"Test2" option:[AsyncOption defaultOption]]];
    
    //sample all
    [Async series:@[[Async asyncWithBlockName:@"Test1"],
                    [Async asyncWithBlockName:@"Test2"]]]
    .match(AsyncSuccessStatus, ^(Async *__weak this, id context){
        NSLog(@"%@", context);
    }, [AsyncOption defaultOption])
    .commit(@[@"hello", @"world"]);
    
    //sample
    [Async asyncWithBlockName:@"Test1"].match(AsyncSuccessStatus, ^(__weak Async *this, id context){
        NSLog(@"%@", context);
    }, [AsyncOption defaultOption]).commit(@"dsad");
    
    [Async async:^(__weak Async *this, id context) {
        context = [NSString stringWithFormat:@"%@_1", context];
        NSLog(@"execute|%@|%@|%@", this, [NSThread currentThread], context);
        
        [this dispatchWithBlockName:@"Test1" context:context]
        .match(AsyncSuccessStatus, ^(__weak Async *that, id context){
            this.next(AsyncSuccessStatus, context);
        }, [AsyncOption defaultOption]);
        
    } option:[AsyncOption defaultOption]]
    .match(AsyncSuccessStatus, ^(__weak Async *this, id context){
        
        NSLog(@"%@|%@|%@|%@", AsyncSuccessStatus, this, [NSThread currentThread], context);
        
    }, [AsyncOption defaultOption].thread(Main_Thread))
    .match(AsyncCancelStatus, ^(__weak Async *this, id context) {
        
         NSLog(@"%@|%@|%@|%@", AsyncCancelStatus, this, [NSThread currentThread], context);
        
    }, [AsyncOption defaultOption])
    .commit(@"hello world");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
