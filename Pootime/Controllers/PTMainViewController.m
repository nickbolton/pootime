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
#import "PTGlobalConstants.h"
#import <EventKit/EventKit.h>

static CGFloat const kPTMainViewControllerNavBarHeight = 64.0f;
static CGFloat const kPTMainViewControllerFooterHeight = 64.0f;
static CGFloat const kPTMainViewControllerSeparatorHeight = 1.0f;
static CGFloat const kPTMainViewControllerSeparatorMargin = 20.0f;
static CGFloat const kPTMainViewControllerButtonContainerSize = 252.0f;
static NSString * const kPTMainViewControllerFooterCellID = @"footer-cell";
static NSInteger const kPTPooImageCount = 37;

@interface PTMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *navigationBarSeparatorView;
@property (nonatomic, strong) UIView *footerSeparatorView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *buttonTextContainer;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *pooImageView;
@property (nonatomic, strong) UITableView *footerTableView;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *selectedCalendarName;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSTimer *eventTimer;
@property (nonatomic, strong) NSDictionary *currentMessage;

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
    
    self.footerSeparatorView = view;
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

- (void)setupPooImageView {
    
    UIImageView *view = [UIImageView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.alpha = 0.0f;
    
    [self.buttonContainer addSubview:view];
    
    NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationEqual
     toItem:self.button
     attribute:NSLayoutAttributeWidth
     multiplier:1.0f
     constant:0.0f];
    
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeHeight
     relatedBy:NSLayoutRelationEqual
     toItem:self.button
     attribute:NSLayoutAttributeHeight
     multiplier:1.0f
     constant:0.0f];
    
    NSLayoutConstraint *xCenterConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:self.button
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f];
    
    NSLayoutConstraint *yCenterConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:self.button
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0f
     constant:0.0f];
    
    [view.superview addConstraint:widthConstraint];
    [view.superview addConstraint:heightConstraint];
    [view.superview addConstraint:xCenterConstraint];
    [view.superview addConstraint:yCenterConstraint];
    
    self.pooImageView = view;
}

- (void)setupLabel {
    
    static CGFloat const bottomSpace = 7.5f;
    static CGFloat const width = 120.0f;

    UILabel *view = [UILabel new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont systemFontOfSize:15.0f];
    view.numberOfLines = 0;
    view.textAlignment = NSTextAlignmentCenter;
    view.text =
    [NSString
     stringWithFormat:PBLoc(@"Put %ld minutes on your calendar."),
     kPTDefaultPooTimeInMinutes];
    
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

- (void)setupCancelButton {
    
    static CGFloat const topSpace = 28.0f;
    
    UIImage *image = [UIImage imageNamed:@"cancel"];
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.alpha = 0.0f;
    
    [view setImage:image forState:UIControlStateNormal];
    [view setImage:image forState:UIControlStateHighlighted];
    
    [view
     addTarget:self
     action:@selector(cancel:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint addWidthConstraint:image.size.width toView:view];
    [NSLayoutConstraint addHeightConstraint:image.size.height toView:view];
    [NSLayoutConstraint horizontallyCenterView:view];
    
    NSLayoutConstraint *topConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeTop
     relatedBy:NSLayoutRelationEqual
     toItem:self.button
     attribute:NSLayoutAttributeBottom
     multiplier:1.0f
     constant:topSpace];
    
    [view.superview addConstraint:topConstraint];
    
    self.cancelButton = view;
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
    
    NSDictionary *lastEvent = [self.wormhole messageWithIdentifier:kPTLastEventKey];
    
    if (lastEvent != nil) {
        [PTDefaultsManager sharedInstance].lastEventID = lastEvent[kPTLastEventEventKey];
        [PTDefaultsManager sharedInstance].lastCalendarID = lastEvent[kPTLastEventCalendarKey];
    }
    
    NSLog(@"lastEventIdentifier: %@", [PTDefaultsManager sharedInstance].lastEventID);
    
    __weak typeof(self) this = self;
    
    [self.wormhole
     listenForMessageWithIdentifier:kPTLastEventKey
     listener:^(id messageObject) {
         
         if (this.currentMessage == nil || [this.currentMessage isEqualToDictionary:messageObject] == NO) {
             NSDictionary *lastEvent = messageObject;
             
             if (lastEvent != nil) {
                 [PTDefaultsManager sharedInstance].lastEventID = lastEvent[kPTLastEventEventKey];
                 [PTDefaultsManager sharedInstance].lastCalendarID = lastEvent[kPTLastEventCalendarKey];
             }
             
             [this checkForCurrentEvent];
             
             PBLog(@"lastEventIdentifier: %@", messageObject);
         }
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
    [self setupPooImageView];
    [self setupLabel];
    [self setupCancelButton];
    [self setupFooterSeparator];
    [self setupFooterTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSelectedCalendarName];
    [self checkForCurrentEvent];
}

#pragma mark - Actions

- (void)buttonTapped {
    
    __weak typeof(self) this = self;
    
    if (self.button.enabled == NO) {
        return;
    }
    
    if ([PTDefaultsManager sharedInstance].selectedCalendarID == nil) {
        
        NSString *message =
        PBLoc(@"Please select a calendar.");
        
        [UIAlertView
         presentOKAlertWithTitle:nil
         andMessage:message];
        return;
    }
    
    self.button.enabled = NO;
    
    [[PTCalendarManager sharedInstance]
     markPooTimeWithCalendarID:[PTDefaultsManager sharedInstance].selectedCalendarID
     eventIdentifier:[PTDefaultsManager sharedInstance].lastEventID
     completion:^(EKEvent *event) {
         
         if (event != nil) {
             
             NSDictionary *lastEvent =
             @{
               kPTLastEventCalendarKey : [PTDefaultsManager sharedInstance].selectedCalendarID,
               kPTLastEventEventKey : event.eventIdentifier,
               };
             
             this.currentMessage = lastEvent;
             
             [this.wormhole
              passMessageObject:lastEvent
              identifier:kPTLastEventKey];
             
             [this startPooTime:NO event:event];
         }
         
         this.button.enabled = YES;
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
                [this.wormhole passMessageObject:calendar.calendarIdentifier identifier:kPTSelectedCalendarKey];

                this.selectedCalendarName = calendar.title;
                [this.footerTableView reloadData];
                
            } else {
                
                this.selectedCalendarName = PBLoc(@"Not Shared");
            }
        }];
    }
}

- (void)checkForCurrentEvent {
    
    __weak typeof(self) this = self;
    
    [[PTCalendarManager sharedInstance] eventWithID:[PTDefaultsManager sharedInstance].lastEventID completion:^(EKEvent *event) {
        
        if (event != nil) {
            
            NSDate *now = [NSDate date];
            
            if ([event.endDate isGreaterThan:now]) {
                [this startPooTime:YES event:event];
            } else {
                
                [this setDefaultUIState:YES];
                [this cancel:nil];
            }
        }
    }];
}

- (void)startPooTime:(BOOL)continuing event:(EKEvent *)event {
    
    NSDate *now = [NSDate date];
    
    if (event == nil || [event.endDate isLessThanOrEqualTo:now]) {
        return;
    }
    
    [UIView
     animateWithDuration:.25f
     animations:^{
        
         self.label.alpha = 0.0f;
         self.cancelButton.alpha = 1.0f;
         self.button.alpha = 0.0f;
         self.pooImageView.alpha = 1.0f;
         self.footerSeparatorView.alpha = 0.0f;
         self.footerTableView.alpha = 0.0f;
     }];
    
    NSDate *endDate = [event.endDate dateByAddingSeconds:-14.5*kPTSecondsPerMinute];
    
    self.endTime = endDate;
    [self startWatchTimer];
    
    if (continuing) {
        [self setCountdownState];
        return;
    }
    
    static NSTimeInterval const duration = .25f;
    
    NSArray *images = [self initialAnimationImages];
    [self.pooImageView setAnimationImages:images];
    self.pooImageView.animationDuration = .25f;
    self.pooImageView.animationRepeatCount = 1;
    [self.pooImageView startAnimating];
    
    __weak typeof(self) this = self;
    
    NSTimeInterval delayInSeconds = duration + .01f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [this setCountdownState];
    });
}

