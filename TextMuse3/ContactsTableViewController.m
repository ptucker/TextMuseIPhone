//
//  ContactsTableViewController.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/20/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "GlobalState.h"
#import "UserContact.h"
#import "UICheckButton.h"
#import "Settings.h"
#import "ChoosePhoneView.h"
#import "SendMessage.h"

@interface ContactsTableViewController ()

@end

NSMutableArray* searchContacts;

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[[[self navigationController] navigationBar] topItem] setTitle:@"Back"];

    sendMessage = [[SendMessage alloc] init];
    checkedContacts = [[NSMutableArray alloc] init];
    
    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(sendMessages:)];
    //[rightButton setEnabled:NO];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    
    showRecentContacts = (SaveRecentContacts && [RecentContacts count] > 0);

    [contacts setDelegate:self];
    [contacts setDataSource:self];
    
    fontBold = [UIFont fontWithName:@"Lato-Regular" size:18];
    fontLight = [UIFont fontWithName:@"Lato-Light" size:18];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    if ([NamedGroups count] > 0) {
        NSMutableArray* gs = [[NSMutableArray alloc] init];
        for (NSString* k in [NamedGroups keyEnumerator]) {
            [gs addObject:k];
        }
        groups = [gs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    [contacts reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        return 1;
    else
        return [[Data getContactHeadings] count]+1 + (showRecentContacts ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        return [searchContacts count];
    else {
        if ((section == 0 && showRecentContacts))
            return [RecentContacts count];
        else if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts))
            return [groups count];
        else {
            // Return the number of rows in the section.
            NSArray* headings = [Data getContactHeadings];
            section--;
            if (showRecentContacts) section--;
            return [[Data getContactsForHeading:[headings objectAtIndex:section]] count];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                  [tableView frame].size.width, 34.0)];
    [customView setBackgroundColor:[UIColor colorWithRed:240.0/256
                                                   green:240.0/256
                                                    blue:240.0/256
                                                   alpha:1.0]];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,
                                                             [tableView frame].size.width-100, 34.0)];

    [lbl setText:[self tableView:tableView titleForHeaderInSection:section]];
    [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:15.0]];
    [lbl setTextColor:[UIColor blackColor]];
    [customView addSubview:lbl];
    
    if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts)) {
        // create the edit button
        CGRect frm = CGRectMake([tableView frame].size.width-100, 0.0, 90.0, 34.0);
        UIButton * headerBtn = [[UIButton alloc] initWithFrame:frm];
        headerBtn.backgroundColor = [UIColor clearColor];
        [headerBtn setTitle:@"Edit" forState:UIControlStateNormal];
        [[headerBtn titleLabel] setTextAlignment:NSTextAlignmentRight];
        [headerBtn setTitleColor:[UIColor colorWithRed:22.0/256 green:194.0/256 blue:223.0/256 alpha:1.0]
                        forState:UIControlStateNormal];
        [headerBtn addTarget:self action:@selector(editGroups:)
            forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:headerBtn];
    }
    
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* title = @"Recent Contacts";
    if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts))
        title = @"Groups";
    else if ((section > 0 && !showRecentContacts) || (section > 1 && showRecentContacts)) {
        section--;
        if (showRecentContacts) section--;
        title = [[Data getContactHeadings] objectAtIndex:section];
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    long section = [indexPath section];
    if (tableView == contacts || tableView == [[self searchDisplayController] searchResultsTableView]) {
        if (tableView == contacts)
            cell = [tableView dequeueReusableCellWithIdentifier:@"contacts"
                                                   forIndexPath:indexPath];
        else {
            cell = [[UITableViewCell alloc] init];
            CGRect frmLeft = CGRectMake(8, 8, [tableView frame].size.width/2 - 4, 44);
            CGRect frmRight = CGRectMake(8, [tableView frame].size.width/2 + 4, frmLeft.size.width, 44);
            UILabel* left = [[UILabel alloc] initWithFrame:frmLeft];
            UILabel* right = [[UILabel alloc] initWithFrame:frmRight];
            [left setTag:100];
            [right setTag:101];
            [cell addSubview:left];
            [cell addSubview:right];
        }

        if (tableView == contacts && ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts))) {
            UILabel* fname = (UILabel*)[cell viewWithTag:100];
            [fname setText:[groups objectAtIndex:[indexPath row]]];
            [fname sizeToFit];
            UILabel* lname = (UILabel*)[cell viewWithTag:101];
            [lname setHidden:YES];
            UICheckButton* btncheck = (UICheckButton*)[cell viewWithTag:102];
            if (btncheck != nil)
                [btncheck setHidden:YES];
        }
        else {
            UserContact* contact;
            
            if (tableView == [[self searchDisplayController] searchResultsTableView]) {
                contact = [searchContacts objectAtIndex:[indexPath row]];
            }
            else {
                if (showRecentContacts && section == 0) {
                    contact = [Data findUserByPhone:[RecentContacts objectAtIndex:[indexPath row]]];
                }
                else {
                    section--;
                    if (showRecentContacts) section--;
                
                    NSArray* headings = [Data getContactHeadings];
                    NSArray* cs = [Data getContactsForHeading:[headings objectAtIndex:section]];
                    contact = [cs objectAtIndex:[indexPath row]];
                }
            }
            UILabel* fname = (UILabel*)[cell viewWithTag:100];
            UILabel* lname = (UILabel*)[cell viewWithTag:101];
            [fname setTextColor:[UIColor blackColor]];
            [lname setTextColor:[UIColor blackColor]];
            [fname setFont:SortLastName ? fontLight : fontBold];
            [lname setFont:!SortLastName ? fontLight : fontBold];
            UICheckButton* btncheck = (UICheckButton*)[cell viewWithTag:102];
            if (btncheck == nil)
                btncheck = [[UICheckButton alloc] initWithFrame:CGRectMake(3, 3, 28, 28)];
            [btncheck setHidden:NO];
            [fname setText:[contact firstName]];
            [fname sizeToFit];
            CGRect frmLName = [fname frame];
            frmLName.origin.x = [fname frame].origin.x + [fname frame].size.width + 8;
            frmLName.size.width = [cell frame].size.width - 8 - frmLName.origin.x;
            [lname setHidden:NO];
            [lname setFrame:frmLName];
            [lname setText:[contact lastName]];
            [lname sizeToFit];
            CGRect frmBtn = [btncheck frame];
            frmBtn.origin.y = [fname frame].origin.y + 2;
            [btncheck setFrame:frmBtn];
            [btncheck addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
            [btncheck setExtra:contact];
            [btncheck setSelected:[checkedContacts containsObject:contact]];
        
            if ([btncheck tag] == 0 && tableView == contacts) {
                [btncheck setTag:102];
                [cell addSubview:btncheck];
            }
        }
    }
    else {
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [Data getContactHeadings];
}

