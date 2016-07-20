//
//  UserProfile.h
//  FreeChat
//
//  Created by Feng Junwen on 2/11/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constrains.h"
#import <ChatKit/LCChatKit.h>

@interface UserProfile : NSObject<NSCopying, LCCKUserDelegate>

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatarUrlStr;

@property (nonatomic, copy, readonly) NSString *userId;

/*!
 * @brief The user's name
 */
@property (nonatomic, copy, readonly) NSString *name;

/*!
 * @brief User's avator URL
 */
@property (nonatomic, copy, readonly) NSURL *avatorURL;

@property (nonatomic, copy, readwrite) NSString *clientId;

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId;
+ (instancetype)userWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId;

@end

@protocol UserProfileProvider <NSObject>

- (void)fetchInfos:(NSArray*)userIds callback:(ArrayResultBlock)block;

@end