//
//  LoginViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "LoginViewController.h"
#import "AVOSCloud/AVOSCloud.h"
#import "AVOSCloudIM/AVOSCloudIM.h"
#import "MainViewController.h"
#import "ConversationStore.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloudSNS/AVUser+SNS.h>

@interface LoginViewController () {
    UITextField *_username;
    UITextField *_password;
}

@end



@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize frameSize = self.view.frame.size;
    _username = [[UITextField alloc] initWithFrame:CGRectMake(30, 50, frameSize.width - 60, 30)];
    [_username setBorderStyle:UITextBorderStyleRoundedRect];
    [_username setPlaceholder:@"username"];
    _password = [[UITextField alloc] initWithFrame:CGRectMake(30, 90, frameSize.width - 60, 30)];
    [_password setBorderStyle:UITextBorderStyleRoundedRect];
    [_password setPlaceholder:@"password"];
    UIButton *signUp = [[UIButton alloc] initWithFrame:CGRectMake(frameSize.width - 140, 140, 60, 20)];
    UIButton *signIn = [[UIButton alloc] initWithFrame:CGRectMake(frameSize.width - 70, 140, 60, 20)];
    [signUp setTitle:@"注册" forState:UIControlStateNormal];
    [signIn setTitle:@"登录" forState:UIControlStateNormal];
    [signUp setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [signIn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [signUp addTarget:self action:@selector(signupClicked:) forControlEvents:UIControlEventTouchUpInside];
    [signIn addTarget:self action:@selector(signinClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    [self.view addSubview:signUp];
    [self.view addSubview:signIn];

    UIButton *weiboLogin = [[UIButton alloc] initWithFrame:CGRectMake(20, 240, frameSize.width - 40, 40)];
    [weiboLogin setTitle:@"新浪微博登录" forState:UIControlStateNormal];
    [weiboLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [weiboLogin addTarget:self action:@selector(loginWithWeibo) forControlEvents:UIControlEventTouchUpInside];
    UIButton *qqLogin = [[UIButton alloc] initWithFrame:CGRectMake(20, 290, frameSize.width - 40, 40)];
    [qqLogin setTitle:@"腾讯 qq 登录" forState:UIControlStateNormal];
    [qqLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [qqLogin addTarget:self action:@selector(loginWithQQ) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weiboLogin];
    [self.view addSubview:qqLogin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([AVUser currentUser] != nil) {
        [self pushToMainViewController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushToMainViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"MainViewIdentifier"];

    AVUser* currentUser = [AVUser currentUser];
    AVIMClient *imClient = [[AVIMClient alloc] init];
    imClient.delegate = mainView;
    NSLog(@"open AVIMClient");
    [imClient openWithClientId:[currentUser objectId] callback:^(BOOL succeeded, NSError *error){
        if (error) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"聊天不可用！" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        } else {
            ConversationStore *store = [ConversationStore sharedInstance];
            store.imClient = imClient;
            [store reviveFromLocal:currentUser];
            [self.navigationController pushViewController:mainView animated:YES];
        }
    }];
}

- (void)signinClicked:(id)sender {
    [AVUser logInWithUsernameInBackground:_username.text
                                 password:_password.text
                                    block:^(AVUser *user, NSError *error){
                                        if (error) {
                                            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [view show];
                                        } else {
                                            [self pushToMainViewController];
                                        }
                                    }];
}

- (void)loginWithWeibo {
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if (error) {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [view show];
                } else {
                    [self pushToMainViewController];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (void)loginWithQQ {
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if (error) {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [view show];
                } else {
                    [self pushToMainViewController];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)signupClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *signupView = [storyboard instantiateViewControllerWithIdentifier:@"SignupViewIdentifier"];
    [self.navigationController pushViewController:signupView animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = (UIView *)[touch view];
    if (self.view == view) {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard
{
    NSArray *subviews = [self.view subviews];
    for (id objInput in subviews)
    {
        if ([objInput isKindOfClass:[UITextField class]])
        {
            UITextField *theTextField = objInput;
            if ([objInput isFirstResponder])
            {
                [theTextField resignFirstResponder];
            }
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
