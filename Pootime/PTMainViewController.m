//
//  PTMainViewController.m
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTMainViewController.h"
#import "Bedrock.h"
#import "PTDesign.h"
#import "PTCalendarManager.h"
#import "PTDefaultsManager.h"
#import "MMWormhole.h"
#import "PTMainFooterCell.h"
#import "PTSelectCalendarViewController.h"
#import <EventKit/EventKit.h>

static CGFloat const kPTMainViewControllerNavBarHeight = 64.0f;
static CGFloat const kPTMainViewControllerFooterHeight = 64.0f;
static CGFloat const kPTMainViewControllerSeparatorHeight = 1.0f;
static CGFloat const kPTMainViewControllerSeparatorMargin = 20.0f;
static CGFloat const kPTMainViewControllerButtonContainerSize = 252.0f;
static NSString * const kPTMainViewControllerFooterCellID = @"footer-cell";

@interface PTMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *navigationBarSeparatorView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *buttonTextContainer;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UITableView *footerTableView;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *selectedCalendarName;

@end

@implementation PTMainViewController

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
    view.text = PBLoc(@"PooTime");
    view.textAlignment = NSTextAlignmentCenter;
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont boldSystemFontOfSize:24.0f];
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandWidthToSuperview:view];
    [NSLayoutConstraint alignToTop:view withPadding:7.0f];
    [NSLayoutConstraint addHeightConstraint:kPTMainViewControllerNavBarHeight toView:view];
    
    self.titleLabel = view;
}

- (void)setupContentContainer {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandWidthToSuperview:view];
    [NSLayoutConstraint alignToTop:view withPadding:kPTMainViewControllerFooterHeight];
    [NSLayoutConstraint alignToBottom:view withPadding:-kPTMainViewControllerFooterHeight];
    
    self.contentContainer = view;
}

- (void)setupNavigationBarSeparator {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.3f];
    
    [self.contentContainer addSubview:view];
    
    [NSLayoutConstraint addHeightConstraint:kPTMainViewControllerSeparatorHeight toView:view];
    [NSLayoutConstraint alignToLeft:view withPadding:kPTMainViewControllerSeparatorMargin];
    [NSLayoutConstraint alignToRight:view withPadding:-kPTMainViewControllerSeparatorMargin];
    [NSLayoutConstraint alignToTop:view withPadding:0.0f];
    
    self.navigationBarSeparatorView = view;
}

- (void)setupFooterSeparator {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.3f];
    
    [self.contentContainer addSubview:view];
    
    [NSLayoutConstraint addHeightConstraint:kPTMainViewControllerSeparatorHeight toView:view];
    [NSLayoutConstraint alignToLeft:view withPadding:kPTMainViewControllerSeparatorMargin];
    [NSLayoutConstraint alignToRight:view withPadding:-kPTMainViewControllerSeparatorMargin];
    [NSLayoutConstraint alignToBottom:view withPadding:0.0f];
    
    self.navigationBarSeparatorView = view;
}

- (void)setupButtonTextContainer {
 
    static CGFloat const height = 302.0f;

    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandWidthToSuperview:view];
    [NSLayoutConstraint addHeightConstraint:height toView:view];
    [NSLayoutConstraint verticallyCenterView:view];

    self.buttonTextContainer = view;
}

- (void)setupButtonContainer {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithRGBHex:0x794C2A];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = kPTMainViewControllerButtonContainerSize / 2.0f;
    
    [self.buttonTextContainer addSubview:view];
    
    [NSLayoutConstraint addWidthConstraint:kPTMainViewControllerButtonContainerSize toView:view];
    [NSLayoutConstraint addHeightConstraint:kPTMainViewControllerButtonContainerSize toView:view];
    [NSLayoutConstraint horizontallyCenterView:view];
    [NSLayoutConstraint alignToTop:view withPadding:0.0f];

    self.buttonContainer = view;
}

- (void)setupButton {
    
    static CGFloat const size = 240.0f;
    
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = size / 2.0f;
    view.titleLabel.font = [UIFont systemFontOfSize:121.0f];
    [view setTitle:@"💩" forState:UIControlStateNormal];
    
    [view
     addTarget:self
     action:@selector(buttonTapped)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonContainer addSubview:view];
    
    [NSLayoutConstraint addWidthConstraint:size toView:view];
    [NSLayoutConstraint addHeightConstraint:size toView:view];
    [NSLayoutConstraint horizontallyCenterView:view];
    [NSLayoutConstraint verticallyCenterView:view];
    
    self.button = view;
}

