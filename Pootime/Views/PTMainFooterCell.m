//
//  PTMainFooterCell.m
//  Pootime
//
//  Created by Nick Bolton on 4/12/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTMainFooterCell.h"
#import "UIView+Utilities.h"
#import "Bedrock.h"

@implementation PTMainFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

#pragma mark - Setup

- (void)setupCell {
    
    static CGFloat const fontSize = 15.0f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [self setTintColor:[UIColor whiteColor]];
    
    self.textLabel.text = PBLoc(@"Select Calendar");
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:fontSize];
    
    self.detailTextLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint expandHeightToSuperview:self.detailTextLabel];
    [NSLayoutConstraint alignToRight:self.detailTextLabel withPadding:2.0f];
}

#pragma mark - Getters and Setters

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setViewPressed:highlighted animated:YES];
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
