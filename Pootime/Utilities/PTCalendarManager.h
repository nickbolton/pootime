//
//  PTCalendarManager.h
//  Pootime
//
//  Created by Nick Bolton on 4/1/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKCalendar;
@class EKEvent;

@interface PTCalendarManager : NSObject

- (void)calendarWithID:(NSString *)calendarID
            completion:(void(^)(EKCalendar *calendar))completionBlock;

- (void)eventWithID:(NSString *)eventID
         completion:(void(^)(EKEvent *event))completionBlock;

- (void)markPooTimeWithCalendarID:(NSString *)calendarID
                  eventIdentifier:(NSString *)eventIdentifier
                       completion:(void(^)(EKEvent *event))completionBlock;

- (void)cancelPooTimeWithCalendarID:(NSString *)calendarID
                    eventIdentifier:(NSString *)eventIdentifier
                         completion:(void(^)(void))completionBlock;

- (void)allCalendars:(void(^)(NSArray *calendars))completionBlock;
- (void)calendarSections:(void(^)(NSArray *sections))completionBlock;

+ (instancetype)sharedInstance;

@end
