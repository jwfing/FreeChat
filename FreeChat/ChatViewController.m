//
//  ChatViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ChatViewController.h"
#import "ConversationDetailViewController.h"
#import "MessageDisplayer.h"
#import "FCMessageCell.h"
#import "AVUserStore.h"

#define INPUTVIEW_HEIGHT 40

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, IMEventObserver,
UUInputFunctionViewDelegate, FCMessageCellDelegate, ConversationOperationDelegate>{
    UITableView *_tableView;
    UUInputFunctionView *_inputView;
    NSMutableArray *_messages;
    BOOL _quitConversation;
}

@end

@implementation ChatViewController

@synthesize conversation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"ChatRoom";
    [self.view setBackgroundColor:[UIColor whiteColor]];

    CGSize frameSize = self.view.frame.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height - 40) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _inputView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    _inputView.delegate = self;
    [self.view addSubview:_inputView];

    [self initNavigationButton];

    
    _messages = [[NSMutableArray alloc] initWithCapacity:100];
    _quitConversation = NO;

    ConversationStore *store = [ConversationStore sharedInstance];
    [store queryMoreMessages:self.conversation from:@"" timestamp:[[NSDate date] timeIntervalSince1970]*1000 limit:20 callback:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_messages addObjectsFromArray:objects];
            [_tableView reloadData];
        });
    }];
}

- (void)initNavigationButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pressedButtonDetail:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];

    ConversationStore *store = [ConversationStore sharedInstance];
    [store addEventObserver:self forConversation:self.conversation.conversationId];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ConversationStore *store = [ConversationStore sharedInstance];
    if (_quitConversation) {
        [store quitConversation:self.conversation];
    } else {
        [store openConversation:self.conversation];
    }
    [store removeEventObserver:self forConversation:self.conversation.conversationId];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (notification.name == UIKeyboardWillShowNotification) {
        self.view.frame = CGRectOffset(self.view.frame, 0, -keyboardEndFrame.size.height);
    }else{
        self.view.frame = CGRectOffset(self.view.frame, 0, keyboardEndFrame.size.height);
    }

    [UIView commitAnimations];
}

- (void)pressedButtonDetail:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConversationDetailViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailIdentifier"];
    detailController.conversation = self.conversation;
    detailController.delegate = self;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messages count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[FCMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    FCMessageFrame *frame = [[FCMessageFrame alloc] init];
    [frame setMessage:((Message*)_messages[indexPath.row])];
    [cell setMessageFrame:frame];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCMessageFrame *frame = [[FCMessageFrame alloc] init];
    [frame setMessage:((Message*)_messages[indexPath.row])];
    return frame.cellHeight;
}

#pragma IMEventObserver
- (void)newMessageArrived:(Message*)message conversation:(AVIMConversation*)conv {
    if (message.eventType == EventKicked) {
        UserProfile *profile = [[AVUserStore sharedInstance] getUserProfile:message.byClient];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ 剔除了你", profile.nickname] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        [self exitConversation:conv];
        return;
    } else {
        [_messages addObject:message];
        [_tableView reloadData];
    }
}

- (void)messageDelivered:(Message*)message conversation:(AVIMConversation*)conversation {
    ;
}

#pragma UUInputFunctionViewDelegate
// text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message {
    if ([message length] > 0) {
        AVIMTextMessage *avMessage = [AVIMTextMessage messageWithText:message attributes:nil];
        [self.conversation sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [MessageDisplayer displayError:error];
            } else {
                Message *msg = [[Message alloc] initWithAVIMMessage:avMessage];
                [_messages addObject:msg];
                [_tableView reloadData];
            }
        }];
    }
}

// image
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image {
    if (image) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:NULL];
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        AVIMImageMessage *avMessage = [AVIMImageMessage messageWithText:nil attachedFilePath:filePath attributes:nil];
        [self.conversation sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [MessageDisplayer displayError:error];
            } else {
                Message *msg = [[Message alloc] initWithAVIMMessage:avMessage];
                [_messages addObject:msg];
                [_tableView reloadData];
            }
        }];
    }
}

// audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second {
    if (voice) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audio.mp3"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:NULL];
        [voice writeToFile:filePath atomically:YES];

        AVIMAudioMessage *avMessage = [AVIMAudioMessage messageWithText:nil attachedFilePath:filePath attributes:nil];
        [self.conversation sendMessage:avMessage callback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [MessageDisplayer displayError:error];
            } else {
                Message *msg = [[Message alloc] initWithAVIMMessage:avMessage];
                [_messages addObject:msg];
                [_tableView reloadData];
            }
        }];
    }
}

#pragma FCMessageCellDelegate
- (void)headImageDidClick:(FCMessageCell *)cell userId:(NSString *)userId {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tip" message:@"HeadImageClick !!!" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

- (void)cellContentDidClick:(FCMessageCell *)cell image:(UIImage *)contentImage {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tip" message:@"MessageContentClick !!!" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

#pragma ConversationOperationDelegate
-(void)exitConversation:(AVIMConversation*)conversation {
    _quitConversation = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)switch2NewConversation:(AVIMConversation *)newConversation{
    [self.navigationController popViewControllerAnimated:YES];
    ChatViewController *newVC = [[ChatViewController alloc] init];
    newVC.conversation = newConversation;
    [self.navigationController pushViewController:newVC animated:YES];
}

@end
