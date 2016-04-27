//
//  SecondViewController.h
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "ConversationStore.h"

typedef int ConversationActionType;
enum : ConversationActionType {
    ActionNone = 0,
    AddNewMembers = 1 << 0,
    KickoffMembers = 1 << 1,
};

@interface ContactsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) ConversationActionType action;
@property (nonatomic, strong) NSArray *specificUsers;
@property (nonatomic, weak) id<ConversationOperationDelegate> delegate;

@end

