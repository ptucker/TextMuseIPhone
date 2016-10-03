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
    
    recentContacts = true;
    
    sendMessage = [[SendMessage alloc] init];
    
    [pickerContacts setDelegate:self];
    [pickerContacts setDataSource:self];
    [pickerTexts setDelegate:self];
    [pickerTexts setDataSource:self];
}

-(void)viewWillAppear:(BOOL)animated {
    CGRect frmMessagePicker = [pickerTexts frame];
    CGRect frmContactPicker = [pickerContacts frame];
    CGRect frmSendBtn = CGRectMake(([[self view] frame].size.width/2) - 72,
                                   frmMessagePicker.origin.y + frmMessagePicker.size.height + 20, 144, 36);
    btnSendIt = [[UICaptionButton alloc] initWithFrame:frmSendBtn
                                             withImage:[UIImage imageNamed:@"TextMuseButton"]
                                          andRightText:@"text it"];
    [btnSendIt addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnSendIt];
    
    if (RecentContacts != nil && [RecentContacts count] > 0) {
        chkRecentContacts = [[UICheckButton alloc] initWithFrame:CGRectMake(8, frmContactPicker.origin.y - 30,
                                                                            20, 20)];
        [chkRecentContacts setSelected:YES];
        [chkRecentContacts addTarget:self action:@selector(contactList:)
                    forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:chkRecentContacts];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(44, frmContactPicker.origin.y - 30,
                                                                 [[self view] frame].size.width - 40, 20)];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [lbl setText:@"recent contacts"];
        [[self view] addSubview:lbl];
    }
    else
        recentContacts = false;
}

-(NSUInteger)getContactCount {
    if (RecentContacts == nil || [RecentContacts count] == 0 || !recentContacts)
        return [[Data getContacts] count];
    else {
        return [RecentContacts count];
    }
}

-(UserContact*) getContactAt:(NSInteger)idx {
    if (RecentContacts == nil || [RecentContacts count] == 0 || !recentContacts)
        return [[Data getContacts] objectAtIndex:idx];
    else {
        return [Data findUserByPhone:[RecentContacts objectAtIndex:idx]];
    }
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
        c = c % [self getContactCount];
        [pickerContacts selectRow:c inComponent:0 animated:YES];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView == pickerContacts)
        return [self getContactCount];
    else
        return [[Data getEventMessages] count];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if (pickerView == pickerContacts)
        return 40;
    else
        return 120;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView* ret = nil;
    if (pickerView == pickerContacts) {
        UserContact* uc = [self getContactAt:row];
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView frame].size.width, 40)];
        [lbl setText:[NSString stringWithFormat:@"%@ %@", [uc firstName], [uc lastName]]];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:22]];
        ret = lbl;
    }
    else {
        ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [pickerView frame].size.width, 120)];
        UILabel* lbl = nil;
        Message* msg = [[Data getEventMessages] objectAtIndex:row];
        if ([msg img] != nil) {
            UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,30,60,60)];
            [imgview setImage:[UIImage imageWithData:[msg img]]];
            [imgview setContentMode:UIViewContentModeScaleAspectFit];
            [ret addSubview:imgview];
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, [pickerView frame].size.width - 60, 120)];
        }
        else {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView frame].size.width, 120)];
        }
        [lbl setNumberOfLines:0];
        [lbl setText:[msg text]];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:22]];
        
        [ret addSubview:lbl];
    }
    return ret;
}

-(void)contactList:(id)sender {
    [chkRecentContacts setSelected:![chkRecentContacts isSelected]];
    recentContacts = [chkRecentContacts isSelected];
    [pickerContacts reloadAllComponents];
}

-(void)sendMessage:(id)sender {
    Message* msg = [[Data getEventMessages] objectAtIndex:[pickerTexts selectedRowInComponent:0]];
    UserContact* uc = [self getContactAt:[pickerContacts selectedRowInComponent:0]];
    
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
