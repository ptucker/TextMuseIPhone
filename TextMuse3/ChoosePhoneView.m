//
//  ChoosePhoneView.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/3/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ChoosePhoneView.h"
#import "UserPhone.h"
@implementation ChoosePhoneView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    //Round the corners
    if ([self respondsToSelector:@selector(layer)]) {
        // Get layer for this view.
        CALayer *layer = [self layer];
        // Set border on layer.
        [layer setCornerRadius: 10];
        [layer setMasksToBounds: YES];
        [layer setBorderWidth:0.5];
    }
    
    [self setBackgroundColor:[UIColor whiteColor]];

    CGRect frmLbl = CGRectMake(0, 0, frame.size.width, 22);
    UILabel* lbl = [[UILabel alloc] initWithFrame:frmLbl];
    CGRect frmTable = CGRectMake(0, 30, frame.size.width, frame.size.height-30);
    UITableView* tableview = [[UITableView alloc] initWithFrame:frmTable];
    
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setText:@"Choose phone"];
    [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
    
    CGRect frmClose = CGRectMake(8, 0, 28, 28); // frmLbl;
    //frmClose.origin.x = 8;
    //frmClose.size.width = 22;
    UIButton* btnClose = [[UIButton alloc] initWithFrame:frmClose];
    [btnClose setTitle:@"X" forState:UIControlStateNormal];
    [[btnClose titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:24]];
    [btnClose setTitleColor:[UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0]
                   forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:btnClose];
    [tableview setDataSource:self];
    [tableview setDelegate:self];
    
    [self addSubview:lbl];
    [self addSubview:tableview];
    
    return self;
}

-(IBAction)close:(id)sender {
    if ([self navItem] != nil)
        [[self navItem] setHidesBackButton:NO animated:YES];
    CGRect frmDest = [self frame];
    frmDest.origin.y = [[self superview] frame].size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{ [self setFrame:frmDest]; }
                     completion:^(BOOL f) { [self removeFromSuperview]; } ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self users] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self users] objectAtIndex:section] description];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UserContact* uc = [[self users] objectAtIndex:section];
    return [[uc phones] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"member"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] init];
    
    UILabel* lblName = (UILabel*)[cell viewWithTag:101];
    if (lblName == nil) {
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(36, 2,
                                                            [cell frame].size.width - 44,
                                                            [cell frame].size.height - 4)];
        [lblName setTag:101];
        [cell addSubview:lblName];
    }
    
    UserContact* uc = [[self users] objectAtIndex:[indexPath section]];
    NSString* chosen = [uc numberToUse];
    UserPhone* p = [[uc phones] objectAtIndex:[indexPath row]];
    NSString* phone = [NSString stringWithFormat:@"%@: %@",
                       [p label],
                       [p number]];
    [lblName setText:phone];
    [lblName setFont:[chosen isEqualToString:[p number]] ?
     [UIFont fontWithName:@"Lato-Regular" size:18] :
     [UIFont fontWithName:@"Lato-Light" size:18]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserContact* uc = [[self users] objectAtIndex:[indexPath section]];
    UserPhone* p = [[uc phones] objectAtIndex:[indexPath row]];
    [uc setPhoneToUse:[p number]];
    
    [tableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
