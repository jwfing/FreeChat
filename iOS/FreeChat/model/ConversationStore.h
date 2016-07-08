//
//  ConversationStore.h
//  FreeChat
//
//  Created by Feng Junwen on 2/5/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UINavigationController.h>

#import "AVOSCloudIM/AVOSCloudIM.h"
#import "Constrains.h"


//@protocol IMEventObserver <NSObject>
//
//- (void)newMessageArrived:(Message*)message conversation:(AVIMConversation*)conversation;
//- (void)messageDelivered:(Message*)message conversation:(AVIMConversation*)conversation;
//
//@end

@protocol ConversationOperationDelegate <NSObject>

@optional
-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation;
-(void)kickoffMembers:(NSArray*)client conversation:(AVIMConversation*)conversation;
-(void)mute:(BOOL)on conversation:(AVIMConversation*)conversation;
-(void)changeName:(NSString*)newName conversation:(AVIMConversation*)conversation;
-(void)exitConversation:(AVIMConversation*)conversation;
-(void)switch2NewConversation:(AVIMConversation*)conversation withNav:(UINavigationController*)controller;

@end

@interface ConversationStore : NSObject<ConversationOperationDelegate>

@property (nonatomic) BOOL networkAvailable;

+(instancetype)sharedInstance;

-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation;
-(void)kickoffMembers:(NSArray*)client conversation:(AVIMConversation*)conversation;
-(void)mute:(BOOL)on conversation:(AVIMConversation*)conversation;
-(void)changeName:(NSString*)newName conversation:(AVIMConversation*)conversation;
-(void)exitConversation:(AVIMConversation*)conversation;
-(void)switch2NewConversation:(AVIMConversation*)conversation;

@end
