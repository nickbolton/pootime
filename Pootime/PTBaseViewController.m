//
//  PTBaseViewController.m
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTBaseViewController.h"
#import "PTAnalytics.h"

@interface PTBaseViewController ()

@property (nonatomic, readwrite) BOOL hasAppeared;

@end

@implementation PTBaseViewController

- (id)init {

    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Setup

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];    
}

#pragma mark - View Lifecycle

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return (UIInterfaceOrientationMaskPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *event =
    [NSString stringWithFormat:@"%@-appeared",
     NSStringFromClass([self class])];
    [PTAnalytics logEvent:event];
    
    self.hasAppeared = YES;
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
}

@end
