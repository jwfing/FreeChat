//
//  SignupViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "SignupViewController.h"
#import "AVOSCloud/AVOSCloud.h"

@interface SignupViewController () {
    UITextField *_username;
    UITextField *_email;
    UITextField *_password;
    UIImageView *_avatar;
}

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize frameSize = self.view.frame.size;
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake((frameSize.width - 80)/2, 70, 80, 80)];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = 40;
    [_avatar setImage:[UIImage imageNamed:@"default_avatar"]];
    [_avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap:)]];

    _username = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, frameSize.width - 60, 20)];
    [_username setBorderStyle:UITextBorderStyleRoundedRect];
    [_username setPlaceholder:@"username"];
    _email = [[UITextField alloc] initWithFrame:CGRectMake(30, 190, frameSize.width - 60, 20)];
    [_email setBorderStyle:UITextBorderStyleRoundedRect];
    [_email setPlaceholder:@"email"];
    _password = [[UITextField alloc] initWithFrame:CGRectMake(30, 220, frameSize.width - 60, 20)];
    [_password setBorderStyle:UITextBorderStyleRoundedRect];
    [_password setPlaceholder:@"password"];

    UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(frameSize.width - 70, 260, 60, 20)];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(signinClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_avatar];
    [self.view addSubview:_username];
    [self.view addSubview:_email];
    [self.view addSubview:_password];
    [self.view addSubview:createButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)avatarTap:(id)sender {
}

- (void)signinClicked:(id)sender {
    AVUser *user = [AVUser user];
    user.username = _username.text;
    user.email = _email.text;
    user.password = _password.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }
    }];
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
