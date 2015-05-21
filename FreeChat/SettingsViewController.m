//
//  SettingsViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "SettingsViewController.h"
#import "AVOSCloud/AVOSCloud.h"
#import "ConversationStore.h"
#import "AVUser+Avatar.h"
#import "UIImageView+AFNetworking.h"
#import "MessageDisplayer.h"
#import "LeanCloudFeedback.h"

@interface SettingsViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UILabel *_username;
    UIImageView *_avatarView;
    UIButton *_logoutButton;
    BOOL _avatarUpdating;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize frameSize = self.view.frame.size;
    CGSize navSize = self.navigationController.navigationBar.frame.size;
    NSLog(@"frame width=%f, frame height=%f", frameSize.width, frameSize.height);
    _username = [[UILabel alloc] initWithFrame:CGRectMake(20, navSize.height + 214, frameSize.width - 40, 20)];
    [_username setFont:[UIFont systemFontOfSize:18.0]];
    [_username setTextAlignment:NSTextAlignmentCenter];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((frameSize.width - 150)/2, navSize.height + 44, 150, 150)];
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = 150 / 2;
    [_avatarView setUserInteractionEnabled:YES];
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeUserAvatar)]];

    _logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(20, frameSize.height - navSize.height - 64, frameSize.width - 40, 30)];
    [_logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
//    [_logoutButton setBackgroundColor:[UIColor lightGrayColor]];
    [_logoutButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_logoutButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, frameSize.height - navSize.height - 104, frameSize.width - 40, 30)];
    [feedbackBtn setTitle:@"提交反馈" forState:UIControlStateNormal];
    [feedbackBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [feedbackBtn addTarget:self action:@selector(pressedFeedback:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_username];
    [self.view addSubview:_avatarView];
    [self.view addSubview:_logoutButton];
    [self.view addSubview:feedbackBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AVUser *currentUser = [AVUser currentUser];
    [_username setText:[NSString stringWithFormat:@"当前用户: %@",[currentUser username]]];
    NSString *avatarUrl = currentUser.avatarUrl;
    if ([avatarUrl length] > 0) {
        [_avatarView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        [_avatarView setImage:[UIImage imageNamed:@"default_avatar"]];
    }
    _avatarUpdating = NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)pressedFeedback:(id)sender {
    LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
    [agent showConversations:self title:@"提点建议" contact:[AVUser currentUser].username];
}

- (void)logout:(id)sender {
    if (_avatarUpdating) {
        return;
    }
    ConversationStore *store = [ConversationStore sharedInstance];
    [store dump2Local:[AVUser currentUser]];
    [AVUser logOut];
    [store.imClient closeWithCallback:^(BOOL succeeded, NSError *error) {
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

- (void)changeUserAvatar {
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
    [actionSheet showInView:self.view];
}

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
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        AVUser *currentUser = [AVUser currentUser];
        _avatarUpdating = YES;
        [currentUser updateAvatarWithImage:editImage callback:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [MessageDisplayer displayError:error];
            } else {
                [_avatarView setImage:editImage];
            }
            _avatarUpdating = NO;
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
