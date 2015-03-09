//
//  MainViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "MainViewController.h"
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "ConversationStore.h"
#import "AVOSCloud/AVOSCloud.h"
#import "RecentConversationViewController.h"
#import "ContactsViewController.h"
#import "SettingsViewController.h"
#import "AVUserStore.h"

@interface MainViewController () {
//    AVIMClient *_imClient;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton = YES;
    self.delegate = self;
    self.title = @"最新消息";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem=nil;
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

#pragma UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[RecentConversationViewController class]]) {
        self.title = @"最新消息";
    } else if ([viewController isKindOfClass:[ContactsViewController class]]) {
        self.title = @"联系人";
    } else if ([viewController isKindOfClass:[SettingsViewController class]]) {
        self.title = @"设置";
    }
}
#pragma AVIMClientDelegate
/*!
 当前聊天状态被暂停，常见于网络断开时触发。
 */
- (void)imClientPaused:(AVIMClient *)imClient {
    ConversationStore *store = [ConversationStore sharedInstance];
    store.networkAvailable = NO;
}

/*!
 当前聊天状态开始恢复，常见于网络断开后开始重新连接。
 */
- (void)imClientResuming:(AVIMClient *)imClient {
}
/*!
 当前聊天状态已经恢复，常见于网络断开后重新连接上。
 */
- (void)imClientResumed:(AVIMClient *)imClient {
    ConversationStore *store = [ConversationStore sharedInstance];
    store.networkAvailable = YES;
}

/*!
 接收到新的普通消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    ConversationStore *store = [ConversationStore sharedInstance];
    [store newMessageArrived:message conversation:conversation];
}

/*!
 接收到新的富媒体消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    ConversationStore *store = [ConversationStore sharedInstance];
    [store newMessageArrived:message conversation:conversation];
}

/*!
 消息已投递给对方。
 @param conversation － 所属对话
 @param message - 具体的消息
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message {
    ConversationStore *store = [ConversationStore sharedInstance];
    [store messageDelivered:message conversation:conversation];
}

/*!
 对话中有新成员加入的通知。
 @param conversation － 所属对话
 @param clientIds - 加入的新成员列表
 @param clientId - 邀请者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId {
    if ([clientId compare:[[AVUser currentUser] objectId]] == NSOrderedSame) {
        // A 邀请 B 加入对话，LeanCloud 云端也会给 A 发送成员增加通知。这时候 clientId 等于 A 的 userId。
    }

    ConversationStore *store = [ConversationStore sharedInstance];
    [store newConversationEvent:EventMemberAdd conversation:conversation from:clientId to:clientIds];
}

/*!
 对话中有成员离开的通知。
 @param conversation － 所属对话
 @param clientIds - 离开的成员列表
 @param clientId - 操作者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation membersRemoved:(NSArray *)clientIds byClientId:(NSString *)clientId {
    if ([clientId compare:[[AVUser currentUser] objectId]] == NSOrderedSame) {
        // A 将 B 踢出对话，LeanCloud 云端也会给 A 发送通知。这时候 clientId 等于 A 的 userId。
    }

    ConversationStore *store = [ConversationStore sharedInstance];
    [store newConversationEvent:EventMemberRemove conversation:conversation from:clientId to:clientIds];
}

/*!
 被邀请加入对话的通知。
 @param conversation － 所属对话
 @param clientId - 邀请者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation invitedByClientId:(NSString *)clientId {
    if ([clientId compare:[[AVUser currentUser] objectId]] == NSOrderedSame) {
        // A 邀请 B 加入对话，LeanCloud 云端也会给 A 发送邀请通知。这时候 clientId 等于 A 的 userId。
        // 这种消息无需处理。
        return;
    }
    ConversationStore *store = [ConversationStore sharedInstance];
    [store newConversationEvent:EventInvited conversation:conversation from:clientId to:nil];
}

/*!
 从对话中被移除的通知。
 @param conversation － 所属对话
 @param clientId - 操作者的 id
 @return None.
 */
- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId {
    ConversationStore *store = [ConversationStore sharedInstance];
    [store newConversationEvent:EventKicked conversation:conversation from:clientId to:nil];
}

@end
