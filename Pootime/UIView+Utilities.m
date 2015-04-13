//
//  UIView+Utilities.m
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "UIView+Utilities.h"

@implementation UIView (Utilities)

- (void)setViewPressed:(BOOL)pressed animated:(BOOL)animated {
    
    NSTimeInterval duration = .2f;
    
    [UIView
     animateWithDuration:animated ? duration : 0.0f
     delay:0.0f
     options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction
     animations:^{

         self.alpha = pressed ? .5f : 1.0f;
         
     } completion:nil];
}

@end
