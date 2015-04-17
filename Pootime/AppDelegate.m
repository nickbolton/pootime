//
//  AppDelegate.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "AppDelegate.h"
#import "PTMainViewController.h"
#import "PTCalendarManager.h"
#import "PTDefaultsManager.h"
#import <EventKit/EventKit.h>
#import "PTGlobalConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupWindow];
    return YES;
}


- (void)application:(UIApplication *)application
handleWatchKitExtensionRequest:(NSDictionary *)userInfo
              reply:(void (^)(NSDictionary *))replyBlock {
    
    __block UIBackgroundTaskIdentifier background_task;

    background_task =
    [application
     beginBackgroundTaskWithName:@"watch-task"
     expirationHandler:^{
         [application endBackgroundTask: background_task];
         background_task = UIBackgroundTaskInvalid;
     }];
    
    NSMutableDictionary *reply = [NSMutableDictionary dictionary];
    reply[@"poop"] = @"poop";
    
    if ([PTDefaultsManager sharedInstance].selectedCalendarID.length > 0) {
        
        [[PTCalendarManager sharedInstance]
         calendarWithID:[PTDefaultsManager sharedInstance].selectedCalendarID
         completion:^(EKCalendar *calendar) {
             
             if (calendar != nil) {
                 reply[kPTSelectedCalendarKey] = calendar.calendarIdentifier;
             }
             
             if (replyBlock != nil) {
                 replyBlock(reply);
             }
         }];
        
    } else {
        
        [[PTCalendarManager sharedInstance] allCalendars:^(NSArray *calendars) {
            
            EKCalendar *calendar = calendars.firstObject;
            
            if (calendar != nil) {
                reply[kPTSelectedCalendarKey] = calendar.calendarIdentifier;
            }
            
            if (replyBlock != nil) {
                replyBlock(reply);
            }
        }];
    }
    
    [application endBackgroundTask: background_task];
    background_task = UIBackgroundTaskInvalid;
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
