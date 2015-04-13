//
//  PTBaseViewController.h
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTBaseViewController : UIViewController

- (void)setupNotifications;
- (void)applicationWillEnterForeground:(NSNotification *)notification;
- (void)applicationDidEnterBackground:(NSNotification *)notification;

@end
