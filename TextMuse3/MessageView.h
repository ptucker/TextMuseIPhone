//
//  MessageView.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "UICaptionButton.h"

@interface MessageView : UIView<UITextViewDelegate> {
    UIImageView* imgLeftQuote;
    UIImageView* imgRightQuote;
    UIImageView* imgBubble;
    UIButton* imgContent;
    UILabel* lblContent;
    UITextView* tvContent;
    UICaptionButton* btnLike;
    UICaptionButton* btnPin;
    UIButton* btnDetails;
    
    Message* message;
}

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i;

@end
