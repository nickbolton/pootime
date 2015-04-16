//
//  PTDefaultsManager.h
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTDefaultsManager : NSObject

@property (nonatomic, strong) NSString *selectedCalendarID;
@property (nonatomic, strong) NSString *lastEventID;
@property (nonatomic, strong) NSString *lastCalendarID;

+ (instancetype)sharedInstance;
- (void)registerDefaults;
- (void)resetDefaults;

@end
