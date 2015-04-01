//
//  InterfaceController.m
//  Pootime WatchKit Extension
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "InterfaceController.h"
#import "MMWormhole.h"
#import "Bedrock.h"
#import "PTCalendarManager.h"

@interface InterfaceController()

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) NSString *calendarID;
@property (nonatomic, strong) NSString *lastEventIdentifier;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial value for the selection message from the wormhole
    self.calendarID = [self.wormhole messageWithIdentifier:@"calendarIdentifier"];
    self.lastEventIdentifier = [self.wormhole messageWithIdentifier:@"lastEventIdentifier"];

    NSLog(@"calendarIdentifier: %@", self.calendarID);
    NSLog(@"lastEventIdentifier: %@", self.lastEventIdentifier);
    
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    
    __weak typeof(self) this = self;
    [self.wormhole
     listenForMessageWithIdentifier:@"calendarIdentifier"
     listener:^(id messageObject) {
        this.calendarID = messageObject;
        PBLog(@"calendarIdentifier: %@", this.calendarID);
    }];
    
    [self.wormhole
     listenForMessageWithIdentifier:@"lastEventIdentifier"
     listener:^(id messageObject) {
         this.lastEventIdentifier = messageObject;
         PBLog(@"lastEventIdentifier: %@", this.lastEventIdentifier);
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
    
    [[PTCalendarManager sharedInstance]
     markPooTimeWithCalendarID:self.calendarID
     eventIdentifier:self.lastEventIdentifier
     completion:^(NSString *eventIdentifier) {
         
         if (eventIdentifier != nil) {
             
             [self.wormhole
              passMessageObject:eventIdentifier
              identifier:@"lastEventIdentifier"];
         }
     }];
}

@end



