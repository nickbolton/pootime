//
//  PTInterfaceController.m
//  Pootime WatchKit Extension
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTInterfaceController.h"
#import "MMWormhole.h"
#import "Bedrock.h"
#import "PTCalendarManager.h"
#import "PTEventRunningView.h"
#import "PTGlobalConstants.h"
#import <EventKit/EventKit.h>

static NSInteger const kPTPooImageCount = 37;

@interface PTInterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *calendarID;
@property (nonatomic, strong) NSString *lastEventIdentifier;
@property (nonatomic, strong) NSString *lastCalendarIdentifier;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *pooButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *cancelButton;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *buttonGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *label;
@property (nonatomic, strong) NSTimer *eventTimer;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic) BOOL khaiGuard;

@end

@implementation PTInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setupViews];
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial value for the selection message from the wormhole
    self.calendarID = [self.wormhole messageWithIdentifier:kPTSelectedCalendarKey];
    
    NSDictionary *lastEvent = [self.wormhole messageWithIdentifier:kPTLastEventKey];

    self.lastEventIdentifier = lastEvent[kPTLastEventEventKey];
    self.lastCalendarIdentifier = lastEvent[kPTLastEventCalendarKey];

    NSLog(@"calendarIdentifier: %@", self.calendarID);
    NSLog(@"lastEventIdentifier: %@", self.lastEventIdentifier);
    NSLog(@"lastCalendarIdentifier: %@", self.lastCalendarIdentifier);
    
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    
    __weak typeof(self) this = self;
    [self.wormhole
     listenForMessageWithIdentifier:kPTSelectedCalendarKey
     listener:^(id messageObject) {
        this.calendarID = messageObject;
        PBLog(@"calendarIdentifier: %@", this.calendarID);
    }];
    
    [self.wormhole
     listenForMessageWithIdentifier:kPTLastEventKey
     listener:^(id messageObject) {
         
         NSDictionary *lastEvent = messageObject;
         
         this.lastEventIdentifier = lastEvent[kPTLastEventEventKey];
         this.lastCalendarIdentifier = lastEvent[kPTLastEventCalendarKey];
         [this checkForCurrentEvent];

         PBLog(@"lastEventIdentifier: %@", this.lastEventIdentifier);
         NSLog(@"lastCalendarIdentifier: %@", this.lastCalendarIdentifier);
     }];
}

- (void)willActivate {
    [super willActivate];
    [self checkForCurrentEvent];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - Setup

- (void)setupViews {
    [self setupButton];
    [self setupLabel];
}

- (void)setupButton {
    [self.buttonGroup setBackgroundImageNamed:@"poo-button-initial-animation"];
}

- (void)setupLabel {
    [self restoreLabel];
}

#pragma mark - Actions

- (IBAction)pootime:(id)sender {
    
    if (self.khaiGuard) {
        return;
    }

    if (self.calendarID == nil) {
        [self flashNoCalendarSet];
        return;
    }
    
    self.khaiGuard = YES;
    self.pooButton.enabled = NO;
    
    __weak typeof(self) this = self;
    
    [[PTCalendarManager sharedInstance]
     markPooTimeWithCalendarID:self.calendarID
     eventIdentifier:self.lastEventIdentifier
     completion:^(EKEvent *event) {
         
         if (event != nil) {
             
             NSDictionary *lastEvent =
             @{
               kPTLastEventCalendarKey : self.calendarID,
               kPTLastEventEventKey : event.eventIdentifier,
               };
             
             [this.wormhole
              passMessageObject:lastEvent
              identifier:kPTLastEventKey];

             [this startPooTime:NO event:event];
         }
         
         this.khaiGuard = NO;
     }];
}

- (void)startPooTime:(BOOL)continuing event:(EKEvent *)event {
    
    NSDate *now = [NSDate date];

    if (event == nil || [event.endDate isLessThanOrEqualTo:now]) {
        return;
    }
    
    self.label.hidden = YES;
    self.cancelButton.hidden = NO;
    
    NSDate *endDate = [event.endDate dateByAddingSeconds:-14.5*kPTSecondsPerMinute];
    
    self.endTime = endDate;
    [self startWatchTimer];

    if (continuing) {
        [self setCountdownState];
        return;
    }
    
    NSRange range = NSMakeRange(0, kPTPooImageCount);
    
    static NSTimeInterval const duration = .25f;
    
    [self.buttonGroup
     startAnimatingWithImagesInRange:range
     duration:.25f
     repeatCount:1];
    
    __weak typeof(self) this = self;
    
    NSTimeInterval delayInSeconds = duration + .01f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [this setCountdownState];
    });
}

- (void)setCountdownState {

    NSDate *now = [NSDate date];
    NSTimeInterval remainingTime = [self.endTime timeIntervalSinceDate:now];
    NSTimeInterval roundedRemainingMinutes = ceilf(remainingTime / kPTSecondsPerMinute);
    
    NSTimeInterval framesPerMinute = (float)kPTPooImageCount / kPTDefaultPooTimeInMinutes;
    
    NSInteger startIndex = roundedRemainingMinutes * framesPerMinute;
    startIndex = MAX(0, startIndex);

    NSInteger length = kPTPooImageCount - startIndex;
    NSRange range = NSMakeRange(startIndex, length);

    [self.buttonGroup setBackgroundImageNamed:@"poo-button"];
    [self.buttonGroup
     startAnimatingWithImagesInRange:range
     duration:remainingTime
     repeatCount:1];
}

- (IBAction)cancel:(id)sender {
    
    __weak typeof(self) this = self;
    
    self.cancelButton.enabled = NO;
    
    [self cancelWatchTimer];
    [self.buttonGroup stopAnimating];
    [self.buttonGroup setBackgroundImageNamed:@"poo-button-initial-animation0"];
    [self.buttonGroup setBackgroundImageNamed:@"poo-button-initial-animation"];

    [[PTCalendarManager sharedInstance]
     cancelPooTimeWithCalendarID:self.lastCalendarIdentifier
     eventIdentifier:self.lastEventIdentifier
     completion:^{
         [this setDefaultUIState];
     }];
}

- (void)setDefaultUIState {
    
    self.cancelButton.enabled = YES;
    self.label.hidden = NO;
    self.cancelButton.hidden = YES;
    self.pooButton.enabled = YES;
}

- (void)checkForCurrentEvent {
    
    __weak typeof(self) this = self;
    
    [[PTCalendarManager sharedInstance] eventWithID:self.lastEventIdentifier completion:^(EKEvent *event) {
        
        if (event != nil) {

            NSDate *now = [NSDate date];

            if ([event.endDate isGreaterThan:now]) {
                [this startPooTime:YES event:event];
            } else {
                
                [this setDefaultUIState];
                [this cancel:nil];
            }
        }
    }];
}

#pragma mark - Private

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

- (void)flashNoCalendarSet {
    
    self.label.text =
    [NSString
     stringWithFormat:PBLoc(@"No Calendar is Set."),
     kPTDefaultPooTimeInMinutes];
    
    __weak typeof(self) this = self;
    NSTimeInterval delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [this restoreLabel];
    });

}

- (void)restoreLabel {
    
    self.label.text =
    [NSString
     stringWithFormat:PBLoc(@"Put %ld Minutes on Your Calendar"),
     kPTDefaultPooTimeInMinutes];
}

@end



