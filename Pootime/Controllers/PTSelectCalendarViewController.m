//
//  PTSelectCalendarViewController.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTSelectCalendarViewController.h"
#import "Bedrock.h"
#import "PTCalendarManager.h"
#import "PTDefaultsManager.h"
#import "MMWormhole.h"
#import <EventKit/EventKit.h>
#import "PTDesign.h"
#import "PTGlobalConstants.h"

static CGFloat const kPTSelectCalendarNavBarHeight = 64.0f;
static CGFloat const kPTSelectCalendarSeparatorHeight = 1.0f;
static CGFloat const kPTSelectCalendarSeparatorMargin = 20.0f;

static NSString * const kPTCalendarCellID = @"cell-id";

@interface PTSelectCalendarViewController ()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) UIView *navigationBarSeparatorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSArray *allCalendars;

@end

@implementation PTSelectCalendarViewController

#pragma mark - Setup

- (void)setupContainer {
    self.view.backgroundColor = [PTDesign sharedInstance].pooColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupNavigationBar {
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage new]
     forBarMetrics:UIBarMetricsDefault];
}

- (void)setupTitleLabel {
    
    UILabel *view = [UILabel new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.text = PBLoc(@"Select Calendar");
    view.textAlignment = NSTextAlignmentCenter;
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont boldSystemFontOfSize:24.0f];
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandWidthToSuperview:view];
    [NSLayoutConstraint alignToTop:view withPadding:7.0f];
    [NSLayoutConstraint addHeightConstraint:kPTSelectCalendarNavBarHeight toView:view];
    
    self.titleLabel = view;
}

- (void)setupNavigationBarSeparator {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.3f];
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint addHeightConstraint:kPTSelectCalendarSeparatorHeight toView:view];
    [NSLayoutConstraint alignToLeft:view withPadding:kPTSelectCalendarSeparatorMargin];
    [NSLayoutConstraint alignToRight:view withPadding:-kPTSelectCalendarSeparatorMargin];
    [NSLayoutConstraint alignToTop:view withPadding:kPTSelectCalendarNavBarHeight];
    
    self.navigationBarSeparatorView = view;
}

- (void)setupTableView {
    
    static CGFloat const margin = 3.5f;

    self.tableViewConstraintInsets = UIEdgeInsetsMake(15.0f, margin, 0.0f, margin);
    
    [super setupTableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(50.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.rowHeight = 50.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView
     registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPTCalendarCellID];    
}

- (void)setupWormhole {
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial message from the wormhole
    NSDictionary *lastEvent = [self.wormhole messageWithIdentifier:kPTLastEventKey];
    
    if (lastEvent != nil) {
        [PTDefaultsManager sharedInstance].lastEventID = lastEvent[kPTLastEventEventKey];
        [PTDefaultsManager sharedInstance].lastCalendarID = lastEvent[kPTLastEventCalendarKey];
    }

    PBLog(@"lastEventIdentifier: %@", [PTDefaultsManager sharedInstance].lastEventID);
    
    [self.wormhole
     listenForMessageWithIdentifier:kPTLastEventKey
     listener:^(id messageObject) {
         
         NSDictionary *lastEvent = messageObject;
         
         if (lastEvent != nil) {
             [PTDefaultsManager sharedInstance].lastEventID = lastEvent[kPTLastEventEventKey];
             [PTDefaultsManager sharedInstance].lastCalendarID = lastEvent[kPTLastEventCalendarKey];
         }
         
         PBLog(@"lastEventIdentifier: %@", messageObject);
     }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContainer];
    [self setupNavigationBar];
    [self setupTitleLabel];
    [self setupNavigationBarSeparator];
    [self setupWormhole];
    
    __weak typeof(self) this = self;
    [[PTCalendarManager sharedInstance] allCalendars:^(NSArray *calendars) {
        this.allCalendars = calendars;
        [this reloadData:NO];
    }];
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [super applicationWillEnterForeground:notification];
    
    __weak typeof(self) this = self;
    [[PTCalendarManager sharedInstance] allCalendars:^(NSArray *calendars) {
        this.allCalendars = calendars;
        [this reloadData:NO];
    }];
}

#pragma mark - DataSource

- (NSArray *)buildDataSource {
    return self.allCalendars;
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPTCalendarCellID];

    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    cell.textLabel.text = calendar.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([calendar.calendarIdentifier isEqualToString:[PTDefaultsManager sharedInstance].selectedCalendarID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    
    if (calendar != nil) {
        [PTDefaultsManager sharedInstance].selectedCalendarID = calendar.calendarIdentifier;
        [self.wormhole passMessageObject:calendar.calendarIdentifier identifier:kPTSelectedCalendarKey];
        [self.tableView reloadData];
    }
}

@end
