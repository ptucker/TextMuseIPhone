//
//  MemberTableData.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/30/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "MemberTableData.h"

@implementation MemberTableData

-(id)init {
    [self setAdds:[[NSMutableArray alloc] init]];
    [self setRemoves:[[NSMutableArray alloc] init]];
    
    return self;
}

-(void)sortContacts {
    NSArray* cs = [Data getContacts];
    NSArray* grpContacts = [NamedGroups objectForKey:CurrentGroup];
    contactsSorted = [cs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UserContact* uc1 = (UserContact*)obj1;
        UserContact* uc2 = (UserContact*)obj2;
        BOOL contact1InGroup = false, contact2InGroup = false;
        for (int i=0; i<[grpContacts count]; i++) {
            if ([uc1 hasPhone:[grpContacts objectAtIndex:i]])
                contact1InGroup = true;
            if ([uc2 hasPhone:[grpContacts objectAtIndex:i]])
                contact2InGroup = true;
        }
        
        if (contact1InGroup && !contact2InGroup) return NSOrderedAscending;
        else if (contact2InGroup && !contact1InGroup) return NSOrderedDescending;
        else {
            if (SortLastName) {
                if (![[uc1 lastName] isEqualToString:[uc2 lastName]])
                    return [[uc1 lastName] compare:[uc2 lastName]];
                else
                    return [[uc1 firstName] compare:[uc2 firstName]];
            }
            else {
                if (![[uc1 firstName] isEqualToString:[uc2 firstName]])
                    return [[uc1 firstName] compare:[uc2 firstName]];
                else
                    return [[uc1 lastName] compare:[uc2 lastName]];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self sortContacts];
    return [contactsSorted count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"member"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] init];
    
    UIButton* btnCheck = (UIButton*)[cell viewWithTag:100];
    if (btnCheck == nil) {
        btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 24, 24)];
        [btnCheck setTag:100];
        [btnCheck setImage:[UIImage imageNamed:@"bluecheck.png"] forState:UIControlStateSelected];
        [btnCheck setImage:[UIImage imageNamed:@"emptycheck.png"] forState:UIControlStateNormal];
        [btnCheck addTarget:self
                     action:@selector(checkMember:)
           forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnCheck];
    }
    UserContact* uc = [contactsSorted objectAtIndex:[indexPath row]];
    NSArray* group = [NamedGroups objectForKey:CurrentGroup];
    BOOL selected = ([group containsObject:[uc numberToUse]] &&
                        ![[self removes] containsObject:[uc numberToUse]])
                    || [[self adds] containsObject:[uc numberToUse]];
    [btnCheck setSelected:selected];
    
    UILabel* lblName = (UILabel*)[cell viewWithTag:101];
    if (lblName == nil) {
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(36, 2, [cell frame].size.width - 44, 28)];
        [lblName setTag:101];
        [lblName setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [cell addSubview:lblName];
    }
    [lblName setText:[uc description]];

    UILabel* lblPhone = (UILabel*)[cell viewWithTag:102];
    if (lblPhone == nil) {
        lblPhone = [[UILabel alloc] init];
        [lblPhone setTag:102];
        [lblPhone setHidden:YES];
        [cell addSubview:lblPhone];
    }
    [lblPhone setText:[[[uc phones] objectAtIndex:0] number]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [Data getContactHeadings];
}
*/

-(IBAction)checkMember:(id)sender {
    UIButton* btn=(UIButton*)sender;
    [btn setSelected:![btn isSelected]];
    NSArray* group = [NamedGroups objectForKey:CurrentGroup];
    
    UILabel* lbl = (UILabel*)[[btn superview] viewWithTag:102];
    if ([btn isSelected]) {
        if (![group containsObject:[lbl text]] && ![[self adds] containsObject:[lbl text]])
            [[self adds] addObject:[lbl text]];
        if ([[self removes] containsObject:[lbl text]])
            [[self removes] removeObject:[lbl text]];
    }
    else if (![btn isSelected]) {
        if ([group containsObject:[lbl text]] && ![[self removes] containsObject:[lbl text]])
            [[self removes] addObject:[lbl text]];
        if ([[self adds] containsObject:[lbl text]])
            [[self adds] removeObject:[lbl text]];
    }
}

@end
