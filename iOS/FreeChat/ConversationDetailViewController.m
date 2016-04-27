//
//  ConversationDetailViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 2/3/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ConversationDetailViewController.h"
#import "ConversationMemberGroupView.h"
#import "ConversationMuteView.h"
#import "MessageDisplayer.h"
#import "AVUserStore.h"
#import "UIImageView+AFNetworking.h"
#import "ContactsViewController.h"
#import "ChangeNameViewController.h"

NSString *kMemberCellIdentifier = @"ChatDetailMemberCellIdentifier";
NSString *kMuteCellIdentifier = @"ChatDetailMuteCellIdentifier";
NSString *kExitCellIdentifier = @"ChatDetailExitCellIdentifier";

@interface ConversationDetailViewController () <UITableViewDataSource, UITableViewDelegate, ConversationOperationDelegate> {
    NSMutableArray *_memberProfiles;
    UITapGestureRecognizer *_tapGesture;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ConversationDetailViewController

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize frameSize = self.view.frame.size;
    CGSize navSize = self.navigationController.navigationBar.frame.size;

    // Do any additional setup after loading the view.
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height - navSize.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[ConversationMemberGroupView class] forCellReuseIdentifier:kMemberCellIdentifier];
    [tableView registerClass:[ConversationMuteView class] forCellReuseIdentifier:kMuteCellIdentifier];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kExitCellIdentifier];
    [self.view addSubview:tableView];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addMembers2Conversation)];
    [_tapGesture setNumberOfTouchesRequired:1];
    
    if ([self createByCurrentUser]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"踢人" style:UIBarButtonItemStylePlain target:self action:@selector(pressedButtonKickoff:)];
        ;
    }
    [[AVUserStore sharedInstance] fetchInfos:self.conversation.members callback:^(NSArray *objects, NSError *error) {
        _memberProfiles = [[NSMutableArray alloc] initWithArray:objects];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)createByCurrentUser {
    NSString *currentUser = [[AVUser currentUser] objectId];
    if ([currentUser compare:self.conversation.creator] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
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

- (void)pressedButtonKickoff:(id) sender {
    AVQuery *query = [AVUser query];
    [query whereKey:@"objectId" containedIn:self.conversation.members];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [MessageDisplayer displayError:error];
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ContactsViewController *contactsController = [storyboard instantiateViewControllerWithIdentifier:@"ContactsViewIdentifier"];
        contactsController.action = KickoffMembers;
        contactsController.specificUsers = objects;
        contactsController.delegate = self;
        [self.navigationController pushViewController:contactsController animated:YES];
    }];
}

-(void)addMembers2Conversation{
    [self.conversation fetchWithCallback:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"failed to fetch conversation");
            return;
        }
        AVIMConversationUpdateBuilder* updater = [self.conversation newUpdateBuilder];
        [updater setObject:@"just-for-test" forKey:@"micUser"];
        [self.conversation update:[updater dictionary] callback:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                NSLog(@"failed to update conversation");
            }
        }];
    }];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    ContactsViewController *contactsController = [storyboard instantiateViewControllerWithIdentifier:@"ContactsViewIdentifier"];
//    contactsController.action = AddNewMembers;
//    contactsController.delegate = self;
//    [self.navigationController pushViewController:contactsController animated:YES];
}

-(BOOL)isMultiPartiesConversation{
    NSNumber *typeNumber = [self.conversation.attributes objectForKey:@"type"];
    return ([typeNumber intValue] == kConversationType_Group);
}

