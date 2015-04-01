//
//  AppDelegate.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "AppDelegate.h"
#import "PTViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupWindow];
    return YES;
}

- (void)setupWindow {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PTViewController new];
    [self.window makeKeyAndVisible];
}

@end
