//
//  ShowGroupViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/28/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ShowGroupViewController.h"
#import "GlobalState.h"
#import "Settings.h"
#import "AddMemberView.h"
#import "ContactsTableViewController.h"

@interface ShowGroupViewController ()

@end

@implementation ShowGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self navigationItem] setTitle:CurrentGroup];

    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(addMembers:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];
    
    [tableview setDelegate:self];
    [tableview setDataSource:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(nullable id)sender {
    if ([[segue identifier] isEqualToString:@"FindMembers"])
    {
        ContactsTableViewController* cvc = [segue destinationViewController];
        [cvc setGroupName:CurrentGroup];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NamedGroups objectForKey:CurrentGroup] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"member"
                                                            forIndexPath:indexPath];
    
    UILabel* lbl = (UILabel*)[cell viewWithTag:100];
    NSArray* group = [NamedGroups objectForKey:CurrentGroup];
    UserContact*uc = [Data findUserByPhone:[group objectAtIndex:[indexPath row]]];
    [lbl setText:[uc description]];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray* group = [NSMutableArray arrayWithArray:[NamedGroups objectForKey:CurrentGroup]];
    UITableViewRowAction* actDelete =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:@"Remove"
                                     handler:^(UITableViewRowAction* action, NSIndexPath* indexPath) {
                                         NSString* user = [group objectAtIndex:[indexPath row]];
                                         [Settings RemoveContact:user fromGroup:CurrentGroup];
                                         [tableView reloadData];
                                     }];
    return [NSArray arrayWithObjects:actDelete, nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(IBAction)addMembers:(id)sender {
    [self performSegueWithIdentifier:@"FindMembers" sender:self];

    /*
    CGRect frm = [[self view] frame];
    CGRect frmNav = [[[self navigationController] navigationBar] frame];
    frm.origin.y = frm.size.height;
    frm.origin.y += 8; frm.origin.x += 8;
    frm.size.height -= 16; frm.size.width -= 16;
    CGFloat topmargin = frmNav.origin.y + frmNav.size.height;
    frm.size.height -= topmargin;
    AddMemberView* add = [[AddMemberView alloc] initWithFrame: frm];
    [add setSourceTable:tableview];
    [add setNavItem:[self navigationItem]];
    
    [[self view] addSubview:add];
    CGRect frmDest = frm;
    frmDest.origin.y = topmargin + 8;
    [UIView animateWithDuration:0.3f animations:^{
        [add setFrame:frmDest];
    }];

    [[self navigationItem] setHidesBackButton:YES animated:YES];
     */
}

@end
