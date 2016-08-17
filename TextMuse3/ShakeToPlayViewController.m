//
//  ShakeToPlayViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 8/9/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "ShakeToPlayViewController.h"
#import "GlobalState.h"
#import "DataAccess.h"
#import "Settings.h"
#import "MessageCategory.h"
#import "Message.h"
#import "UserContact.h"

@interface ShakeToPlayViewController ()

@end

@implementation ShakeToPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sendMessage = [[SendMessage alloc] init];
    
    [pickerContacts setDelegate:self];
    [pickerContacts setDataSource:self];
    [pickerTexts setDelegate:self];
    [pickerTexts setDataSource:self];
}

-(void)viewWillAppear:(BOOL)animated {
    CGRect frmMessagePicker = [pickerTexts frame];
    CGRect frmSendBtn = CGRectMake(([[self view] frame].size.width/2) - 72,
                                   frmMessagePicker.origin.y + frmMessagePicker.size.height + 20, 144, 36);
    btnSendIt = [[UICaptionButton alloc] initWithFrame:frmSendBtn
                                             withImage:[UIImage imageNamed:@"TextMuseButton"]
                                          andRightText:@"text it"];
    [btnSendIt addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnSendIt];
}

- (void)viewDidAppear:(BOOL)animated {
    [self play];

    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self play];
}

-(IBAction)lock:(id)sender {
    UIButton* btn = (UIButton*)sender;
    [btn setSelected:![btn isSelected]];
}

-(void)play {
    if (![btnTextLock isSelected]) {
        int t = arc4random() % [[Data getEventMessages] count];
        [pickerTexts selectRow:t inComponent:0 animated:YES];
    }
    if (![btnContactLock isSelected]) {
        int c = arc4random();
        c = (RecentContacts == nil || [RecentContacts count] == 0) ?
                c % [[Data getContacts] count] :
                c % [RecentContacts count];
        [pickerContacts selectRow:c inComponent:0 animated:YES];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView == pickerContacts) {
        if (RecentContacts == nil || [RecentContacts count] == 0)
            return [[Data getContacts] count];
        else
            return [RecentContacts count];
    }
    else
        return [[Data getEventMessages] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    if (pickerView == pickerContacts) {
        UserContact* uc = nil;
        if (RecentContacts == nil || [RecentContacts count] == 0)
            uc = [[Data getContacts] objectAtIndex:row];
        else {
            uc = [Data findUserByPhone:[RecentContacts objectAtIndex:row]];
        }
        return [NSString stringWithFormat:@"%@ %@", [uc firstName], [uc lastName]];
    }
    else
        return [[[Data getEventMessages] objectAtIndex:row] text];
}

-(void)sendMessage:(id)sender {
    Message* msg = [[Data getEventMessages] objectAtIndex:[pickerTexts selectedRowInComponent:0]];
    UserContact* uc = nil;
    if (RecentContacts == nil || [RecentContacts count] == 0)
        uc = [[Data getContacts] objectAtIndex:[pickerContacts selectedRowInComponent:0]];
    else
        uc = [Data findUserByPhone:[RecentContacts objectAtIndex:[pickerContacts selectedRowInComponent:0]]];
    
    CurrentCategory = [msg category];
    CurrentMessage = msg;

    [sendMessage sendMessageTo:[NSArray arrayWithObject:uc] from:self];
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

@end
