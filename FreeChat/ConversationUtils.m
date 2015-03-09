//
//  ConversationUtils.m
//  FreeChat
//
//  Created by Feng Junwen on 3/6/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ConversationUtils.h"

@implementation ConversationUtils

+(NSString*)getConversationDisplayname:(AVIMConversation*)conversation {
    int memberCount = [conversation.members count];
    AVUser *currentUser = [AVUser currentUser];
    if (memberCount < 1) {
        return conversation.conversationId;
    }
    for (int i = 0; i < memberCount; i++) {
        NSString *tmpUserId = conversation.members[i];
        if ([tmpUserId length] > 0 && [tmpUserId compare:currentUser.objectId] != NSOrderedSame) {
            return tmpUserId;
        }
    }
    return nil;
}

@end
