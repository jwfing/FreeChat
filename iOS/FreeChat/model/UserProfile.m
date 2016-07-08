//
//  UserProfile.m
//  FreeChat
//
//  Created by Feng Junwen on 2/11/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "UserProfile.h"
#import <ChatKit/LCChatKit.h>

@interface UserProfile  (LCCKUserModelDelegate)

@property (nonatomic, copy, readonly) NSString *userId;

/*!
 * @brief The user's name
 */
@property (nonatomic, copy, readonly) NSString *name;

/*!
 * @brief User's avator URL
 */
@property (nonatomic, copy, readonly) NSURL *avatorURL;

@end

@implementation UserProfile

@synthesize objectId, nickname, avatarUrlStr;

-(NSString*)userId {
    return objectId;
}

-(NSString*)name {
    return nickname;
}

-(NSURL*)avatorURL {
    if (avatarUrlStr) {
        return [[NSURL alloc] initWithString:avatarUrlStr];
    } else {
        return [[NSURL alloc] initWithString:@"http://tva3.sinaimg.cn/crop.110.143.933.933.180/d9b8b8fcjw8ez8a62jkeuj20xc0xc3yw.jpg"];
    }
}

@end
