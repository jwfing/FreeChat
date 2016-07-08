//
//  ConversationStore.m
//  FreeChat
//
//  Created by Feng Junwen on 2/5/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ConversationStore.h"
//#import "RemoteMessagePersisiter.h"
#import "AVUserStore.h"

#define kDecodeKey_Conversations                  @"conversations"
#define kDecodeKey_Conversation_UnreadMapping     @"conversation_msg_mapping"

@interface ConversationStore() {
    NSMutableOrderedSet *_conversations;
    NSMutableDictionary *_conversationUnreadMsgMapping;
    NSMutableDictionary *_observerMapping;
}

@end

@implementation ConversationStore

@synthesize networkAvailable;

- (id)init {
    self = [super init];
    if (self) {
        _conversations = [[NSMutableOrderedSet alloc] initWithCapacity:100];
        _conversationUnreadMsgMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
        _observerMapping = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static ConversationStore *store = nil;
    if (nil == store) {
        store = [[ConversationStore alloc] init];
    }
    return store;
}

- (void)openConversation:(AVIMConversation*)conversation {
    [self changeConversationToHead:conversation];
    // clear unread msg count
    [_conversationUnreadMsgMapping setObject:[NSNumber numberWithInt:0] forKey:conversation.conversationId];
}

- (void)quitConversation:(AVIMConversation *)conversation {
    [_conversations removeObject:conversation];
    [_conversationUnreadMsgMapping setObject:[NSNumber numberWithInt:0] forKey:conversation.conversationId];
}

- (void)changeConversationToHead:(AVIMConversation*)conversation {
    if (!conversation) {
        return;
    }
    [_conversations removeObject:conversation];
    [_conversations insertObject:conversation atIndex:0];
}

- (NSArray*)recentConversations {
    int count = [_conversations count];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [result addObject:[_conversations objectAtIndex:i]];
    }
    return result;
}

