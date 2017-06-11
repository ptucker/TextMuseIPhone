//
//  MessageView.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "SendMessage.h"
#import "UICaptionButton.h"
#import "FLAnimatedImage.h"

@interface MessageView : UIView<UITextViewDelegate> {
    UIImageView* imgLeftQuote;
    UIImageView* imgRightQuote;
    UIImageView* imgBubble;
    UIButton* imgContent;
    UILabel* lblContent;
    UITextView* tvContent;
    //UICaptionButton* btnLike;
    //UICaptionButton* btnPin;
    UIButton* btnDetails;
    UIButton* btnText;
    UIButton* btnFollow;
    
    Message* message;
}

@property (readwrite) id objSendMessage;
@property (readwrite) SEL selSendMessage;
@property (readwrite) bool showBadges;
@property (readwrite) bool isFullScreen;

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i;

//-(void)setLikeButtonForMessage:(Message*)msg inView:(UIView*)subview;
//-(void)setPinButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setTextItButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setSeeItButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setFollowButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setDetailsTextForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setDetailsForMessage:(Message*)msg inView:(UIView*)subview;

-(IBAction)close:(id)sender;

+(MessageView*)setupViewForMessage:(Message*)msg
                           inFrame:(CGRect)frame
                        withBadges:(bool) b
                        fullScreen:(bool)f
                         withColor:(UIColor*)color
                             index:(long)i;

+(MessageView*)setupViewForMessage:(Message*)msg
                        withBadges:(bool) b
                        fullScreen:(bool)f
                           inFrame:(CGRect)frame;

@end

extern UIImage* bubble1;
extern UIImage* bubble2;
extern UIImage* bubble3;
extern UIImage* leftQuote;
extern UIImage* rightQuote;
extern UIImage* likeRed;
extern UIImage* likeGrey;
extern UIImage* pinRed;
extern UIImage* pinGrey;
extern UIImage* openInNew;
