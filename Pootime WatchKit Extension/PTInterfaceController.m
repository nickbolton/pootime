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
@property (nonatomic) NSInteger currentAnimationFrame;
@property (nonatomic, strong) NSArray *animationFrames;

@end

@implementation PTInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setupAnimationFrames];
    [self setupViews];
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial value for the selection message from the wormhole
    self.calendarID = [self.wormhole messageWithIdentifier:kPTSelectedCalendarKey];
    
    NSDictionary *lastEvent = [self.wormhole messageWithIdentifier:kPTLastEventKey];
    [self handleReceivedEvent:lastEvent];
    
    PBLog(@"calendarIdentifier: %@", self.calendarID);
    
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
         [this handleReceivedEvent:lastEvent];
         [this checkForCurrentEvent];
     }];
}

- (void)willActivate {
    [super willActivate];
    [self checkForCurrentEvent];
    
    __weak typeof(self) this = self;
    
    [self.class
     openParentApplication:@{}
     reply:^(NSDictionary *replyInfo, NSError *error) {
         this.calendarID = replyInfo[kPTSelectedCalendarKey];
     }];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - Setup

- (void)setupAnimationFrames {

    NSMutableArray *animationFrames = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < kPTPooImageCount; idx++) {
        
        NSString *imageName = [NSString stringWithFormat:@"poo-button-frame%ld", idx];
        UIImage *image = [UIImage imageNamed:imageName];
        [animationFrames addObject:image];
    }
    
    self.animationFrames = animationFrames;
}

- (void)setupViews {
    [self setupButton];
    [self setupLabel];
}

- (void)setupButton {
    
    UIImage *image = self.animationFrames[0];
    [self.buttonGroup setBackgroundImage:image];
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
    
    self.endTime = event.endDate;
    [self startWatchTimer];

    if (continuing) {
        [self updateCurrentAnimationFrame];
        return;
    }
    
    NSRange range = NSMakeRange(0, kPTPooImageCount);
    
    [self.buttonGroup setBackgroundImageNamed:@"poo-button-frame"];
    
    [self.buttonGroup
     startAnimatingWithImagesInRange:range
     duration:.5f
     repeatCount:1];
}

- (NSInteger)animationFrameForRemainingTime {
    
    NSDate *now = [NSDate date];
    NSTimeInterval remainingTime = [self.endTime timeIntervalSinceDate:now];
    NSTimeInterval roundedRemainingTime = floor(remainingTime);
    
    NSTimeInterval framesPerSecond = (float)kPTPooImageCount / (kPTDefaultPooTimeInMinutes*60.0f);
    
    NSInteger frameIndex = roundedRemainingTime * framesPerSecond;
    frameIndex = MAX(0, frameIndex);
    frameIndex = MIN(kPTPooImageCount-1, frameIndex);
    
    return frameIndex;
}

- (IBAction)cancel:(id)sender {
    
    [self doCancel:self.lastEventIdentifier];
    self.lastEventIdentifier = nil;
    self.lastCalendarIdentifier = nil;
    [self.wormhole
     passMessageObject:nil
     identifier:kPTLastEventKey];
}

- (void)doCancel:(NSString *)eventID {

    __weak typeof(self) this = self;
    
    self.cancelButton.enabled = NO;
    
    [self cancelWatchTimer];
    
    UIImage *image = self.animationFrames[0];
    [self.buttonGroup setBackgroundImage:image];

    [[PTCalendarManager sharedInstance]
     cancelPooTimeWithEventIdentifier:eventID
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

- (void)handleReceivedEvent:(NSDictionary *)lastEvent {
    
    if (lastEvent != nil) {
        self.lastEventIdentifier = lastEvent[kPTLastEventEventKey];
        self.lastCalendarIdentifier = lastEvent[kPTLastEventCalendarKey];
    } else {
        
        [self doCancel:self.lastEventIdentifier];
        self.lastEventIdentifier = nil;
        self.lastCalendarIdentifier = nil;
    }
    
    PBLog(@"lastEventIdentifier: %@", self.lastEventIdentifier);
    PBLog(@"lastCalendarIdentifier: %@", self.lastCalendarIdentifier);
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
    
    [self updateCurrentAnimationFrame];

    if (self.currentAnimationFrame <= 0) {
        [self cancel:nil];
    }
}

- (void)updateCurrentAnimationFrame {
    
    NSInteger frameIndex = [self animationFrameForRemainingTime];
    UIImage *image = self.animationFrames[frameIndex];
    self.currentAnimationFrame = frameIndex;
    [self.buttonGroup setBackgroundImage:image];
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



