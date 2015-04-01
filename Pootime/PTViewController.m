//
//  PTViewController.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTViewController.h"
#import "Bedrock.h"
#import "PTCalendarManager.h"
#import "PTDefaultsManager.h"
#import "MMWormhole.h"
#import <EventKit/EventKit.h>

static CGFloat const kPTBottomContainerHeight = 100.0f;

static NSString * const kPTCalendarCellID = @"cell-id";

@interface PTViewController ()

@property (nonatomic) BOOL granted;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) UIButton *pooTimeButton;

@end

@implementation PTViewController

#pragma mark - Setup

- (void)setupTableView {
    self.tableViewConstraintInsets = UIEdgeInsetsMake(0.0f, 0.0f, kPTBottomContainerHeight, 0.0f);
    
    [super setupTableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(50.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.rowHeight = 50.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView
     registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPTCalendarCellID];
    
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class]
     forHeaderFooterViewReuseIdentifier:@"header"];
}

- (void)setupPooTimeButton {
    
    static CGFloat const height = 50.0f;
    
    UIButton *view = [UIButton buttonWithType:UIButtonTypeSystem];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view setTitle:@"pOOO Time" forState:UIControlStateNormal];
    
    [view
     addTarget:self
     action:@selector(pooTimeTapped)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandWidthToSuperview:view];
    [NSLayoutConstraint addHeightConstraint:height toView:view];
    [NSLayoutConstraint horizontallyCenterView:view];
    [NSLayoutConstraint alignToBottom:view withPadding:-(kPTBottomContainerHeight-height)/2.0f];
    
    self.pooTimeButton = view;
}

- (void)setupWormhole {
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial message from the wormhole
    NSString *eventID = [self.wormhole messageWithIdentifier:@"lastEventIdentifier"];
    
    if (eventID != nil) {
        [PTDefaultsManager sharedInstance].lastEventID = eventID;
    }

    NSLog(@"lastEventIdentifier: %@", eventID);
    
    [self.wormhole
     listenForMessageWithIdentifier:@"lastEventIdentifier"
     listener:^(id messageObject) {
         
         if (messageObject != nil) {
             [PTDefaultsManager sharedInstance].lastEventID = messageObject;
         }
         
         PBLog(@"lastEventIdentifier: %@", messageObject);
     }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPooTimeButton];
    [self setupWormhole];
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [super applicationWillEnterForeground:notification];
    [self reloadData:NO];
}

#pragma mark - Actions

- (void)pooTimeTapped {
    
    [[PTCalendarManager sharedInstance]
     markPooTimeWithCalendarID:[PTDefaultsManager sharedInstance].selectedCalendarID
     eventIdentifier:[PTDefaultsManager sharedInstance].lastEventID
     completion:^(NSString *eventIdentifier) {
         
         if (eventIdentifier != nil) {
             
             [self.wormhole
              passMessageObject:eventIdentifier
              identifier:@"lastEventIdentifier"];
         }
     }];
}

#pragma mark - DataSource

- (NSArray *)buildDataSource {
    return [PTCalendarManager sharedInstance].calendarSections;
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPTCalendarCellID];

    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    cell.textLabel.text = calendar.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:21.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([calendar.calendarIdentifier isEqualToString:[PTDefaultsManager sharedInstance].selectedCalendarID]) {
        cell.backgroundColor = [[UIColor brownColor] colorWithAlpha:.7f];
        cell.contentView.backgroundColor = [[UIColor brownColor] colorWithAlpha:.7f];
    } else {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sectionArray = [self dataSourceArrayAtSection:section];
    return sectionArray.count;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *sectionArray = [self dataSourceArrayAtSection:section];
    EKCalendar *calendar = sectionArray.firstObject;
    return calendar.source.title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    
    if (calendar != nil) {
        [PTDefaultsManager sharedInstance].selectedCalendarID = calendar.calendarIdentifier;
        [self.wormhole passMessageObject:calendar.calendarIdentifier identifier:@"calendarIdentifier"];
        [self.tableView reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UITableViewHeaderFooterView *header =
    [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    header.contentView.backgroundColor = [UIColor blackColor];
    header.textLabel.textColor = [UIColor whiteColor];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
}

@end