- (NSInteger)tableView:(UITableView *)tableView
        sectionForSectionIndexTitle:(NSString*)title
               atIndex:(NSInteger)index {
    long i = 0;
    NSArray* headings = [Data getContactHeadings];
    for (; i<[headings count]; i++) {
        if ([[headings objectAtIndex:i] isEqualToString:title])
            break;
    }
    i++; //to skip groups
    if (showRecentContacts) i++; //skip recent contacts
    return i;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long section = [indexPath section];
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        UserContact* contact = [searchContacts objectAtIndex:[indexPath row]];
        
        NSArray* contactlist = [NSArray arrayWithObject:contact];
        [sendMessage sendMessageTo:contactlist from:self];
    }
    else {
        if (section == 0 && showRecentContacts) {
            UserContact* contact = [Data findUserByPhone:[RecentContacts objectAtIndex:[indexPath row]]];
            
            NSArray* contactlist = [NSArray arrayWithObject:contact];
            [sendMessage sendMessageTo:contactlist from:self];
        }
        else if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts)) {
            NSArray* grp = [NamedGroups objectForKey:[groups objectAtIndex:[indexPath row]]];
            NSMutableArray* users = [[NSMutableArray alloc] init];
            for (NSString*phone in grp) {
                [users addObject:[Data findUserByPhone:phone]];
            }
            if ([users count] > 0)
                [sendMessage sendMessageTo:users from:self];
        }
        else {
            section--;
            if (showRecentContacts) section--;
            
            NSArray* headings = [Data getContactHeadings];
            NSArray* cs = [Data getContactsForHeading:[headings objectAtIndex:section]];
            UserContact* contact = [cs objectAtIndex:[indexPath row]];

            NSArray* contactlist = [NSArray arrayWithObject:contact];
            [sendMessage sendMessageTo:contactlist from:self];
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* actChoose =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:@"Choose number"
                                     handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                                         NSArray* cs;
                                         int topMargin = 8;
                                         if (tableView == [[self searchDisplayController] searchResultsTableView]) {
                                             cs = [NSArray arrayWithObject:[searchContacts objectAtIndex:[indexPath row]]];
                                             topMargin += 40;
                                         }
                                         else {
                                             long section = [indexPath section];
                                             if (section == 0 && showRecentContacts)
                                                 cs = [NSArray arrayWithObject:[Data findUserByPhone:[RecentContacts objectAtIndex:[indexPath row]]]];
                                             else if ((section == 0 && !showRecentContacts) ||
                                                      (section == 1 && showRecentContacts)) {
                                                 NSArray* grp = [NamedGroups objectForKey:[groups objectAtIndex:[indexPath row]]];
                                                 NSMutableArray* users = [[NSMutableArray alloc] init];
                                                 for (NSString*phone in grp) {
                                                     [users addObject:[Data findUserByPhone:phone]];
                                                 }
                                                 cs = [NSArray arrayWithArray:users];
                                             }
                                             else {
                                                 section--;
                                                 if (showRecentContacts) section--;
                                                 NSArray* headings = [Data getContactHeadings];
                                                 NSArray* users = [Data getContactsForHeading:[headings objectAtIndex:section]];
                                                 cs = [NSArray arrayWithObject: [users objectAtIndex:[indexPath row]]];
                                             }
                                         }
                                         if (cs != nil/* && [cs count] > 0*/)
                                             [self choosePhone:cs withMargin:topMargin];
                                     }];
    return [NSArray arrayWithObjects:actChoose, nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:[searchString lowercaseString]];
    return true;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[[controller searchBar] text]];
    return true;
}