//-(void)fillWithUserInfo:(NSArray*)messages invokeCallback:(ArrayResultBlock)block error:(NSError*)error {
//    NSMutableArray *userClients = [[NSMutableArray alloc] init];
//    NSMutableSet *userSet = [[NSMutableSet alloc] init];
//    for (int i = 0; i < messages.count; i++) {
//        Message *msg = messages[i];
//        if (msg.clients) {
//            for (NSString *tmp in msg.clients) {
//                if (![userSet member:tmp]) {
//                    [userSet addObject:tmp];
//                    [userClients addObject:tmp];
//                }
//            }
//        }
//        if (msg.byClient && ![userSet member:msg.byClient]) {
//            [userSet addObject:msg.byClient];
//            [userClients addObject:msg.byClient];
//        }
//    }
//    AVUserStore *userStore = [AVUserStore sharedInstance];
//    [userStore fetchInfos:userClients callback:^(NSArray *objects, NSError *error) {
//        if (block) {
//            block(messages, error);
//        }
//    }];
//};
//
//- (void)queryMoreMessages:(AVIMConversation*)conversation from:(NSString*)msgId timestamp:(int64_t)ts limit:(int)limit callback:(ArrayResultBlock)callback {
//    [[RemoteMessagePersisiter sharedInstance] pullMessagesForConversation:conversation preceded:msgId timestamp:ts limit:limit callback:^(NSArray *objects, NSError *error) {
//        [self fillWithUserInfo:objects invokeCallback:callback error:error];
//    }];
//}
//
//- (void)newMessageSent:(AVIMMessage *)message conversation:(AVIMConversation *)conv {
//    Message *newMessage = [[Message alloc] init];
//    newMessage.imMessage = message;
//    newMessage.eventType = CommonMessage;
//    newMessage.convId =[conv conversationId];
//    newMessage.clients = nil;
//    newMessage.byClient = [message clientId];
//    newMessage.sentTimestamp = message.sendTimestamp;
//}
//
//- (void)newMessageArrived:(AVIMMessage*)message conversation:(AVIMConversation*)conv {
//    Message *newMessage = [[Message alloc] init];
//    newMessage.imMessage = message;
//    newMessage.eventType = CommonMessage;
//    newMessage.convId =[conv conversationId];
//    newMessage.clients = nil;
//    newMessage.byClient = [message clientId];
//    newMessage.sentTimestamp = message.sendTimestamp;
//    [self fireNewMessage:newMessage conversation:conv];
//}
//
//- (void)messageDelivered:(AVIMMessage*)message conversation:(AVIMConversation*)conv {
//    // 无需特别处理
//}
//
//// 对话中新的事件发生
//- (void)newConversationEvent:(IMMessageType)event conversation:(AVIMConversation*)conv from:(NSString*)clientId to:(NSArray*)clientIds {
//    Message *newMessage = [[Message alloc] init];
//    newMessage.eventType = event;
//    newMessage.imMessage = nil;
//    newMessage.convId = [conv conversationId];
//    newMessage.clients = clientIds;
//    newMessage.byClient = clientId;
//    newMessage.sentTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
//    switch (event) {
//        case EventInvited:
//            break;
//        case EventKicked:
//            break;
//        case EventMemberAdd:
//            break;
//        case EventMemberRemove:
//            break;
//        default:
//            return;
//    }
//    [self fireNewMessage:newMessage conversation:conv];
//}
//
//- (void)fireNewMessage:(Message*)message conversation:(AVIMConversation*)conv{
//    NSMutableArray *userClients = [[NSMutableArray alloc] initWithObjects:message.byClient, nil];
//    if (message.clients) {
//        [userClients addObjectsFromArray:message.clients];
//    }
//    [[AVUserStore sharedInstance] fetchInfos:userClients callback:^(NSArray *objects, NSError *error) {
//        [self changeConversationToHead:conv];
//        NSNumber *unreadCount = [_conversationUnreadMsgMapping objectForKey:conv.conversationId];
//        if (unreadCount) {
//            unreadCount = [NSNumber numberWithInt:(unreadCount.intValue + 1)];
//        } else {
//            unreadCount = [NSNumber numberWithInt:1];
//        }
//        [_conversationUnreadMsgMapping setObject:unreadCount forKey:conv.conversationId];
//        
//        NSMutableArray *observerChain = [_observerMapping objectForKey:@"*"];
//        if (observerChain) {
//            for (int i = 0; i < [observerChain count]; i++) {
//                id<IMEventObserver> observer = [observerChain objectAtIndex:i];
//                [observer newMessageArrived:message conversation:conv];
//            }
//        }
//        observerChain = [_observerMapping objectForKey:[conv conversationId]];
//        if (observerChain) {
//            for (int i = 0; i < [observerChain count]; i++) {
//                id<IMEventObserver> observer = [observerChain objectAtIndex:i];
//                [observer newMessageArrived:message conversation:conv];
//            }
//        }
//    }];
//}

- (int)conversationUnreadCount:(NSString*)conversationId {
    NSNumber *count = [_conversationUnreadMsgMapping objectForKey:conversationId];
    if (count) {
        return count.intValue;
    }
    return 0;
}

//- (void)addEventObserver:(id<IMEventObserver>)observer forConversation:(NSString*)conversationId {
//    NSMutableArray *observerChain = [_observerMapping objectForKey:conversationId];
//    if (observerChain == nil) {
//        observerChain = [[NSMutableArray alloc] initWithObjects:observer, nil];
//    } else {
//        [observerChain addObject:observer];
//    }
//    [_observerMapping setObject:observerChain forKey:conversationId];
//}
//
//- (void)removeEventObserver:(id<IMEventObserver>)observer forConversation:(NSString*)conversationId {
//    NSMutableArray *observerChain = [_observerMapping objectForKey:conversationId];
//    if (observerChain != nil) {
//        [observerChain removeObject:observer];
//        [_observerMapping setObject:observerChain forKey:conversationId];
//    }
//}


@end
