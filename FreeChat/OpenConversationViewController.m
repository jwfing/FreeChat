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
#import "ChatViewController.h"
#import "MJRefresh.h"

NSString * kOpenConversationCellIdentifier = @"OpenConversationIdentifier";

@interface OpenConversationViewController () <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *_conversations;
    MJRefreshHeaderView *_refreshHead;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshOpenConversations:(BOOL)dismissRefreshHeaderView {
    AVIMConversationQuery *query = [[ConversationStore sharedInstance].imClient conversationQuery];
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
    _refreshHead = [MJRefreshHeaderView header];
    _refreshHead.scrollView = _conversationTable;
    _refreshHead.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [weakSelf refreshOpenConversations:YES];
    };
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

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _conversations.count) {
        return nil;
    }
    AVIMConversation *targetConversation = _conversations[indexPath.row];
    UITableViewCell *cell = [self.conversationTable dequeueReusableCellWithIdentifier:kOpenConversationCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOpenConversationCellIdentifier];
    }
    [cell.textLabel setText:targetConversation.name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _conversations.count) {
        return;
    }
    AVIMConversation *conv = [_conversations objectAtIndex:[indexPath row]];
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.conversation = conv;
    [self.navigationController pushViewController:chatViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
