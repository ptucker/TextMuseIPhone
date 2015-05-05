//
//  AddMemberView.h
//  TextMuse3
//
//  Created by Peter Tucker on 4/30/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberTableData.h"

@interface AddMemberView : UIView {
    MemberTableData* memberdata;
}

@property (retain) UITableView* sourceTable;

@end
