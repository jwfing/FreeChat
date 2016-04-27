//
//  SignupViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "SignupViewController.h"
#import "AVOSCloud/AVOSCloud.h"
#import "AVUser+Avatar.h"

@interface SignupViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UITextField *_username;
    UITextField *_email;
    UITextField *_password;
    UIImageView *_avatar;
    UIImage *_customeImage;
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
    [_avatar setUserInteractionEnabled:YES];
    [_avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap:)]];
    _customeImage = nil;

    _username = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, frameSize.width - 60, 30)];
    [_username setBorderStyle:UITextBorderStyleRoundedRect];
    [_username setPlaceholder:@"username"];
    _email = [[UITextField alloc] initWithFrame:CGRectMake(30, 200, frameSize.width - 60, 30)];
    [_email setBorderStyle:UITextBorderStyleRoundedRect];
    [_email setPlaceholder:@"email"];
    _password = [[UITextField alloc] initWithFrame:CGRectMake(30, 240, frameSize.width - 60, 30)];
    [_password setBorderStyle:UITextBorderStyleRoundedRect];
    [_password setPlaceholder:@"password"];

    UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(frameSize.width - 70, 290, 60, 20)];
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
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
    [actionSheet showInView:self.view];
}

- (void)signinClicked:(id)sender {
    AVUser *user = [AVUser user];
    user.username = _username.text;
    user.email = _email.text;
    user.password = _password.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (_customeImage) {
                AVUser *currentUser = [AVUser currentUser];
                [currentUser updateAvatarWithImage:_customeImage callback:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"failed to update user avatar. error:%@", error.description);
                    }
                }];
            }
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

#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.navigationController presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _customeImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_avatar setImage:_customeImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
