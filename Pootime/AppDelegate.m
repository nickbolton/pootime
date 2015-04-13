//
//  AppDelegate.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "AppDelegate.h"
#import "PTMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupWindow];
    return YES;
}

- (void)setupWindow {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor whiteColor];
    
    UINavigationController *navigationController =
    [[UINavigationController alloc]
     initWithRootViewController:[PTMainViewController new]];
    
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

@end
