//
//  UIButton+Utilities.m
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "UIButton+Utilities.h"
#import "UIView+Utilities.h"
#import <objc/runtime.h>
#import "Bedrock.h"

static char kPTApplyPressedToSuperviewObjectKey;

@implementation UIButton (Utilities)

- (BOOL)applyPressedToSuperview {
    NSNumber *value = (id)objc_getAssociatedObject(self, &kPTApplyPressedToSuperviewObjectKey);
    return value.boolValue;
}

- (void)setApplyPressedToSuperview:(BOOL)b {
    objc_setAssociatedObject(self, &kPTApplyPressedToSuperviewObjectKey, @(b), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)initialize {
    [self setupSwizzlesIfNecessary];
}

+ (void)setupSwizzlesIfNecessary {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
        PBReplaceSelectorForTargetWithSourceImpAndSwizzle(self,
                                                          @selector(setHighlighted:),
                                                          @selector(pt_setHighlighted:));
#pragma clang diagnostic pop
    });
}

#pragma mark -  Highlighted State

- (void)pt_setHighlighted:(BOOL)highlighted {
    [self pt_setHighlighted:highlighted];
    [self updateHighlightedState];
}

- (void)updateHighlightedState {
    
    BOOL applyToSuperview = [self applyPressedToSuperview];
    
    if (applyToSuperview) {
        [self.superview setViewPressed:self.isHighlighted animated:YES];
    } else {
        [self setViewPressed:self.isHighlighted animated:YES];
    }
}

@end
