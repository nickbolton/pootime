//
//  NSLayoutConstraint+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#if TARGET_OS_IPHONE
#else
#import <Cocoa/Cocoa.h>
#endif

@interface NSLayoutConstraint (Bedrock)

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addMinWidthConstraint:(CGFloat)minWidth toView:(UIView *)view;
+ (NSLayoutConstraint *)addMaxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view;
+ (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width toView:(UIView *)view;
+ (NSArray *)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view;
+ (NSLayoutConstraint *)addMinHeightConstraint:(CGFloat)minHeight toView:(UIView *)view;
+ (NSLayoutConstraint *)addMaxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view;
+ (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height toView:(UIView *)view;
+ (NSArray *)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view;
+ (NSLayoutConstraint *)horizontallyCenterView:(UIView *)view;
+ (NSLayoutConstraint *)verticallyCenterView:(UIView *)view;
+ (NSLayoutConstraint *)horizontallyCenterView:(UIView *)view padding:(CGFloat)padding;
+ (NSLayoutConstraint *)verticallyCenterView:(UIView *)view padding:(CGFloat)padding;
+ (NSArray *)expandWidthToSuperview:(UIView *)view;
+ (NSArray *)expandHeightToSuperview:(UIView *)view;
+ (NSArray *)expandToSuperview:(UIView *)view;
+ (NSArray *)expandWidthToSuperview:(UIView *)view withInsets:(UIEdgeInsets)insets;
+ (NSArray *)expandHeightToSuperview:(UIView *)view withInsets:(UIEdgeInsets)insets;
+ (NSArray *)expandToSuperview:(UIView *)view withInsets:(UIEdgeInsets)insets;
+ (NSLayoutConstraint *)alignToTop:(UIView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToBottom:(UIView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToLeft:(UIView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToRight:(UIView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)verticallySpaceTopView:(UIView *)topView toBottomView:(UIView *)bottomView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)horizontallySpaceLeftView:(UIView *)leftView toRightView:(UIView *)rightView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignBottomOfView:(UIView *)view1 toBaselineOfView:(UIView *)view2 withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignTopView:(UIView *)topView toBottomView:(UIView *)bottomView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignRightView:(UIView *)rightView toLeftView:(UIView *)leftView withPadding:(CGFloat)padding;
#else
+ (NSLayoutConstraint *)addMinWidthConstraint:(CGFloat)minWidth toView:(NSView *)view;
+ (NSLayoutConstraint *)addMaxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view;
+ (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width toView:(NSView *)view;
+ (NSArray *)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view;
+ (NSLayoutConstraint *)addMinHeightConstraint:(CGFloat)minHeight toView:(NSView *)view;
+ (NSLayoutConstraint *)addMaxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view;
+ (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height toView:(NSView *)view;
+ (NSArray *)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view;
+ (NSLayoutConstraint *)horizontallyCenterView:(NSView *)view;
+ (NSLayoutConstraint *)verticallyCenterView:(NSView *)view;
+ (NSLayoutConstraint *)horizontallyCenterView:(NSView *)view padding:(CGFloat)padding;
+ (NSLayoutConstraint *)verticallyCenterView:(NSView *)view padding:(CGFloat)padding;
+ (NSArray *)expandWidthToSuperview:(NSView *)view;
+ (NSArray *)expandHeightToSuperview:(NSView *)view;
+ (NSArray *)expandToSuperview:(NSView *)view;
+ (NSArray *)expandWidthToSuperview:(NSView *)view withInsets:(NSEdgeInsets)insets;
+ (NSArray *)expandHeightToSuperview:(NSView *)view withInsets:(NSEdgeInsets)insets;
+ (NSArray *)expandToSuperview:(NSView *)view withInsets:(NSEdgeInsets)insets;
+ (NSLayoutConstraint *)alignToTop:(NSView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToBottom:(NSView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToLeft:(NSView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignToRight:(NSView *)view withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)verticallySpaceTopView:(NSView *)topView toBottomView:(NSView *)bottomView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)horizontallySpaceLeftView:(NSView *)leftView toRightView:(NSView *)rightView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignBottomOfView:(NSView *)view1 toBaselineOfView:(NSView *)view2 withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignTopView:(NSView *)topView toBottomView:(NSView *)bottomView withPadding:(CGFloat)padding;
+ (NSLayoutConstraint *)alignRightView:(NSView *)rightView toLeftView:(NSView *)leftView withPadding:(CGFloat)padding;
#endif


@end
