//
//  PTCalendarManager.m
//  Pootime
//
//  Created by Nick Bolton on 4/1/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTCalendarManager.h"
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>
#import "Bedrock.h"

@interface PTCalendarManager()

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation PTCalendarManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupEventStore];
    }
    return self;
}

- (void)setupEventStore {
    self.eventStore = [[EKEventStore alloc] init];    
}

#pragma mark - Getters and Setters

- (void)calendarSections:(void(^)(NSArray *sections))completionBlock {
    
    __weak typeof(self) this = self;
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
       
            NSArray *allCalendars =
            [this.eventStore calendarsForEntityType:EKEntityTypeEvent];
            
            NSPredicate *predicate =
            [NSPredicate
             predicateWithFormat:@"type != %d AND allowsContentModifications != 0 AND NOT title contains[c] %@ AND NOT title contains[c] %@",
             EKCalendarTypeBirthday, @"birthday", @"holiday"];
            
            NSArray *filteredCalendars =
            [allCalendars filteredArrayUsingPredicate:predicate];
            
            NSMutableDictionary *buckets = [NSMutableDictionary dictionary];
            
            for (EKCalendar *calendar in filteredCalendars) {
                
                NSMutableArray *calendars = buckets[calendar.source.sourceIdentifier];
                
                if (calendars == nil) {
                    calendars = [NSMutableArray array];
                    buckets[calendar.source.sourceIdentifier] = calendars;
                }
                
                [calendars addObject:calendar];
            }
            
            NSSortDescriptor *sorter =
            [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
            
            NSArray *sources = buckets.allKeys;
            sources = [sources sortedArrayUsingDescriptors:@[sorter]];
            
            NSMutableArray *sections = [NSMutableArray array];
            
            for (NSString *sourceID in sources) {
                
                NSArray *calendars = buckets[sourceID];
                calendars = [calendars sortedArrayUsingDescriptors:@[sorter]];
                
                [sections addObject:calendars];
            }
            
            if (completionBlock != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(sections);
                });
            }
        }
    }];
}

- (void)allCalendars:(void(^)(NSArray *calendars))completionBlock {

    __weak typeof(self) this = self;
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        NSSortDescriptor *sorter =
        [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        
        NSArray *allCalendars =
        [this.eventStore calendarsForEntityType:EKEntityTypeEvent];
        
        NSPredicate *predicate =
        [NSPredicate
         predicateWithFormat:@"type != %d AND allowsContentModifications != 0 AND NOT title contains[c] %@ AND NOT title contains[c] %@",
         EKCalendarTypeBirthday, @"birthday", @"holiday"];
        
        NSArray *filteredCalendars =
        [allCalendars filteredArrayUsingPredicate:predicate];
        
        filteredCalendars = [filteredCalendars sortedArrayUsingDescriptors:@[sorter]];
        
        if (completionBlock != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(filteredCalendars);
            });
        }
    }];
}

#pragma mark - Public

- (void)markPooTimeWithCalendarID:(NSString *)calendarID
                  eventIdentifier:(NSString *)eventIdentifier
                       completion:(void(^)(NSString *eventIdentifier))completionBlock {
    
    __weak typeof(self) this = self;
    
    [self.eventStore
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {

         if (granted) {
             
             NSString *newEventIdentifier =
             [this
              doMarkPooTimeWithCalendarID:calendarID
              eventIdentifier:eventIdentifier];
             
             if (completionBlock != nil) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completionBlock(newEventIdentifier);
	                });
             }
             
         } else {
             
             if (completionBlock != nil) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completionBlock(nil);
	                });
             }
         }
     }];
}

- (void)calendarWithID:(NSString *)calendarID
            completion:(void(^)(EKCalendar *calendar))completionBlock {

    __weak typeof(self) this = self;
    
    [self.eventStore
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {

         EKCalendar *calendar = [this.eventStore calendarWithIdentifier:calendarID];
         
         if (completionBlock != nil) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 completionBlock(calendar);
             });
         }
     }];
}

- (NSString *)doMarkPooTimeWithCalendarID:(NSString *)calendarID
                          eventIdentifier:(NSString *)eventIdentifier {

    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    components.minute = 15;
    
    NSDate *now = [NSDate date];
    NSDate *startTime = now;
    NSDate *endTime = [currentCalendar dateByAddingComponents:components toDate:startTime options:0];
    
    EKCalendar *calendar = [self.eventStore calendarWithIdentifier:calendarID];
    
    if (eventIdentifier != nil) {
        
        EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];
        
        if (event != nil) {
            
            if ([event.endDate isGreaterThan:startTime]) {
                
                event.endDate = endTime;
                
                NSError *error = nil;
                [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
                
                if (error != nil) {
                    PBLog(@"Error saving event: %@", error);
                }
                
                return event.eventIdentifier;
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
    
    return event.eventIdentifier;
}

#pragma mark - Singleton Methods

+ (instancetype)sharedInstance {
    
    static dispatch_once_t predicate;
    static PTCalendarManager *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[PTCalendarManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
