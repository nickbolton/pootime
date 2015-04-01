//
//  InterfaceController.m
//  Pootime WatchKit Extension
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "InterfaceController.h"
#import "MMWormhole.h"
#import <EventKit/EventKit.h>
#import "Bedrock.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *calendarID;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSString *lastEventIdentifier;

@end

@implementation InterfaceController

- (void)setupEventStore {
    
    self.eventStore = [[EKEventStore alloc] init];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setupEventStore];
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial value for the selection message from the wormhole
    self.calendarID = [self.wormhole messageWithIdentifier:@"calendarIdentifier"];

    NSLog(@"calendarIdentifier: %@", self.calendarID);
    
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    
    __weak typeof(self) this = self;
    [self.wormhole listenForMessageWithIdentifier:@"calendarIdentifier" listener:^(id messageObject) {
        this.calendarID = messageObject;
        NSLog(@"calendarIdentifier: %@", this.calendarID);
    }];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - Actions

- (IBAction)pootime:(id)sender {
//    [self.wormhole passMessageObject:[NSDate date] identifier:@"pootime"];
    
    __weak typeof(self) this = self;
    
    [self.eventStore
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {

         if (granted) {
             [this doPooTime];
         }
     }];
}

- (void)doPooTime {

    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    components.minute = 15;
    
    NSDate *now = [NSDate date];
    NSDate *startTime = now;
    NSDate *endTime = [currentCalendar dateByAddingComponents:components toDate:startTime options:0];
    
    EKCalendar *calendar = [self.eventStore calendarWithIdentifier:self.calendarID];

    if (self.lastEventIdentifier != nil) {
        
        EKEvent *event = [self.eventStore eventWithIdentifier:self.lastEventIdentifier];
        
        if (event != nil) {
            
            if ([event.endDate isGreaterThan:startTime]) {
                
                event.endDate = endTime;
                
                NSError *error = nil;
                [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
                
                if (error != nil) {
                    PBLog(@"Error saving event: %@", error);
                }

                return;
            }
        }
    }
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.availability = EKEventAvailabilityBusy;
    event.title = @"pOOO Time";
    event.calendar = calendar;
    event.startDate = startTime;
    event.endDate = endTime;
    
    NSError *error = nil;
    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    
    if (error != nil) {
        PBLog(@"Error saving event: %@", error);
    }

    self.lastEventIdentifier = event.eventIdentifier;
}

@end



