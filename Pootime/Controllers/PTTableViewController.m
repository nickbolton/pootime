//
//  PTTableViewController.m
//  Pootime
//
//  Created by Nick Bolton on 03/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTTableViewController.h"
#import "Bedrock.h"

@interface PTTableViewController()

@property (nonatomic, readwrite) NSLayoutConstraint *tableViewTopSpace;
@property (nonatomic, readwrite) NSLayoutConstraint *tableViewBottomSpace;
@property (nonatomic, readwrite) NSLayoutConstraint *tableViewLeftSpace;
@property (nonatomic, readwrite) NSLayoutConstraint *tableViewRightSpace;
@property (nonatomic, readwrite) UIView *tableViewContainer;
@property (nonatomic, readwrite) BOOL didReloadOnLoad;

@end

@implementation PTTableViewController

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        self.tableViewConstraintInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupTableViewContainer {
    
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:view];
    
    [NSLayoutConstraint expandToSuperview:view];

    self.tableViewContainer = view;
}

- (void)setupTableView {
    
    UITableView *tableView = [UITableView new];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;

    [self.tableViewContainer addSubview:tableView];
    
    tableView.contentInset = self.tableViewContentInsets;
    
    self.tableViewTopSpace =
    [NSLayoutConstraint
     alignToTop:tableView
     withPadding:self.tableViewConstraintInsets.top];

    self.tableViewBottomSpace =
    [NSLayoutConstraint
     alignToBottom:tableView
     withPadding:-self.tableViewConstraintInsets.bottom];

    self.tableViewLeftSpace =
    [NSLayoutConstraint
     alignToLeft:tableView
     withPadding:self.tableViewConstraintInsets.left];
    
    self.tableViewRightSpace =
    [NSLayoutConstraint
     alignToRight:tableView
     withPadding:-self.tableViewConstraintInsets.right];
    
    self.tableView = tableView;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [self setupTableViewContainer];
    [super viewDidLoad];
    [self setupTableView];
    
    if (self.tabBarController.selectedViewController == self) {
        [self reloadData];
        self.didReloadOnLoad = YES;
    } else {
        self.needsReloadOnWillAppear = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.needsReloadOnWillAppear ||
        (self.didReloadOnLoad == NO && self.tabBarController.selectedViewController == self)) {
        self.needsReloadOnWillAppear = NO;
        [self reloadData];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
        
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Data Source

- (void)reloadData {
    [self reloadDataSource];
    [self.tableView reloadData];
}

- (void)reloadData:(BOOL)animate {
    
    NSTimeInterval duration = animate ? .3f : 0.0f;
    
    [UIView
     transitionWithView:self.tableView
     duration:duration
     options:UIViewAnimationOptionTransitionCrossDissolve
     animations:^{
         [self reloadData];
     } completion:nil];
}

- (void)reloadDataSource {
    self.dataSource = [self buildDataSource];
}

- (NSArray *)buildDataSource {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSArray *)dataSourceArrayAtSection:(NSInteger)section {
    
    NSArray *result = nil;
    
    if (section == 0) {
        
        if (self.dataSource.count > 0) {
            
            result = self.dataSource[0];
            if ([result isKindOfClass:[NSArray class]] == NO) {
                result = self.dataSource;
            }
        }
        
    } else if (section < self.dataSource.count) {
        
        result = self.dataSource[section];
        if ([result isKindOfClass:[NSArray class]] == NO) {
            result = nil;
        }
    }
    
    return result;
}

- (id)dataSourceItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath != nil) {
        
        NSArray *sectionArray = [self dataSourceArrayAtSection:indexPath.section];
        
        if (indexPath.row < sectionArray.count) {
            return sectionArray[indexPath.row];
        }
    }
    return nil;
}

- (id)dataSourceItemForCell:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return [self dataSourceItemAtIndexPath:indexPath];
}

#pragma mark - Getters and Setters

- (void)setTableViewConstraintInsets:(UIEdgeInsets)tableViewConstraintInsets {
    _tableViewConstraintInsets = tableViewConstraintInsets;
    [self updateTableViewConstraints];
}

- (UIEdgeInsets)tableViewContentInsets {
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark - Private

- (void)updateTableViewConstraints {
    
    self.tableViewTopSpace.constant = self.tableViewConstraintInsets.top;
    self.tableViewBottomSpace.constant = -self.tableViewConstraintInsets.bottom;
    self.tableViewLeftSpace.constant = self.tableViewConstraintInsets.left;
    self.tableViewRightSpace.constant = -self.tableViewConstraintInsets.right;
    [self.tableView layoutIfNeeded];
}

#pragma mark - UITableViewDataSource Conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:self.cellLayoutMargins];
    }
}

#pragma mark - Header/Footer Nonsense

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
