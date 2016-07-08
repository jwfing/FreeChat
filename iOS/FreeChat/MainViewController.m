//
//  MainViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "MainViewController.h"
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "ConversationStore.h"
#import "AVOSCloud/AVOSCloud.h"
#import "ContactsViewController.h"
#import "SettingsViewController.h"
#import "OpenConversationViewController.h"
#import "AVUserStore.h"
#import <ChatKit/LCCKConversationViewController.h>

@interface MainViewController () {
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton = YES;
    self.delegate = self;
    self.title = @"最新消息";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[LCCKConversationListViewController class]]) {
        self.title = @"最新消息";
    } else if ([viewController isKindOfClass:[ContactsViewController class]]) {
        self.title = @"联系人";
    } else if ([viewController isKindOfClass:[SettingsViewController class]]) {
        self.title = @"设置";
    } else if ([viewController isKindOfClass:[OpenConversationViewController class]]) {
        self.title = @"部落";
    }
}

@end
