//
//  ChangeNameViewController.m
//  FreeChat
//
//  Created by Feng Junwen on 3/6/15.
//  Copyright (c) 2015 Feng Junwen. All rights reserved.
//

#import "ChangeNameViewController.h"

@interface ChangeNameViewController () {
    UITextField *_textField;
}

@end

@implementation ChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize frameSize = self.view.frame.size;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 94, frameSize.width - 20, 30)];
    [_textField setFont:[UIFont systemFontOfSize:18.0f]];
    [_textField setText:self.oldName];
    [_textField setPlaceholder:@"please input something..."];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textField];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(pressedButtonOK:)];
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

-(void)pressedButtonOK:(id)sender {
    NSString *newValue = _textField.text;
    if ([newValue compare:self.oldName] != NSOrderedSame) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeName:conversation:)]) {
            [self.delegate changeName:newValue conversation:nil];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
