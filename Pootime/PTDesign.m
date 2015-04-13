//
//  PTDesign.m
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTDesign.h"
#import "Bedrock.h"

@implementation PTDesign

- (UIColor *)pooColor {
    return [UIColor colorWithRGBHex:0x89552b];
}

#pragma mark - Singleton Methods

+ (instancetype)sharedInstance {
    
    static dispatch_once_t predicate;
    static PTDesign *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[PTDesign alloc] init];
    });
    
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
