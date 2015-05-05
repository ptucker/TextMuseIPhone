//
//  AddMemberView.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/30/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "AddMemberView.h"
#import "GlobalState.h"
#import "MemberTableData.h"

@implementation AddMemberView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    //Round the corners
    if ([self respondsToSelector:@selector(layer)]) {
        // Get layer for this view.
        CALayer *layer = [self layer];
        // Set border on layer.
        [layer setCornerRadius: 10];
        [layer setMasksToBounds: YES];
        [layer setBorderWidth:0.5];
    }
    
    CGRect frmLbl = frame;
    frmLbl.origin.y = 10;
    frmLbl.size.height = 22;
    UILabel* lbl = [[UILabel alloc] initWithFrame:frmLbl];
    [lbl setText:@"Edit membership"];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:22]];
    [self addSubview:lbl];
    
    CGRect frmClose = frmLbl;
    frmClose.origin.x = 8;
    frmClose.size.width = 22;
    UIButton* btnClose = [[UIButton alloc] initWithFrame:frmClose];
    [btnClose setTitle:@"X" forState:UIControlStateNormal];
    [[btnClose titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
    [btnClose setTitleColor:[UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0]
                   forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];

    CGRect frmDone = frmLbl;
    frmDone.origin.x = frame.size.width - 72;
    frmDone.size.width = 60;
    UIButton* btnDone = [[UIButton alloc] initWithFrame:frmDone];
    [btnDone setTitle:@"Save" forState:UIControlStateNormal];
    [[btnDone titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
    [btnDone setTitleColor:[UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0]
                  forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(saveData:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDone];

    CGRect frmTable = frmLbl;
    frmTable.origin.y = frmLbl.origin.y + frmLbl.size.height + 4;
    frmTable.size.height = [self frame].size.height - frmTable.origin.y;
    UITableView* tableView = [[UITableView alloc] initWithFrame:frmTable];
    memberdata = [[MemberTableData alloc] init];
    [tableView setDelegate:memberdata];
    [tableView setDataSource:memberdata];
    [self addSubview:tableView];

    return self;
}

-(IBAction)saveData:(id)sender {
    NSArray* group = [NamedGroups objectForKey:CurrentGroup];

    for (NSString*c in [memberdata adds]) {
        if (![group containsObject:c])
            [Settings AddContact:c forGroup:CurrentGroup];
    }
    for (NSString*c in [memberdata removes]) {
        if ([group containsObject:c])
            [Settings RemoveContact:c fromGroup:CurrentGroup];
    }
    
    [[self sourceTable] reloadData];
}

-(IBAction)close:(id)sender {
    CGRect frmDest = [self frame];
    frmDest.origin.y = [[self superview] frame].size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{ [self setFrame:frmDest]; }
                     completion:^(BOOL f) { [self removeFromSuperview]; } ];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
