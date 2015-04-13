//
//  PTAnalytics.h
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTAnalytics : NSObject

+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName
  withParameters:(NSDictionary *)parameters;

@end