- (void)setupLabel {
    
    static CGFloat const bottomSpace = 7.5f;
    static CGFloat const width = 120.0f;

    UILabel *view = [UILabel new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.text = PBLoc(@"Put 15 minutes on your calendar.");
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont systemFontOfSize:15.0f];
    view.numberOfLines = 0;
    view.textAlignment = NSTextAlignmentCenter;
    
    [self.buttonTextContainer addSubview:view];
    
    CGRect boundingRect =
    [view.text
     boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
     attributes:@{NSFontAttributeName : view.font}
     context:NULL];
    
    CGFloat height = ceilf(CGRectGetHeight(boundingRect));

    [NSLayoutConstraint addWidthConstraint:width toView:view];
    [NSLayoutConstraint addHeightConstraint:height toView:view];
    [NSLayoutConstraint horizontallyCenterView:view];
    [NSLayoutConstraint alignToBottom:view withPadding:bottomSpace];

    self.label = view;
}

- (void)setupFooterTableView {
    
    static CGFloat const margin = 3.5f;
    
    UITableView *tableView = [UITableView new];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorColor = [UIColor clearColor];
    tableView.rowHeight = kPTMainViewControllerFooterHeight;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:tableView];
    
    [NSLayoutConstraint alignToLeft:tableView withPadding:margin];
    [NSLayoutConstraint alignToRight:tableView withPadding:-margin];
    [NSLayoutConstraint alignToBottom:tableView withPadding:0.0f];
    [NSLayoutConstraint addHeightConstraint:kPTMainViewControllerFooterHeight toView:tableView];

    self.footerTableView = tableView;
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
    self.selectedCalendarName = PBLoc(@"Not Shared");
    [super viewDidLoad];
    [self setupWormhole];
    [self setupNavigationBar];
    [self setupTitleLabel];
    [self setupContentContainer];
    [self setupNavigationBarSeparator];
    [self setupContainer];
    [self setupButtonTextContainer];
    [self setupButtonContainer];
    [self setupButton];
    [self setupLabel];
    [self setupFooterSeparator];
    [self setupFooterTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSelectedCalendarName];
}

#pragma mark - Actions

- (void)buttonTapped {
    
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

#pragma mark - Private

- (void)presentSelectCalendarViewController {

    self.title = @"";
    PTSelectCalendarViewController *viewController = [PTSelectCalendarViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)updateSelectedCalendarName {

    __weak typeof(self) this = self;
    
    if ([PTDefaultsManager sharedInstance].selectedCalendarID.length > 0) {
        
        [[PTCalendarManager sharedInstance]
         calendarWithID:[PTDefaultsManager sharedInstance].selectedCalendarID
         completion:^(EKCalendar *calendar) {
             
             if (calendar != nil) {
                 
                 this.selectedCalendarName = calendar.title;                 
                 [this.footerTableView reloadData];
                 
             } else {
                 
                 this.selectedCalendarName = PBLoc(@"Not Shared");
             }
         }];
        
    } else {
        
        [[PTCalendarManager sharedInstance] allCalendars:^(NSArray *calendars) {
           
            EKCalendar *calendar = calendars.firstObject;

            if (calendar != nil) {
                
                [PTDefaultsManager sharedInstance].selectedCalendarID = calendar.calendarIdentifier;
                
                this.selectedCalendarName = calendar.title;
                [this.footerTableView reloadData];
                
            } else {
                
                this.selectedCalendarName = PBLoc(@"Not Shared");
            }
        }];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PTMainFooterCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:kPTMainViewControllerFooterCellID];
    
    if (cell == nil) {
        
        cell =
        [[PTMainFooterCell alloc]
         initWithStyle:UITableViewCellStyleValue1
         reuseIdentifier:kPTMainViewControllerFooterCellID];
    }
    
    cell.detailTextLabel.text = self.selectedCalendarName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self presentSelectCalendarViewController];
}

@end
