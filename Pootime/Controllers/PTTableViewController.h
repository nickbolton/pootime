//
//  PTTableViewController.h
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTBaseViewController.h"

@interface PTTableViewController : PTBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) UIEdgeInsets tableViewConstraintInsets;
@property (nonatomic, readonly) UIView *tableViewContainer;
@property (nonatomic, readonly) NSLayoutConstraint *tableViewTopSpace;
@property (nonatomic, readonly) NSLayoutConstraint *tableViewBottomSpace;
@property (nonatomic, readonly) NSLayoutConstraint *tableViewLeftSpace;
@property (nonatomic, readonly) NSLayoutConstraint *tableViewRightSpace;
@property (nonatomic, readonly) UIEdgeInsets tableViewContentInsets;
@property (nonatomic) UIEdgeInsets cellLayoutMargins;
@property (nonatomic) BOOL needsReloadOnWillAppear;
@property (nonatomic) NSUInteger dataSourceIndex;
@property (nonatomic, readonly) BOOL didReloadOnLoad;

- (void)setupTableView;

- (void)reloadData:(BOOL)animate;
- (NSArray *)buildDataSource;
- (NSArray *)dataSourceArrayAtSection:(NSInteger)section;
- (id)dataSourceItemAtIndexPath:(NSIndexPath *)indexPath;
- (id)dataSourceItemForCell:(UITableViewCell *)cell;
- (void)reloadDataSource;

@end