-(void)filterContentForSearchText:(NSString*)searchText {
    NSMutableArray* filtered = [[NSMutableArray alloc] init];
    NSArray* cs = [Data getContacts];
    for (UserContact* uc in cs) {
        NSString* compare = [[uc description] lowercaseString];
        if ([compare containsString:searchText])
            [filtered addObject: uc];
    }
    searchContacts = filtered;
}

-(void)choosePhone:(NSArray*)users withMargin:(int)margin {
    CGRect frm = [[self view] frame];
    CGRect frmNav = [[[self navigationController] navigationBar] frame];
    CGFloat topmargin = frmNav.origin.y + frmNav.size.height;
    frm.origin.x += 8;
    frm.origin.y += frm.size.height;
    frm.size.width -= 16;
    frm.size.height -= 20 - margin;
    ChoosePhoneView* choosephone = [[ChoosePhoneView alloc] initWithFrame:frm];
    [choosephone setUsers:users];
    [choosephone setNavItem:[self navigationItem]];
    [[self view] addSubview:choosephone];

    CGRect frmDest = frm;
    frmDest.origin.y = topmargin + margin;
    [UIView animateWithDuration:0.3f animations:^{
        [choosephone setFrame:frmDest];
    }];
    
    [[self navigationItem] setHidesBackButton:YES animated:YES];
}

-(IBAction)editGroups:(id)sender {
    [self performSegueWithIdentifier:@"ShowGroups" sender:self];
}

-(IBAction)backButton:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)check:(id)sender {
    UICheckButton* btn = (UICheckButton*)sender;
    [btn setSelected:![btn isSelected]];
    
    UserContact* uc = (UserContact*)[btn extra];
    if ([btn isSelected])
        [checkedContacts addObject:uc];
    else {
        [checkedContacts removeObjectIdenticalTo:uc];
    }
    
    //[rightButton setEnabled:[checkedContacts count] > 0];
    
    [self syncSendButton];
}

-(IBAction)sendMessages:(id)sender {
    if ([checkedContacts count] > 1) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Name Group Title", nil)
                              message:NSLocalizedString(@"Name Group Details", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Yes Button", nil)
                              otherButtonTitles:NSLocalizedString(@"No Button", nil), nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setPlaceholder:@"Group name"];
        [alert show];
    }
    else
        [sendMessage sendMessageTo:checkedContacts from:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* grp = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 0 && [grp length] > 0 && [NamedGroups objectForKey:grp] == nil) {
        NSMutableArray* cs = [[NSMutableArray alloc] init];
        for (NSString* p in checkedContacts) {
            [cs addObject:p];
        }
        [Settings AddGroup:grp withContacts:cs];
    }

    [sendMessage sendMessageTo:checkedContacts from:self];
}



-(void)syncSendButton {
    [btnSend setHidden:[checkedContacts count] == 0];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
