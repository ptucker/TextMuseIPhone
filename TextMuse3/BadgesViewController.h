//
//  BadgesViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 7/29/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    long selectedRow;
    
    IBOutlet UITableView* tableview;
}

@end
