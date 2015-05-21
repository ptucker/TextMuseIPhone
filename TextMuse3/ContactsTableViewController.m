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
#import <MobileCoreServices/MobileCoreServices.h>

@interface ContactsTableViewController ()

@end

NSString* urlUpdateNotes = @"http://www.textmuse.com/admin/notesend.php";

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[[[self navigationController] navigationBar] topItem] setTitle:@"Back"];

    checkedContacts = [[NSMutableArray alloc] init];
    
    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(sendMessages:)];
    [rightButton setEnabled:NO];
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
    return [[Data getContactHeadings] count]+1 + (showRecentContacts ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    if (tableView == contacts) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"contacts"
                                               forIndexPath:indexPath];

        if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts)) {
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
            UILabel* fname = (UILabel*)[cell viewWithTag:100];
            UILabel* lname = (UILabel*)[cell viewWithTag:101];
            [fname setFont:SortLastName ? fontLight : fontBold];
            [lname setFont:!SortLastName ? fontLight : fontBold];
            UICheckButton* btncheck = (UICheckButton*)[cell viewWithTag:102];
            if (btncheck == nil)
                btncheck = [[UICheckButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
            [btncheck setHidden:NO];
            [fname setText:[contact firstName]];
            [fname sizeToFit];
            CGRect frmLName = [fname frame];
            frmLName.origin.x = [fname frame].origin.x + [fname frame].size.width + 8;
            frmLName.size.width = [cell frame].size.width - 8 - frmLName.origin.x;
            [lname setHidden:NO];
            [lname setFrame:frmLName];
            [lname setText:[contact lastName]];
            CGRect frmBtn = [btncheck frame];
            frmBtn.origin.y = [fname frame].origin.y + 2;
            [btncheck setFrame:frmBtn];
            [btncheck addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
            [btncheck setExtra:contact];
        
            if ([btncheck tag] == 0) {
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
    
    if (section == 0 && showRecentContacts) {
        UserContact* contact = [Data findUserByPhone:[RecentContacts objectAtIndex:[indexPath row]]];
        
        NSArray* contactlist = [NSArray arrayWithObject:contact];
        [self sendMessageTo:contactlist];
    }
    else if ((section == 0 && !showRecentContacts) || (section == 1 && showRecentContacts)) {
        NSArray* grp = [NamedGroups objectForKey:[groups objectAtIndex:[indexPath row]]];
        NSMutableArray* users = [[NSMutableArray alloc] init];
        for (NSString*phone in grp) {
            [users addObject:[Data findUserByPhone:phone]];
        }
        if ([users count] > 0)
            [self sendMessageTo:users];
    }
    else {
        section--;
        if (showRecentContacts) section--;
        
        NSArray* headings = [Data getContactHeadings];
        NSArray* cs = [Data getContactsForHeading:[headings objectAtIndex:section]];
        UserContact* contact = [cs objectAtIndex:[indexPath row]];

        NSArray* contactlist = [NSArray arrayWithObject:contact];
        [self sendMessageTo:contactlist];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* actChoose =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:@"Choose number"
                                     handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                                         NSArray* cs;
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
                                         if (cs != nil/* && [cs count] > 0*/)
                                             [self choosePhone:cs];
                                     }];
    return [NSArray arrayWithObjects:actChoose, nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(void)choosePhone:(NSArray*)users {
    CGRect frm = [[self view] frame];
    CGRect frmNav = [[[self navigationController] navigationBar] frame];
    CGFloat topmargin = frmNav.origin.y + frmNav.size.height;
    frm.origin.x += 8;
    frm.origin.y += frm.size.height;
    frm.size.width -= 16;
    frm.size.height -= 28;
    ChoosePhoneView* choosephone = [[ChoosePhoneView alloc] initWithFrame:frm];
    [choosephone setUsers:users];
    [choosephone setNavItem:[self navigationItem]];
    [[self view] addSubview:choosephone];

    CGRect frmDest = frm;
    frmDest.origin.y = topmargin + 8;
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
    
    [rightButton setEnabled:[checkedContacts count] > 0];
    
    [self syncSendButton];
}

-(IBAction)sendMessages:(id)sender {
    [self sendMessageTo:checkedContacts];
}

-(void)syncSendButton {
    [btnSend setHidden:[checkedContacts count] == 0];
}

-(void) sendMessageTo:(NSArray*) contactlist {
    if ([CurrentMessage msgId] > 0)
        [Settings AddRecentMessage:CurrentMessage];
    if (CurrentCategory != nil) {
        //Could be nil for Your Photos, Your Texts
        [RecentCategories setObject:[CurrentMessage description] forKey:CurrentCategory];
        [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
    }
    
    if([MFMessageComposeViewController canSendText])
    {
        [self updateMessageCount:[CurrentMessage msgId]];
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        for (UserContact*c in contactlist) {
            [phones addObject:[c getPhone]];
            [Settings AddRecentContact:[c getPhone]];
        }
        if (msgcontroller == nil)
            msgcontroller = [[MFMessageComposeViewController alloc] init];
        [msgcontroller setRecipients: phones];
        [msgcontroller setMessageComposeDelegate: self];
        
        NSString* urlAdd = ([CurrentMessage url] == nil ? @"" :
                            [NSString stringWithFormat:@" (%@)", [CurrentMessage url]]);
        NSString* text = ([CurrentMessage text] == nil ? @"" : [CurrentMessage text]);
        NSString* message = [NSString stringWithFormat:@"%@%@", text, urlAdd];
        //if (arc4random() % 10 == 0)
        message = [message stringByAppendingString:@"\n\nSent by TextMuse - http://www.textmuse.com/download"];
        if (([CurrentMessage mediaUrl] == nil || [[CurrentMessage mediaUrl] length] == 0) &&
            [CurrentMessage img] == nil)
            [msgcontroller setBody: message];
        else {
            if ([CurrentMessage isVideo])
                message = [NSString stringWithFormat:@"%@%@", text, urlAdd];
            [msgcontroller setBody:message];
            if ([CurrentMessage assetURL] != nil) {
                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:[CurrentMessage assetURL] resultBlock:^(ALAsset* asset) {
                    CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
                    NSData* d = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
                    [msgcontroller addAttachmentData:d
                                      typeIdentifier:(NSString*)kUTTypeImage
                                            filename:@"test.png"];
                } failureBlock:^(NSError*err) {}];
            }
            else if ([CurrentMessage img] != nil) {
                [msgcontroller addAttachmentData:[CurrentMessage img]
                                  typeIdentifier:(NSString*)kUTTypeImage
                                        filename:@"test.png"];
            }
            else {
                [msgcontroller addAttachmentData:[loader inetdata]
                                  typeIdentifier:(NSString*)kUTTypeImage
                                        filename:@"test.png"];
            }
        }
        
        [self presentViewController:msgcontroller animated:YES completion:^{ }];
    }
}

-(void)updateMessageCount:(int)msgId {
    NSURL* url = [NSURL URLWithString:urlUpdateNotes];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%d&app=%@", msgId, AppID]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result != MessageComposeResultSent) {
        if (result == MessageComposeResultFailed) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Send Failed Title", nil)
                                  message:NSLocalizedString(@"Send Failed Text", nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
        [msgcontroller dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [msgcontroller dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
                [[self navigationController] popToRootViewControllerAnimated:YES];
            });
        }];
    
    msgcontroller = nil;
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
