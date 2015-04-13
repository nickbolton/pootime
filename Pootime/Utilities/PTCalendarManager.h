//
//  PTCalendarManager.h
//  Pootime
//
//  Created by Nick Bolton on 4/1/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKCalendar;

@interface PTCalendarManager : NSObject

- (void)calendarWithID:(NSString *)calendarID
            completion:(void(^)(EKCalendar *calendar))completionBlock;

- (void)markPooTimeWithCalendarID:(NSString *)calendarID
                  eventIdentifier:(NSString *)eventIdentifier
                       completion:(void(^)(NSString *eventIdentifier))completionBlock;

- (void)allCalendars:(void(^)(NSArray *calendars))completionBlock;
- (void)calendarSections:(void(^)(NSArray *sections))completionBlock;

+ (instancetype)sharedInstance;

@end
