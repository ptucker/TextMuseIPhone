//
//  BadgesViewController.m
//  TextMuse
//
//  Created by Peter Tucker on 7/29/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "BadgesViewController.h"
#import "Settings.h"
#import "BadgeTreeTableViewCell.h"

@interface BadgesViewController ()

@end

@implementation BadgesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedRow = -1;
    
    [tableview setDelegate:self];
    [tableview setDataSource:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [indexPath row] == selectedRow ? 180 : 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgeTreeTableViewCell* cell = nil;
    
    CGRect frm = CGRectMake(0, 0, [[self view] frame].size.width, 40);
    switch ([indexPath row]) {
        case 0: cell = [[BadgeTreeTableViewCell alloc] initWithFrame:frm forBadge:Explorer];
            break;
        case 1: cell = [[BadgeTreeTableViewCell alloc] initWithFrame:frm forBadge:Sharer];
            break;
        case 2: cell = [[BadgeTreeTableViewCell alloc] initWithFrame:frm forBadge:Muse];
            break;
        case 3: cell = [[BadgeTreeTableViewCell alloc] initWithFrame:frm forBadge:Master];
            break;
    }
    
    [[cell descLabel] setHidden:(selectedRow != [indexPath row])];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow = (selectedRow == [indexPath row]) ? -1 : [indexPath row];
    [tableview reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
