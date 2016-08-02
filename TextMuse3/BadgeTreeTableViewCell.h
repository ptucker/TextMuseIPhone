//
//  BadgeTreeTableViewCell.h
//  TextMuse
//
//  Created by Peter Tucker on 7/29/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum { Explorer, Sharer, Muse, Master } BadgeEnum;

@interface BadgeTreeTableViewCell : UITableViewCell {
    UILabel* titleLabel;
    UILabel* descLabel;
    UIImageView* badgeView;
    UILabel* description;
}

@property BOOL Selected;
@property UILabel* descLabel;

-(id)initWithFrame:(CGRect)frame forBadge:(BadgeEnum)badgetype;

@end
