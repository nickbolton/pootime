//
//  PTDesign.h
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTDesign : NSObject

@property (nonatomic, readonly) UIColor *pooColor;

+ (instancetype)sharedInstance;

@end
