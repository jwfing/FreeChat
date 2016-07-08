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

#import "ConversationDetailViewController.h"

#import <ChatKit/LCChatKit.h>
#import <ChatKit/LCCKConversationViewController.h>

#define kDecodeKey_Conversations                  @"conversations"
#define kDecodeKey_Conversation_UnreadMapping     @"conversation_msg_mapping"

@interface ConversationStore() {
}

@end

@implementation ConversationStore

@synthesize networkAvailable;

- (id)init {
    self = [super init];
    if (self) {
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

-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation {
    [conversation addMembersWithClientIds:clients callback:^(BOOL succeeded, NSError *error) {
        NSLog(@"addMembers conversation result:%hhd", succeeded);
    }];
}

-(void)kickoffMembers:(NSArray*)client conversation:(AVIMConversation*)conversation {
    [conversation removeMembersWithClientIds:client callback:^(BOOL succeeded, NSError *error) {
        NSLog(@"removeMembers conversation:%@ result:%hhd", conversation.conversationId, succeeded);
    }];
}

-(void)mute:(BOOL)on conversation:(AVIMConversation*)conversation {
    if (on) {
        [conversation muteWithCallback:^(BOOL succeeded, NSError *error) {
            NSLog(@"mute conversation:%@ result:%hhd", conversation.conversationId, succeeded);
        }];
    } else {
        [conversation unmuteWithCallback:^(BOOL succeeded, NSError *error) {
            NSLog(@"unmute conversation:%@ result:%hhd", conversation.conversationId, succeeded);
        }];
    }
}

-(void)changeName:(NSString*)newName conversation:(AVIMConversation*)conversation {
    AVIMConversationUpdateBuilder *cub = [conversation newUpdateBuilder];
    [cub setName:newName];
    [conversation update:cub.dictionary callback:^(BOOL succeeded, NSError *error) {
        NSLog(@"change conversation:%@  name:%@ result:%hhd", conversation.conversationId,
              newName, succeeded);
    }];
}

-(void)exitConversation:(AVIMConversation*)conversation {
    [conversation quitWithCallback:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@ exit conversation:%@ result:%hhd",
              [LCChatKit sharedInstance].clientId, conversation.conversationId, succeeded);
    }];
}

-(void)switch2NewConversation:(AVIMConversation*)conversation withNav:(UINavigationController*)controller {
    LCCKConversationViewController *conversationVC = [[LCCKConversationViewController alloc]
                                                      initWithConversationId:conversation.conversationId];
    [conversationVC setConversationHandler:^(AVIMConversation *conversation, LCCKConversationViewController *conversationController) {
        ConversationDetailViewController *detailVC = [[ConversationDetailViewController alloc] init];
        detailVC.conversation = conversation;
        detailVC.delegate = [ConversationStore sharedInstance];
        [conversationController.navigationController pushViewController:detailVC animated:YES];
    }];
    [controller pushViewController:conversationVC animated:YES];
}

@end
