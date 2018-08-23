//
//  GroupsViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/28/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "GroupsViewController.h"
#import "Settings.h"
#import "GlobalState.h"

@interface GroupsViewController ()

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadGroups];
    
    [tableview setDelegate:self];
    [tableview setDataSource:self];
    [tableview reloadData];

    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(sendMessages:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"group"
                                                            forIndexPath:indexPath];
    NSString* groupName = [groups objectAtIndex:[indexPath row]];
    UILabel* lblName = (UILabel*)[cell viewWithTag:100];
    [lblName setText:groupName];
    UILabel* lblCount = (UILabel*)[cell viewWithTag:101];
    NSArray* group = [NamedGroups objectForKey:groupName];
    [lblCount setText:[NSString stringWithFormat:@"%lu members", (unsigned long)[group count]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentGroup = [groups objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"ShowGroup" sender:self];
}

-(void)loadGroups {
    if ([NamedGroups count] > 0) {
        NSMutableArray* gs = [[NSMutableArray alloc] init];
        for (NSString* k in [NamedGroups keyEnumerator]) {
            [gs addObject:k];
        }
        groups = [NSMutableArray arrayWithArray:
                  [gs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* actDelete =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:@"Remove"
                                         handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                                             NSString* grp = [self->groups objectAtIndex:[indexPath row]];
                                             [self->groups removeObject:grp];
                                             [Settings RemoveGroup:grp];
                                             [self->tableview reloadData];
                                          }];
    UITableViewRowAction* actRename =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:@"Rename"
                                     handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                                         UIAlertView * alert =
                                         [[UIAlertView alloc] initWithTitle:@"Rename Group"
                                                                    message:@"Enter a new group name"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Save", nil];
                                         alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                         CurrentGroup = [self->groups objectAtIndex:[indexPath row]];
                                         [alert setTag:2];
                                         [alert show];
                                     }];
    [actRename setBackgroundColor:[UIColor grayColor]];
    return [NSArray arrayWithObjects:actDelete, actRename, nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(IBAction)sendMessages:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Group"
                                                     message:@"Enter a name for this group"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:1];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* grp = [[alertView textFieldAtIndex:0] text];
    if (grp == nil || [grp length] == 0) return;
    
    if ([alertView tag] == 1) {
        if (buttonIndex == 1 && [NamedGroups objectForKey:grp] == nil) {
            [Settings AddGroup:grp withContacts:nil];
            [self loadGroups];
            [tableview reloadData];
        }
    }
    else if ([alertView tag] == 2) {
        if (buttonIndex == 1) {
            NSArray* gs = [NamedGroups objectForKey:CurrentGroup];
            [Settings RemoveGroup:CurrentGroup];
            NSMutableArray* ucs = [[NSMutableArray alloc] init];
            for (NSString*p in gs) {
                [ucs addObject:[Data findUserByPhone:p]];
            }
            [Settings AddGroup:grp withContacts:ucs];
            [self loadGroups];
            [tableview reloadData];
        }
        CurrentGroup = nil;
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

@end
