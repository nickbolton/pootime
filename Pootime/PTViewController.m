//
//  PTViewController.m
//  Pootime
//
//  Created by Nick Bolton on 3/31/15.
//  Copyright (c) 2015 Pixelbleed. All rights reserved.
//

#import "PTViewController.h"
#import "Bedrock.h"
#import <EventKit/EventKit.h>
#import "PTDefaultsManager.h"
#import "MMWormhole.h"

static NSString * const kPTCalendarCellID = @"cell-id";

@interface PTViewController ()

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic) BOOL granted;
@property (nonatomic, strong) MMWormhole *wormhole;

@end

@implementation PTViewController

#pragma mark - Setup

- (void)setupTableView {
    [super setupTableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(50.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.rowHeight = 50.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView
     registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPTCalendarCellID];
    
    [self.tableView
     registerClass:[UITableViewHeaderFooterView class]
     forHeaderFooterViewReuseIdentifier:@"header"];
}

- (void)setupEventStore {
    
    self.eventStore = [[EKEventStore alloc] init];
        
    __weak typeof(self) this = self;
    
    [self.eventStore
     requestAccessToEntityType:EKEntityTypeEvent
     completion:^(BOOL granted, NSError *error) {
         
         this.granted = granted;
     }];
}

- (void)setupWormhole {
    
    // Initialize the wormhole
    self.wormhole =
    [[MMWormhole alloc]
     initWithApplicationGroupIdentifier:@"group.com.pixelbleed.pootime"
     optionalDirectory:@"wormhole"];
    
    // Obtain an initial message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"pootime"];
    NSDate *pootime = messageObject;

    NSLog(@"pootime: %@", pootime);
    
    // Become a listener for changes to the wormhole for the button message
    [self.wormhole listenForMessageWithIdentifier:@"pootime" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSDate *pootime = messageObject;
        NSLog(@"pootime: %@", pootime);
        
        [UIAlertView
         presentOKAlertWithTitle:[NSString stringWithFormat:@"pOOO Time: %@", pootime]
         andMessage:nil];
    }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupEventStore];
    [self setupWormhole];
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [super applicationWillEnterForeground:notification];
    [self reloadData:NO];
}

#pragma mark - DataSource

- (NSArray *)buildDataSource {
    
    NSArray *allCalendars =
    [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    NSPredicate *predicate =
    [NSPredicate
     predicateWithFormat:@"type != %d", EKCalendarTypeBirthday];
    
    NSArray *filteredCalendars =
    [allCalendars filteredArrayUsingPredicate:predicate];
    
    NSMutableDictionary *buckets = [NSMutableDictionary dictionary];
    
    for (EKCalendar *calendar in filteredCalendars) {
        
        NSMutableArray *calendars = buckets[calendar.source.sourceIdentifier];
        
        if (calendars == nil) {
            calendars = [NSMutableArray array];
            buckets[calendar.source.sourceIdentifier] = calendars;
        }
        
        [calendars addObject:calendar];
    }
    
    NSSortDescriptor *sorter =
    [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];

    NSArray *sources = buckets.allKeys;
    sources = [sources sortedArrayUsingDescriptors:@[sorter]];
    
    NSMutableArray *sections = [NSMutableArray array];

    for (NSString *sourceID in sources) {
        
        NSArray *calendars = buckets[sourceID];
        calendars = [calendars sortedArrayUsingDescriptors:@[sorter]];
        
        [sections addObject:calendars];
    }
    
    return sections;
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPTCalendarCellID];

    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    cell.textLabel.text = calendar.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:21.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([calendar.calendarIdentifier isEqualToString:[PTDefaultsManager sharedInstance].selectedCalendarID]) {
        cell.backgroundColor = [[UIColor brownColor] colorWithAlpha:.7f];
        cell.contentView.backgroundColor = [[UIColor brownColor] colorWithAlpha:.7f];
    } else {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sectionArray = [self dataSourceArrayAtSection:section];
    return sectionArray.count;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *sectionArray = [self dataSourceArrayAtSection:section];
    EKCalendar *calendar = sectionArray.firstObject;
    return calendar.source.title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EKCalendar *calendar = [self dataSourceItemAtIndexPath:indexPath];
    
    if (calendar != nil) {
        [PTDefaultsManager sharedInstance].selectedCalendarID = calendar.calendarIdentifier;
        [self.wormhole passMessageObject:calendar.calendarIdentifier identifier:@"calendarIdentifier"];
        [self.tableView reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UITableViewHeaderFooterView *header =
    [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    header.contentView.backgroundColor = [UIColor blackColor];
    header.textLabel.textColor = [UIColor whiteColor];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
}

@end
