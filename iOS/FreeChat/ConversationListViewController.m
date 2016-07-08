//
//  ConversationListViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 3/6/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ConversationListViewController.h"
#import "ConversationStore.h"
#import "ConversationUtils.h"
#import "ContactsViewController.h"
#import "MessageDisplayer.h"
#import <ChatKit/LCCKConversationViewController.h>
#import <ChatKit/LCChatKit.h>

#define kConversationCellIdentifier @"ConversationCellIdentifier"

@interface ConversationListViewController () <UITableViewDataSource, UITableViewDelegate, ConversationOperationDelegate> {
    UITableView *_tableView;
    NSMutableArray *_conversations;
}

@end

@implementation ConversationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我参加的群聊";
    CGSize frameSize = self.view.frame.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kConversationCellIdentifier];
    [self.view addSubview:_tableView];

    AVIMConversationQuery *query = [[LCChatKit sharedInstance].client conversationQuery];
    [query whereKey:kAVIMKeyMember containedIn:@[[AVUser currentUser].objectId]];
    [query whereKey:AVIMAttr(@"type") equalTo:[NSNumber numberWithInt:kConversationType_Group]];
    [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
        _conversations = [NSMutableArray arrayWithArray:objects];
        [_tableView reloadData];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStylePlain target:self action:@selector(pressedButtonCreate:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)pressedButtonCreate:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContactsViewController *contactsController = [storyboard instantiateViewControllerWithIdentifier:@"ContactsViewIdentifier"];
    contactsController.action = AddNewMembers;
    contactsController.delegate = self;
    [self.navigationController pushViewController:contactsController animated:YES];
}

#pragma ConversationOperationDelegate
-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation {
    if (clients.count < 1) {
        return;
    }
    NSString *currentUserId = [[AVUser currentUser] objectId];
    NSMutableArray *convMembers = [NSMutableArray arrayWithArray:clients];
    if (![clients containsObject:currentUserId]) {
        [convMembers addObject:currentUserId];
    }
    AVIMClient *imClient = [LCChatKit sharedInstance].client;
    [imClient createConversationWithName:nil
                               clientIds:convMembers
                              attributes:@{@"type":[NSNumber numberWithInt:kConversationType_Group]}
                                 options:AVIMConversationOptionNone
                                callback:^(AVIMConversation *conversation, NSError *error) {
                                    if (error) {
                                        [MessageDisplayer displayError:error];
                                    } else {
                                        [_conversations insertObject:conversation atIndex:0];
                                        [_tableView reloadData];
                                    }
                                }];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_conversations count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [_conversations count]) {
        return nil;
    }
    AVIMConversation *conv = [_conversations objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kConversationCellIdentifier
                                                             forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kConversationCellIdentifier];
    }
    NSArray *members = conv.members;
    if ([conv.name length] > 0) {
        [cell.textLabel setText:conv.name];
    } else {
        NSString *displayName = [ConversationUtils getConversationDisplayname:conv];
        if (members.count < 3) {
            [cell.textLabel setText:displayName];
        } else {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ 等%d人", displayName, members.count]];
        }
        
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AVIMConversation *conv = [_conversations objectAtIndex:[indexPath row]];
    LCCKConversationViewController *conversationVC = [[LCCKConversationViewController alloc] initWithConversationId:conv.conversationId];
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
