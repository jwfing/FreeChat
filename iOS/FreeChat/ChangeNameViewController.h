//
//  ChangeNameViewController.h
//  FreeChat
//
//  Created by Feng Junwen on 3/6/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationStore.h"

@interface ChangeNameViewController : UIViewController

@property (nonatomic, weak) id<ConversationOperationDelegate> delegate;
@property (nonatomic, copy) NSString *oldName;

@end