- (NSArray *)initialAnimationImages {
    return [self animationImagesWithPrefix:@"poo-button-initial-animation" startIndex:0];
}

- (NSArray *)defaultAnimationImages:(NSInteger)startIndex {
    return [self animationImagesWithPrefix:@"poo-button" startIndex:startIndex];
}

- (NSArray *)animationImagesWithPrefix:(NSString *)prefix startIndex:(NSInteger)startIndex {

    NSMutableArray *result = [NSMutableArray array];
    
    for (NSInteger idx = startIndex; idx < kPTPooImageCount; idx++) {
        
        NSString *imageName = [NSString stringWithFormat:@"%@%ld", prefix, idx];
        UIImage *image = [UIImage imageNamed:imageName];
        [result addObject:image];
    }
    
    return result;
}

- (void)setCountdownState {
    
    NSDate *now = [NSDate date];
    NSTimeInterval remainingTime = [self.endTime timeIntervalSinceDate:now];
    NSTimeInterval roundedRemainingMinutes = ceilf(remainingTime / kPTSecondsPerMinute);
    
    NSTimeInterval framesPerMinute = (float)kPTPooImageCount / kPTDefaultPooTimeInMinutes;
    
    NSInteger startIndex = roundedRemainingMinutes * framesPerMinute;
    startIndex = MAX(0, startIndex);
    
    NSArray *images = [self defaultAnimationImages:startIndex];
    [self.pooImageView setAnimationImages:images];
    self.pooImageView.animationDuration = remainingTime;
    self.pooImageView.animationRepeatCount = 1;
    [self.pooImageView startAnimating];
}

- (IBAction)cancel:(id)sender {
    
    __weak typeof(self) this = self;
    
    self.cancelButton.enabled = NO;
    
    [self cancelWatchTimer];
    [self.pooImageView stopAnimating];
    
    [[PTCalendarManager sharedInstance]
     cancelPooTimeWithCalendarID:[PTDefaultsManager sharedInstance].lastCalendarID
     eventIdentifier:[PTDefaultsManager sharedInstance].lastEventID
     completion:^{
         [this setDefaultUIState:YES];
     }];
}

- (void)setDefaultUIState:(BOOL)animated {
    
    NSTimeInterval duration = animated ? .25f : 0.0f;
    
    [UIView
     animateWithDuration:duration
     animations:^{
         
         self.label.alpha = 1.0f;
         self.cancelButton.alpha = 0.0f;
         self.button.alpha = 1.0f;
         self.pooImageView.alpha = 0.0f;
         self.footerSeparatorView.alpha = 1.0f;
         self.footerTableView.alpha = 1.0f;
     }];
}

- (void)startWatchTimer {
    
    [self.eventTimer invalidate];

    self.eventTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:1.0f
     target:self
     selector:@selector(watchTimer:)
     userInfo:nil
     repeats:YES];
}

- (void)watchTimer:(NSTimer *)timer {
    
    NSDate *now = [NSDate date];
    
    if ([now isGreaterThanOrEqualTo:self.endTime]) {
        [self cancel:nil];
    }
}

- (void)cancelWatchTimer {
    [self.eventTimer invalidate];
    self.eventTimer = nil;
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