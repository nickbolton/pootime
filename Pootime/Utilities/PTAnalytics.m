//
//  PTAnalytics.m
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTAnalytics.h"
#import "Bedrock.h"

@implementation PTAnalytics

+ (void)logEvent:(NSString *)eventName {
#if DEBUG
    PBLog(@"%@ - %@", NSStringFromClass(self), eventName);
#endif
//    [Flurry logEvent:eventName];
}

+ (void)logEvent:(NSString *)eventName
  withParameters:(NSDictionary *)parameters {
#if DEBUG
    PBLog(@"%@ - %@", NSStringFromClass(self), eventName);
#endif
//    [Flurry logEvent:eventName withParameters:parameters];
}

@end
