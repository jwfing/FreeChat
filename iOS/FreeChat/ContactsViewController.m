//
//  SecondViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ContactsViewController.h"
#import "AVOSCloud/AVOSCloud.h"
#import "ConversationStore.h"
#import "MessageDisplayer.h"
#import "Constrains.h"
#import "ConversationListViewController.h"
#import "ConversationDetailViewController.h"
#import "MJRefresh/MJRefresh.h"
#import <ChatKit/LCChatKit.h>

NSString * kContactCellIdentifier = @"ContactIdentifier";

@interface ContactsViewController () {
    UITableView *_tableView;
    NSMutableArray *_allUsers;
    NSMutableArray *_pickedUsers;
    MJRefreshFooter *_refreshFooter;
}

@property (nonatomic, strong)NSMutableArray *allUsers;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)MJRefreshFooter *refreshFooter;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGSize frameSize = self.view.frame.size;
    CGSize navSize = self.navigationController.navigationBar.frame.size;

    if (self.action != ActionNone) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height) style:UITableViewStylePlain];
        _tableView.allowsMultipleSelection = YES;
    } else {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navSize.height + 24, frameSize.width, frameSize.height - navSize.height - 49) style:UITableViewStylePlain];
        _tableView.allowsMultipleSelection = NO;
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kContactCellIdentifier];
    [self.view addSubview:_tableView];
    
    _allUsers = [[NSMutableArray alloc] initWithCapacity:100];
    _pickedUsers = [[NSMutableArray alloc] initWithCapacity:100];
    if (self.specificUsers) {
        _allUsers = [NSMutableArray arrayWithArray:self.specificUsers];
    } else {
        AVQuery *query = [AVUser query];
        [query addAscendingOrder:@"username"];
        [query whereKey:@"objectId" notEqualTo:[AVUser currentUser].objectId];
        query.limit = 100;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [_allUsers addObjectsFromArray:objects];
            [_tableView reloadData];
        }];
        _refreshFooter = [MJRefreshFooter footerWithRefreshingBlock:^{
            AVQuery *query = [AVUser query];
            [query addAscendingOrder:@"username"];
            [query whereKey:@"objectId" notEqualTo:[AVUser currentUser].objectId];
            query.limit = 100;
            query.skip = [self.allUsers count];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [self.allUsers addObjectsFromArray:objects];
                [self.tableView reloadData];
                [self.refreshFooter endRefreshing];
            }];
            
        }];
//        _refreshFooter.scrollView = _tableView;
//        __weak typeof(self) ws = self;
//        _refreshFooter.refreshingBlock = ^(MJRefreshBaseView *refreshView) {
//            AVQuery *query = [AVUser query];
//            [query addAscendingOrder:@"username"];
//            [query whereKey:@"objectId" notEqualTo:[AVUser currentUser].objectId];
//            query.limit = 100;
//            query.skip = [ws.allUsers count];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                [ws.allUsers addObjectsFromArray:objects];
//                [ws.tableView reloadData];
//                [ws.refreshFooter endRefreshing];
//            }];
//        };
    }
    if (self.action != ActionNone) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(pressedButtonOK:)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    [_refreshFooter free];
}

-(void)pressedButtonOK:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.action != ActionNone && [_pickedUsers count] > 0) {
        NSMutableArray *clients = [[NSMutableArray alloc] initWithCapacity:[_pickedUsers count]];
        for (int i = 0; i < [_pickedUsers count]; i++) {
            [clients addObject:((AVUser*)_pickedUsers[i]).objectId];
        }
        if (self.action == AddNewMembers && [self.delegate respondsToSelector:@selector(addMembers:conversation:)]) {
            [self.delegate addMembers:clients conversation:nil];
        } else if (self.action == KickoffMembers && [self.delegate respondsToSelector:@selector(kickoffMembers:conversation:)]){
            [self.delegate kickoffMembers:clients conversation:nil];
        }
    }
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (ActionNone == self.action) {
        if (0 == section) {
            return 1;
        } else {
            return [_allUsers count];
        }
    }
    return [_allUsers count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (ActionNone == self.action && indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactCellIdentifier];
        }
        [cell.textLabel setText:@"群聊"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    if ([indexPath row] >= [_allUsers count]) {
        return nil;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactCellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    AVUser *user = [_allUsers objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[user username]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (ActionNone == self.action) {
        return 2;
    } else {
        return 1;
    }
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (ActionNone == self.action && indexPath.section == 0) {
        ConversationListViewController *conversationLV = [[ConversationListViewController alloc] init];
        [self.navigationController pushViewController:conversationLV animated:YES];
        return;
    }
    if ([indexPath row] >= [_allUsers count]) {
        return;
    }
    if (self.action != ActionNone) {
        AVUser *targetUser = [_allUsers objectAtIndex:[indexPath row]];
        [_pickedUsers removeObject:targetUser];
        [_pickedUsers addObject:targetUser];
        return;
    }
    AVUser *peerUser = [_allUsers objectAtIndex:[indexPath row]];
    LCCKConversationViewController *conversationVC = [[LCCKConversationViewController alloc] initWithPeerId:peerUser.objectId];
    [conversationVC setConversationHandler:^(AVIMConversation *conversation, LCCKConversationViewController *conversationController) {
        ConversationDetailViewController *detailVC = [[ConversationDetailViewController alloc] init];
        detailVC.conversation = conversation;
        detailVC.delegate = [ConversationStore sharedInstance];
        [conversationController.navigationController pushViewController:detailVC animated:YES];
    }];
    [self.navigationController pushViewController:conversationVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.action != ActionNone) {
        AVUser *targetUser = [_allUsers objectAtIndex:[indexPath row]];
        [_pickedUsers removeObject:targetUser];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (ActionNone == self.action) {
        if (0 == section) {
            return 0.0f;
        } else {
            return 30.0f;
        }
    } else {
        return 0.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (ActionNone != self.action) {
        return nil;
    }
    if (0 == section) {
        return nil;
    }
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [headerLabel setText:@" 用户列表"];
    [headerLabel setBackgroundColor:[UIColor lightGrayColor]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [headerLabel setTextAlignment:NSTextAlignmentLeft];
    return headerLabel;
}

@end
