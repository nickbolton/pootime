//
//  PTDefaultsManager.m
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTDefaultsManager.h"

static NSString * const kPTSelectedCalendarIDKey = @"pt-selected-calendar-id";
static NSString * const kPTLastEventIDKey = @"pt-last-event-id";

@implementation PTDefaultsManager

- (void)setSelectedCalendarID:(NSString *)selectedCalendarID {
    [self setString:selectedCalendarID forKey:kPTSelectedCalendarIDKey];
}

- (NSString *)selectedCalendarID {
    return [self stringForKey:kPTSelectedCalendarIDKey];
}

- (void)setLastEventID:(NSString *)lastEventID {
    [self setString:lastEventID forKey:kPTLastEventIDKey];
}

- (NSString *)lastEventID {
    return [self stringForKey:kPTLastEventIDKey];
}

#pragma mark - Private

- (NSString *)stringForKey:(NSString *)key {
    
    return
    [[NSUserDefaults standardUserDefaults]
     stringForKey:key];
}

- (void)setString:(NSString *)string forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:string
     forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)dateForKey:(NSString *)key {
    
    NSDate *date =
    [[NSUserDefaults standardUserDefaults]
     objectForKey:key];
    
    if ([date isKindOfClass:[NSDate class]]) {
        return date;
    }
    
    return nil;
}

- (void)setDate:(NSDate *)date forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:date
     forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)integerForKey:(NSString *)key {
    
    return
    [[NSUserDefaults standardUserDefaults]
     integerForKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setInteger:value
     forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)boolForKey:(NSString *)key {
    
    return
    [[NSUserDefaults standardUserDefaults]
     boolForKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setBool:value
     forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)registerDefaults {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *appDefaults =
    @{
      };

    [defaults registerDefaults:appDefaults];
}

- (void)resetDefaults {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults synchronize];
}

#pragma mark - Singleton Methods

+ (instancetype)sharedInstance {

    static dispatch_once_t predicate;
    static PTDefaultsManager *sharedInstance = nil;

    dispatch_once(&predicate, ^{
        sharedInstance = [[PTDefaultsManager alloc] init];
    });

    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
