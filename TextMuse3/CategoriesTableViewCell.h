//
//  CategoriesTableViewCell.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface CategoriesTableViewCell : UITableViewCell {
    Message* message;
}

@property (retain, atomic) UILabel* lblTitle;
@property (retain, atomic) UILabel* lblNew;
@property (retain, atomic) UIButton* btnSeeAll;
@property (retain, atomic) UIView* viewContent;
@property (retain, atomic) UIImageView* imgContent;
@property (retain, atomic) UILabel* lblContent;
@property (retain, atomic) UIImageView* imgLeftQuote;
@property (retain, atomic) UIImageView* imgRightQuote;
@property (retain, atomic) UIImageView* imgBubble;

-(void)showForWidth:(CGFloat)width
          withColor:(UIColor*)color
          title:(NSString*)title
           newCount:(int)cnt
            message:(Message*)msg;

@end
