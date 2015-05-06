//
//  ChoosePhoneView.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/3/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserContact.h"

@interface ChoosePhoneView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (retain) NSArray* users;
@property (retain) UINavigationItem* navItem;

@end
