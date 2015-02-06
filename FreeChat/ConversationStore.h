//
//  ConversationStore.h
//  FreeChat
//
//  Created by Feng Junwen on 2/5/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AVOSCloudIM/AVOSCloudIM.h"
#import "Conversation.h"
#import "Message.h"

typedef int ConversationEvent;
enum : ConversationEvent {
    EventInvited = 0,
    EventMemberAdd = 1 << 0,
    EventMemberRemove = 1 << 1,
    EventKicked = 1 << 2,
};

typedef void (^CommonResultBlock)(BOOL successed);
typedef void (^ArrayResultBlock)(NSArray *objects, NSError *error);

@interface ConversationStore : NSObject

+(instancetype)sharedInstance;

// 打开了某对话
- (void)enterConversation:(Conversation*)conversation callback:(CommonResultBlock)callback;

// 获取最近对话列表
- (NSArray*)recentConversations;

// 获取某个对话的更多消息
- (void)queryMoreMessages:(NSString*)conversationId from:(NSString*)msgId timestamp:(int64_t)ts limit:(int)limit callback:(ArrayResultBlock)callback;

// 新消息到达
- (void)newMessageArrived:(AVIMMessage*)message;

// 对话中新的事件发生
- (void)newConversationEvent:(ConversationEvent)event from:(NSString*)clientId to:(NSArray*)clientIds;

// 获取对话中未读消息数量
- (int)conversationUnreadCount:(NSString*)conversationId;

@end
