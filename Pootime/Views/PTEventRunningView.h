//
//  PTEventRunningView.h
//  Pootime
//
//  Created by Nick Bolton on 4/13/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTEventRunningDelegate <NSObject>

@end

@interface PTEventRunningView : UIView

@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, weak) id <PTEventRunningDelegate> delegate;

@end
