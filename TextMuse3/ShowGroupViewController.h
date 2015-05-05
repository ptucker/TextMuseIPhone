//
//  ShowGroupViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 4/28/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowGroupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView* tableview;
}

@end
