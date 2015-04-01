//
//  PTCalendarManager.h
//  Pootime
//
//  Created by Nick Bolton on 4/1/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTCalendarManager : NSObject

@property (nonatomic, readonly) NSArray *calendarSections;

- (void)markPooTimeWithCalendarID:(NSString *)calendarID
                  eventIdentifier:(NSString *)eventIdentifier
                       completion:(void(^)(NSString *eventIdentifier))completionBlock;

+ (instancetype)sharedInstance;

@end
