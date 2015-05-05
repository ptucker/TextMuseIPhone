//
//  GroupsViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 4/28/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* tableview;
    UIBarButtonItem* rightButton;
    
    NSMutableArray* groups;
}

@end
