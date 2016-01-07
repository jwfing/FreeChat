//
//  ConversationDetailViewController.h
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVOSCloud.h"
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "ConversationStore.h"

@interface ConversationDetailViewController : UIViewController

@property (nonatomic, strong) AVIMConversation *conversation;
@property (nonatomic, weak) id<ConversationOperationDelegate> delegate;

@end
