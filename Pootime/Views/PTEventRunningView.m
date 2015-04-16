//
//  PTEventRunningView.m
//  Pootime
//
//  Created by Nick Bolton on 4/13/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTEventRunningView.h"
#import "Bedrock.h"

static CGFloat const kPTEventRunningPooPercent = 0.66875f;

@interface PTEventRunningView()

@property (nonatomic, strong) UIView *pooContainer;
@property (nonatomic, strong) UIButton *pooButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSLayoutConstraint *pooContainerHeightConstraint;

@end

@implementation PTEventRunningView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setupViews];
}

#pragma mark - Setup

- (void)setupViews {
    [self setupPooContainer];
    [self setupPooButton];
    [self setupCancelButton];
    [self setupLabel];
}

- (void)setupPooContainer {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.clipsToBounds = YES;
    
    [self addSubview:view];

    self.pooContainerHeightConstraint =
    [NSLayoutConstraint addHeightConstraint:0.0f toView:view];
    [NSLayoutConstraint alignToTop:view withPadding:0.0f];
    [NSLayoutConstraint horizontallyCenterView:view];
    
    NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeHeight
     multiplier:1.0f
     constant:0.0f];
    
    [view addConstraint:widthConstraint];

    self.pooContainer = view;
}

- (void)setupPooButton {
    
    static CGFloat const inset = 1.0f;
    
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor colorWithRGBHex:0x292929];
    view.clipsToBounds = YES;
    
    [view setTitle:@"💩" forState:UIControlStateNormal];

    [view
     addTarget:self
     action:@selector(pooButtonTapped)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.pooContainer addSubview:view];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [NSLayoutConstraint expandToSuperview:view withInsets:insets];
    
    self.pooButton = view;
}

- (void)setupCancelButton {
    
}

- (void)setupLabel {
    
}

#pragma mark - Actions

- (void)pooButtonTapped {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Private

- (void)updatePooButton {
    
    static CGFloat const fontPercent = 0.4289099526f;
    
    self.pooButton.layer.cornerRadius = CGRectGetHeight(self.pooButton.frame) / 2.0f;
    
    CGFloat fontSize = CGRectGetHeight(self.pooButton.frame) * fontPercent;
    fontSize = roundf(fontSize);
    
    self.pooButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

#pragma mark - Constraints

- (void)updateConstraints {
    [super updateConstraints];
    [self updatePooContainerConstraints];
}

- (void)updatePooContainerConstraints {
    
    CGFloat height = roundf(CGRectGetHeight(self.frame) * kPTEventRunningPooPercent);
    self.pooContainerHeightConstraint.constant = height;
    
    [self updatePooButton];
}

@end
