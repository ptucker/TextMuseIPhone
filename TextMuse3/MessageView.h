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
#import "FLAnimatedImage.h"

@interface MessageView : UIView<UITextViewDelegate> {
    UIImageView* imgLeftQuote;
    UIImageView* imgRightQuote;
    UIImageView* imgBubble;
    UIButton* imgContent;
    UILabel* lblContent;
    UITextView* tvContent;
    UICaptionButton* btnLike;
    UICaptionButton* btnPin;
    UICaptionButton* btnDetails;
    
    Message* message;
}

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i;
-(void)setupImageForMessage:(Message*)msg inFrame:(CGRect)frame;

@end