-(int)memberCellCount {
    int memberCount = [self.conversation.members count];
    return ceil(memberCount / 4.0);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    int delta = 0;
    if ([self isMultiPartiesConversation]) {
        delta = 1;
    }
    return [self memberCellCount] + 2 + delta;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = [indexPath row];
    int memberCellCount = [self memberCellCount];
    BOOL enableChangeName = [self isMultiPartiesConversation];
    if (index < memberCellCount) {
        ConversationMemberGroupView *result = [tv dequeueReusableCellWithIdentifier:kMemberCellIdentifier forIndexPath:indexPath];
        if (!result) {
            result = [[ConversationMemberGroupView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMemberCellIdentifier];
        }
        NSArray *avatarArray = [result avatarArray];
        NSArray *usernameArray = [result usernameArray];
        UserProfile *tmpProfile = nil;
        UIImageView *tmpAvatarView = nil;
        UILabel *tmpUsernameLabel = nil;
        for (int i = index * 4; i < (index + 1) * 4; i++) {
            tmpAvatarView = avatarArray[i - index * 4];
            tmpUsernameLabel = usernameArray[i - index * 4];
            if (i < _memberProfiles.count) {
                tmpProfile = _memberProfiles[i];
                [tmpAvatarView setImageWithURL:[NSURL URLWithString:tmpProfile.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
                [tmpUsernameLabel setText:tmpProfile.nickname];
                [tmpAvatarView setHidden:NO];
                [tmpAvatarView setUserInteractionEnabled:NO];
                [tmpAvatarView removeGestureRecognizer:_tapGesture];
                [tmpUsernameLabel setHidden:NO];
            } else if ( i == _memberProfiles.count) {
                [tmpUsernameLabel setText:@""];
                [tmpAvatarView setImage:[UIImage imageNamed:@"add_member"]];
                [tmpAvatarView setHidden:NO];
                [tmpAvatarView addGestureRecognizer:_tapGesture];
                [tmpAvatarView setUserInteractionEnabled:YES];
                [tmpUsernameLabel setHidden:NO];
            } else {
                [tmpAvatarView setHidden:YES];
                [tmpUsernameLabel setHidden:YES];
            }
        }

        return result;
    } else if (index == memberCellCount) {
        ConversationMuteView *result = [tv dequeueReusableCellWithIdentifier:kMuteCellIdentifier forIndexPath:indexPath];
        if (!result) {
            result = [[ConversationMuteView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMuteCellIdentifier];
        }
        ((ConversationMuteView*)result).delegate = self;
        [((ConversationMuteView*)result).switchView setOn:self.conversation.muted];

        return result;
    } else {
        UITableViewCell *result = [tv dequeueReusableCellWithIdentifier:kExitCellIdentifier forIndexPath:indexPath];
        if (!result) {
            result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kExitCellIdentifier];
        }
        if (enableChangeName && (index == memberCellCount + 1)) {
            [result.textLabel setTextAlignment:NSTextAlignmentLeft];
            [result.textLabel setTextColor:[UIColor blackColor]];
            if (self.conversation.name) {
                [result.textLabel setText:[NSString stringWithFormat:@"群聊名称: %@",self.conversation.name]];
            } else {
                [result.textLabel setText:@"群聊名称: 暂无"];
            }
            result.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        } else {
            [result.textLabel setTextAlignment:NSTextAlignmentCenter];
            [result.textLabel setTextColor:[UIColor redColor]];
            [result.textLabel setText:@"退出当前会话"];
            result.accessoryType=UITableViewCellAccessoryNone;
        }

        return result;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row;
    int memberCellCount = [self memberCellCount];
    if (index < memberCellCount) {
        return [ConversationMemberGroupView cellHeight];
    } else  if (index == memberCellCount) {
        return [ConversationMuteView cellHeight];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row;
    int memberCellCount = [self memberCellCount];
    if (index > memberCellCount) {
        BOOL enableChangeName = [self isMultiPartiesConversation];
        if (enableChangeName && (index == memberCellCount + 1)) {
            // change conversation name;
            ChangeNameViewController *changenameVC = [[ChangeNameViewController alloc] init];
            changenameVC.delegate = self;
            changenameVC.oldName = self.conversation.name;
            [self.navigationController pushViewController:changenameVC animated:YES];
        } else {
            // quit converstion;
            [self.conversation quitWithCallback:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    [MessageDisplayer displayError:error];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(exitConversation:)]) {
                        [self.delegate exitConversation:self.conversation];
                    }
                }
            }];
        }
    }
}

#pragma ConversationOperationDelegate
-(void)addMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation {
    __block UITableView *tab = self.tableView;
    if (clients.count < 1) {
        return;
    }
    if([self isMultiPartiesConversation]) {
        [self.conversation addMembersWithClientIds:clients callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [tab reloadData];
            } else {
                [MessageDisplayer displayError:error];
            }
        }];
    } else {
        NSMutableArray *newClients = [[NSMutableArray alloc] initWithArray:self.conversation.members];
        [newClients addObjectsFromArray:clients];

        [[ConversationStore sharedInstance].imClient createConversationWithName:nil
                                   clientIds:newClients
                                  attributes:@{@"type":[NSNumber numberWithInt:kConversationType_Group]}
                                     options:AVIMConversationOptionNone
                                    callback:^(AVIMConversation *conversation, NSError *error) {
                                        if (error) {
                                            [MessageDisplayer displayError:error];
                                        } else {
                                            [self.navigationController popViewControllerAnimated:YES];
                                            if (self.delegate && [self.delegate respondsToSelector:@selector(switch2NewConversation:)]) {
                                                [self.delegate switch2NewConversation:conversation];
                                            }
                                        }
                                    }];
    }
}

-(void)kickoffMembers:(NSArray*)clients conversation:(AVIMConversation*)conversation {
    __block UITableView *tab = self.tableView;
    if (clients.count < 1) {
        return;
    }
    [self.conversation removeMembersWithClientIds:clients callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [tab reloadData];
        } else {
            [MessageDisplayer displayError:error];
        }
    }];
}

- (void)mute:(BOOL)open conversation:(AVIMConversation *)conversation{
    if (open) {
        [self.conversation muteWithCallback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [MessageDisplayer displayError:error];
            }
        }];
    } else {
        [self.conversation unmuteWithCallback:^(BOOL succeeded, NSError *error) {
            if (error) {
                [MessageDisplayer displayError:error];
            }
        }];
    }
}

-(void)changeName:(NSString*)newName conversation:(AVIMConversation*)conversation {
    AVIMConversationUpdateBuilder *updateBuilder = [self.conversation newUpdateBuilder];
    updateBuilder.name = newName;
    __block UITableView *tab = self.tableView;
    [self.conversation update:updateBuilder.dictionary callback:^(BOOL succeeded, NSError *error) {
        if (error) {
            [MessageDisplayer displayError:error];
        } else {
            [tab reloadData];
        }
    }];
}

@end
