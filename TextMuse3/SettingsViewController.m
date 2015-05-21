//
//  SettingsViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/25/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "SettingsViewController.h"
#import "GlobalState.h"
#import "UICheckButton.h"
#import "Settings.h"
#import "MessageCategory.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(saveSettings)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    
    [sortContacts setOn:SortLastName];
    [notifications setOn:NotificationOn];
    [contacts setOn:SaveRecentContacts];
    [contactCount setEnabled:SaveRecentContacts];
    [contactCount setValue:MaxRecentContacts];
    [notes setOn:SaveRecentMessages];
    [notesCount setEnabled:SaveRecentMessages];
    [notesCount setValue:MaxRecentMessages];
    
    if (ChosenCategories == nil)
        ChosenCategories = [NSMutableArray arrayWithArray:[Data getCategories]];
    
    [chosenCategories setDataSource:self];
    [chosenCategories setDelegate:self];
    
    [chosenCategories reloadData];
    
    [self setViewPositions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setViewPositions {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Data getCategories] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"CATEGORIES SHOWN";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"shownCategory"
                                                            forIndexPath:indexPath];
    
    UILabel* category = (UILabel*)[cell viewWithTag:100];
    NSString* categoryName = [[Data getCategories] objectAtIndex:[indexPath row]];
    [category setText:categoryName];
    
    if (![[Data getRequiredCategories] containsObject:categoryName]) {
        UICheckButton* btncheck = (UICheckButton*)[cell viewWithTag:102];
        if (btncheck == nil)
            btncheck = [[UICheckButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        CGRect frmBtn = [btncheck frame];
        frmBtn.origin.y = [category frame].origin.y + 2;
        [btncheck setFrame:frmBtn];
        [btncheck addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
        [btncheck setExtra:categoryName];
        BOOL selected = [ChosenCategories containsObject:categoryName];
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

-(IBAction)check:(id)sender {
    UICheckButton* btn = (UICheckButton*)sender;
    [btn setSelected:![btn isSelected]];
    
    NSString* categoryName = [btn extra];
    if ([btn isSelected] && ![ChosenCategories containsObject:categoryName])
        [ChosenCategories addObject:categoryName];
    else if (![btn isSelected] && [ChosenCategories containsObject:categoryName])
        [ChosenCategories removeObject:categoryName];
}

-(IBAction)registerUser:(id)sender {
    
}

-(IBAction)feedback:(id)sender {
    
}

-(IBAction)switchContacts:(id)sender {
    [contactCount setEnabled:[contacts isOn]];
}

-(IBAction)switchNotes:(id)sender {
    [notesCount setEnabled:[notes isOn]];
}

-(void)saveSettings {
    [Settings SaveSetting:SettingChosenCategories withValue:ChosenCategories];
    for (NSString*c in [Data getCategories]) {
        MessageCategory*mc = [Data getCategory:c];
        [mc setChosen:[ChosenCategories containsObject:c]];
    }
    
    if (SortLastName != [sortContacts isOn]) {
        SortLastName = [sortContacts isOn];
        [Data sortContacts];
    }
    [Settings SaveSetting:SettingSortLastName withValue:SortLastName ? @"YES" : @"NO"];
    
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
    
    [[self navigationController] popViewControllerAnimated:YES];
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
