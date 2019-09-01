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
//#import "MessagesViewController.h"

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
    UIButton* btnTextContact;
    
    CGFloat bottom;
    
    UISwipeGestureRecognizer* swipe;
    
    Message* message;
    
    NSArray* phones;
}

@property (readwrite) bool showBadges;
@property (readwrite) bool isFullScreen;
@property (readonly) NSArray* phones;

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i;
-(void)setTarget:(UIViewController*)vc withSelector:(SEL) sel andQuickSend:(SEL)selQuick;

-(int)getHeightForMessageDetails:(Message*) msg inFrame:(CGRect)frame;

//-(void)setLikeButtonForMessage:(Message*)msg inView:(UIView*)subview;
//-(void)setPinButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setTextItButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setSeeItButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setFollowButtonForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setDetailsTextForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setDetailsForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setPhoneContactForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setTextContactForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setContactsForMessage:(Message*)msg inView:(UIView*)subview;
-(void)setHeaderForMessage:(Message*)msg inView:(UIView*)subview;
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
