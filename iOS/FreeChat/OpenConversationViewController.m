//
//  OpenConversationViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 3/26/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "OpenConversationViewController.h"
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "ConversationStore.h"
#import "MJRefresh.h"
#import <ChatKit/LCChatKit.h>
#import <ChatKit/LCCKConversationViewController.h>

NSString *kOpenConversationCellIdentifier = @"OpenConversationIdentifier";
NSString *kConversationStatusFormat = @"%@(在线: %d 人)";

@interface OpenConversationViewController () <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *_conversations;
    NSMutableDictionary *_memberCountDict;
    MJRefreshHeader *_refreshHead;
    NSTimer *_memberCounterTimer;
}

@property (strong) UILabel *comment;
@property (strong) UITableView *conversationTable;

@end

@implementation OpenConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize frameSize = self.view.frame.size;
    CGSize navSize = self.navigationController.navigationBar.frame.size;

    _comment = [[UILabel alloc] initWithFrame:CGRectMake(0, navSize.height + 24, frameSize.width, 30)];
    _comment.textAlignment = NSTextAlignmentLeft;
    [_comment setText:@"开放聊天室，直接点击进入即可"];
    [self.view addSubview:_comment];
    _conversationTable = [[UITableView alloc] initWithFrame:CGRectMake(0, navSize.height + 54, frameSize.width, frameSize.height - navSize.height - 54)];
    _conversationTable.delegate = self;
    _conversationTable.dataSource = self;
    [_conversationTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kOpenConversationCellIdentifier];
    [self.view addSubview:_conversationTable];

    [self addRefreshViews];
    
    [self refreshOpenConversations:NO];
    _memberCountDict = [[NSMutableDictionary alloc] initWithCapacity:10];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _memberCounterTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refreshConversationMembers) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_memberCounterTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshOpenConversations:(BOOL)dismissRefreshHeaderView {
    AVIMConversationQuery *query = [[LCChatKit sharedInstance].client conversationQuery];
    [query whereKey:AVIMAttr(@"type") equalTo:[NSNumber numberWithInt:2]];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        if (error || objects.count < 1) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"开放聊天室不可用！" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        } else {
            _conversations = [NSMutableArray arrayWithArray:objects];
            [self.conversationTable reloadData];
        }
        if (dismissRefreshHeaderView) {
            [_refreshHead endRefreshing];
        }
    }];
}

- (void)addRefreshViews {
    __weak typeof(self) weakSelf = self;
    _refreshHead = [MJRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refreshOpenConversations:YES];
    }];
}

- (void)refreshConversationMembers {
    NSLog(@"begin to refresh conversation member count...");
    dispatch_group_t refreshGroup = dispatch_group_create();
    int total = _conversations.count;
    for (int i = 0; i < total; i++) {
        AVIMConversation *conv = _conversations[i];
        dispatch_group_enter(refreshGroup);
        [conv countMembersWithCallback:^(NSInteger number, NSError *error) {
            if (!error) {
                [_memberCountDict setObject:[NSNumber numberWithInt:number] forKey:conv.name];
            }
            NSLog(@"countMembersWithCallback - %@ count: %d", conv.name, number);
            dispatch_group_leave(refreshGroup);
        }];
    }
    dispatch_group_notify(refreshGroup, dispatch_get_main_queue(), ^{
        NSLog(@"end refresh conversation member count.");
        [_refreshHead endRefreshing];
        [self.conversationTable reloadData];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _conversations.count) {
        return nil;
    }
    AVIMConversation *targetConversation = _conversations[indexPath.row];
    UITableViewCell *cell = [self.conversationTable dequeueReusableCellWithIdentifier:kOpenConversationCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOpenConversationCellIdentifier];
    }
    NSNumber *number = [_memberCountDict objectForKey:targetConversation.name];
    [cell.textLabel setText:[NSString stringWithFormat:kConversationStatusFormat, targetConversation.name, number.intValue]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _conversations.count) {
        return;
    }
    AVIMConversation *conv = [_conversations objectAtIndex:[indexPath row]];
    LCCKConversationViewController *conversationVC = [[LCCKConversationViewController alloc] initWithConversationId:conv.conversationId];
    [self.navigationController pushViewController:conversationVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
