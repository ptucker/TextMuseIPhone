//
//  Settings2ViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 8/4/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import "Settings2ViewController.h"
#import "GlobalState.h"
#import "UICheckButton.h"
#import "Settings.h"
#import "ChooseSkinView.h"

@interface Settings2ViewController ()

@end

@implementation Settings2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [sortContacts setOn:SortLastName];
    [groupMessages setOn:!GroupMessages];
    [notifications setOn:NotificationOn];
    [contacts setOn:SaveRecentContacts];
    [contactCount setEnabled:SaveRecentContacts];
    [contactCount setValue:MaxRecentContacts];
    [notes setOn:SaveRecentMessages];
    [notesCount setEnabled:SaveRecentMessages];
    [notesCount setValue:MaxRecentMessages];
    
#ifdef HUMANIX
    [btnVersions setHidden:true];
#endif
#ifdef YOUTHREACH
    [btnVersions setHidden:true];
#endif
#ifdef OODLES
    [btnVersions setHidden:true];
#endif
#ifdef NRCC
    [btnVersions setHidden:true];
#endif

    if (CategoryList == nil) {
        for (NSString*c in [Data getCategories]) {
            [CategoryList setObject:@"1" forKey:c];
        }
    }

    [chosenCategories setDataSource:self];
    [chosenCategories setDelegate:self];
    [chosenCategories setEditing:NO];
    
    [chosenCategories reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Data getCategories] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"CATEGORIES SHOWN";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    
    UILabel* category = [[UILabel alloc] initWithFrame:CGRectMake(40, 5,
                                                                  [tableView frame].size.width - 50, 25)];
    NSString* categoryName = [[Data getCategories] objectAtIndex:[indexPath row]];
    [category setText:categoryName];
    [cell addSubview:category];
    
    if (![[Data getRequiredCategories] containsObject:categoryName]) {
        UICheckButton* btncheck = (UICheckButton*)[cell viewWithTag:102];
        if (btncheck == nil)
            btncheck = [[UICheckButton alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
        CGRect frmBtn = [btncheck frame];
        frmBtn.origin.y = [category frame].origin.y + 2;
        [btncheck setFrame:frmBtn];
        [btncheck addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
        [btncheck setExtra:categoryName];
        if ([CategoryList objectForKey:categoryName] == nil)
            [CategoryList setObject:@"1" forKey:categoryName];
        BOOL selected = ![[CategoryList objectForKey:categoryName] isEqualToString: @"0"];
        [btncheck setSelected:selected];
        
        if ([btncheck tag] == 0) {
            [btncheck setTag:102];
            [cell addSubview:btncheck];
        }
    }
    else {
        UIView* v = [cell viewWithTag:102];
        if (v != nil)
            [v removeFromSuperview];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    UICheckButton* chk = (UICheckButton*) [cell viewWithTag:102];
    if (chk != nil)
        [self check:chk];
}

-(IBAction)check:(id)sender {
    UICheckButton* btn = (UICheckButton*)sender;
    NSString* categoryName = [btn extra];
    [btn setSelected:![btn isSelected]];
    /*
     NSString* pos = @"0";
    if ([btn isSelected]) {
        NSArray* categories = [Data getCategories];
        int max = -1;
        for (int i=0; i<[categories count]; i++) {
            NSString* cat = [categories objectAtIndex:i];
            if (![[CategoryList objectForKey:cat] isEqualToString:@"0"]) {
                int tmp = [[CategoryList objectForKey:cat] intValue];
                if (tmp > max)
                    max = tmp;
            }
        }
        pos = [NSString stringWithFormat:@"%d", (max+1)];
    }
    */
    
    [CategoryList setObject:[btn isSelected] ? @"1" : @"0" forKey:categoryName];
    if ([btn isSelected])
        [SqlDb addChosenCategory:categoryName];
    else
        [SqlDb removeChosenCategory:categoryName];
}

-(IBAction)switchContacts:(id)sender {
    [contactCount setEnabled:[contacts isOn]];
}

-(IBAction)switchNotes:(id)sender {
    [notesCount setEnabled:[notes isOn]];
}

-(IBAction)skins:(id)sender {
    CGRect frm = [[self view] frame];
    CGFloat topmargin = 32; // frmNav.size.height;
    frm.origin.y = topmargin; // + frm.size.height;
    frm.size.height -= topmargin;
    
    ChooseSkinView* skinview = [[ChooseSkinView alloc] initWithFrame:frm];
    [[self view] addSubview:skinview];
}

-(void)saveSettings {
    [Settings SaveSetting:SettingCategoryList withValue:CategoryList];
    for (NSString*c in [Data getCategories]) {
        MessageCategory*mc = [Data getCategory:c];
        [mc setChosen:![[CategoryList objectForKey:c] isEqualToString:@"0"]];
    }
    
    if (SortLastName != [sortContacts isOn]) {
        SortLastName = [sortContacts isOn];
        [Data sortContacts];
    }
    [Settings SaveSetting:SettingSortLastName withValue:SortLastName ? @"YES" : @"NO"];
    
    GroupMessages = ![groupMessages isOn];
    [Settings SaveSetting:SettingGroupMessages withValue:GroupMessages ? @"YES" : @"NO"];
    
    NotificationOn = [notifications isOn];
    [Settings SaveSetting:SettingNotificationOn withValue:NotificationOn ? @"YES" : @"NO"];
    
    SaveRecentContacts = [contacts isOn];
    [Settings SaveSetting:SettingSaveRecentContacts withValue:SaveRecentContacts ? @"YES" : @"NO"];
    MaxRecentContacts = (int)[contactCount value];
    [Settings SaveSetting:SettingRecentContactsCount withValue:[NSString stringWithFormat:@"%d", MaxRecentContacts]];
    
    SaveRecentMessages = [notes isOn];
    [Settings SaveSetting:SettingSaveRecentMessages withValue:SaveRecentMessages ? @"YES" : @"NO"];
    MaxRecentMessages = (int)[notesCount value];
    [Settings SaveSetting:SettingRecentMessagesCount withValue:[NSString stringWithFormat:@"%d", MaxRecentMessages]];
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
