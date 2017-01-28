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
#import "ChooseSkinView.h"

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
    
    if (CategoryList == nil) {
        for (NSString*c in [Data getCategories]) {
            [CategoryList setObject:@"1" forKey:c];
        }
    }
    
#ifdef HUMANIX
    [btnVersions setHidden:true];
#endif
    
    [chosenCategories setDataSource:self];
    [chosenCategories setDelegate:self];
    [chosenCategories setEditing:NO];
    
    [chosenCategories reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    tmpCategoryList = [NSMutableDictionary dictionaryWithDictionary:CategoryList];
    discardChanges = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (discardChanges)
        CategoryList = [NSMutableDictionary dictionaryWithDictionary:tmpCategoryList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Hide the delete button
    return UITableViewCellEditingStyleNone;
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

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSArray* categories = [Data getCategories];
    NSString* categoryMove = [categories objectAtIndex:[sourceIndexPath row]];
    int precpos = 1;
    if ([categories objectAtIndex:[destinationIndexPath row]] > 0) {
        NSString* categoryPrec = [categories objectAtIndex:[destinationIndexPath row]-1];
        precpos = [[CategoryList objectForKey:categoryPrec] intValue];
    }
    int newpos = precpos+1;
    [CategoryList setValue:[NSString stringWithFormat:@"%d", newpos] forKey:categoryMove];
    for (unsigned long i=[destinationIndexPath row]; i<[categories count]; i++) {
        NSString* cat = [categories objectAtIndex:i];
        int ipos = [[CategoryList objectForKey:cat] intValue];
        if (ipos < (newpos + 1) && ![cat isEqualToString:categoryMove])
            [CategoryList setValue:[NSString stringWithFormat:@"%d", (newpos+1)] forKey:cat];
    }
}

-(IBAction)check:(id)sender {
    UICheckButton* btn = (UICheckButton*)sender;
    NSString* categoryName = [btn extra];
    NSString* pos = @"0";
    [btn setSelected:![btn isSelected]];
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

    [CategoryList setObject:pos forKey:categoryName];
}

-(IBAction)registerUser:(id)sender {
    
}

-(IBAction)feedback:(id)sender {
    
}

-(IBAction)skins:(id)sender {
    CGRect frm = [[self view] frame];
    CGFloat topmargin = 32; // frmNav.size.height;
    frm.origin.y = topmargin; // + frm.size.height;
    frm.size.height -= topmargin;

    //ChooseSkinView* skinview = ChooseSkinView.alloc().initWithFrame(frm);
    ChooseSkinView* skinview = [[ChooseSkinView alloc] initWithFrame:frm];
    [[self view] addSubview:skinview];
    /*
    CGRect frmDest = frm;
    frmDest.origin.y = topmargin;
    [UIView animateWithDuration:0.75f animations:^{
        [skinview setFrame:frmDest];
    }];
     */
}

-(IBAction)switchContacts:(id)sender {
    [contactCount setEnabled:[contacts isOn]];
}

-(IBAction)switchNotes:(id)sender {
    [notesCount setEnabled:[notes isOn]];
}

-(void)saveSettings {
    discardChanges = NO;
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
