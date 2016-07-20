//
//  UserProfile.m
//  FreeChat
//
//  Created by Feng Junwen on 2/11/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "UserProfile.h"
#import <ChatKit/LCChatKit.h>

@implementation UserProfile

@synthesize objectId, nickname, avatarUrlStr;
@synthesize clientId = _objectId;

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

- (id)copyWithZone:(nullable NSZone *)zone {
    UserProfile *profile = [[UserProfile allocWithZone:zone] init];
    profile.objectId = self.objectId;
    profile.nickname = self.nickname;
    profile.avatarUrlStr = self.avatarUrlStr;
    return profile;
}

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId {
    self.objectId = userId;
    self.nickname = name;
    self.avatarUrlStr = avatarURL.absoluteString;
    return self;
}

+ (instancetype)userWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId {
    UserProfile *profile = [[UserProfile alloc] initWithUserId:userId name:name avatarURL:avatarURL clientId:clientId];
    return profile;
}

@end
