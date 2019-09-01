//
//  TextMessageView.m
//  TextMuse
//
//  Created by Peter Tucker on 6/2/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import "TextMessageView.h"
#import "ImageUtil.h"
#import "TextUtil.h"
#import "GlobalState.h"
#import "Settings.h"
#import "FLAnimatedImage.h"
#import "UICaptionButton.h"

@implementation TextMessageView

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i {
    if (bubble1 == nil) {
        bubble1 = [UIImage imageNamed:@"largegreenbubble"];
        if (Skin != nil)
            bubble1 = [bubble1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if (bubble2 == nil) {
        bubble2 = [UIImage imageNamed:@"largeorangebubble"];
        if (Skin != nil)
            bubble2 = [bubble2 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if (bubble3 == nil) {
        bubble3 = [UIImage imageNamed:@"largebluebubble"];
        if (Skin != nil)
            bubble3 = [bubble3 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if (leftQuote == nil)
        leftQuote = [UIImage imageNamed:@"blackleftquote"];
    if (rightQuote == nil)
        rightQuote = [UIImage imageNamed:@"blackrightquote"];
    if (likeRed == nil)
        likeRed = [UIImage imageNamed:@"heart_red"];
    if (likeGrey == nil)
        likeGrey = [UIImage imageNamed:@"heart_dkgrey"];
    if (pinRed == nil)
        pinRed = [UIImage imageNamed:@"pin_red"];
    if (pinGrey == nil)
        pinGrey = [UIImage imageNamed:@"pin_dkgrey"];
    if (openInNew == nil)
        openInNew = [UIImage imageNamed:@"open-in-new"];
    
    message = msg;
    
    //[self setFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    CGFloat fontSize = 20.0;
    if (frame.size.height < 350)
        fontSize -= 4;
    UIFont* fontText = [TextUtil GetBoldFontForSize:fontSize];
    CGSize sizeContent = CGSizeMake(frame.size.width-132, frame.size.height/2);
    sizeContent = [TextUtil GetContentSizeForText:[msg text] inSize:sizeContent forFont:fontText];
    CGSize sizeBubble = CGSizeMake(7*frame.size.width/8, frame.size.height/2);
    sizeBubble = [ImageUtil GetContentSizeForImage:bubble1 inSize:sizeBubble forCell:NO];
    
    CGFloat quoteTop = frame.size.height/6;
    CGRect frmHeader = CGRectMake(10, 10, frame.size.width-20, 40);
    CGRect frmLeftQuote = CGRectMake(14, quoteTop, 44, 44);
    CGRect frmRightQuote = CGRectMake(frame.size.width - 58, quoteTop, 44, 44);
    CGRect frmBubble = CGRectMake(frame.size.width/8, 70,
                                  sizeBubble.width, sizeBubble.height);
    CGRect frmLblContent = CGRectMake(66, quoteTop, frmRightQuote.origin.x - 66, sizeContent.height);
    imgBubble = [[UIImageView alloc] initWithFrame:frmBubble];
    switch (i) {
        case 0:
            [imgBubble setImage:bubble1];
            if (Skin != nil)
                [imgBubble setTintColor:[Skin createColor1]];
            break;
        case 1:
            [imgBubble setImage:bubble2];
            if (Skin != nil)
                [imgBubble setTintColor:[Skin createColor2]];
            break;
        case 2:
            [imgBubble setImage:bubble3];
            if (Skin != nil)
                [imgBubble setTintColor:[Skin createColor3]];
            break;
    }
    [self addSubview:imgBubble];

    NSString* txt = [msg getFullMessage];
    imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeftQuote];
    [imgLeftQuote setImage:leftQuote];
    imgRightQuote = [[UIImageView alloc] initWithFrame:frmRightQuote];
    [imgRightQuote setImage:rightQuote];
    
    lblContent = [[UILabel alloc] initWithFrame:frmLblContent];
    [lblContent setText:txt];
    [lblContent setTextAlignment:NSTextAlignmentCenter];
    [lblContent setFont:fontText];
    [lblContent setTextColor:[UIColor blackColor]];
    [lblContent setNumberOfLines:0];
    [lblContent sizeToFit];
    
    [self addSubview:imgLeftQuote];
    [self addSubview:imgRightQuote];
    [self addSubview:lblContent];
    
    UIView* viewHeader = [[UIView alloc] initWithFrame:frmHeader];
    [self setHeaderForMessage:msg inView:viewHeader];
    [self addSubview:viewHeader];
    
    CGFloat heightDetails = [self getHeightForMessageDetails:msg inFrame:frame];
    CGRect frmButtons = CGRectMake(0, [self frame].size.height - heightDetails - 12,
                                   [self frame].size.width, heightDetails);
    UIView* viewButtons = [[UIView alloc] initWithFrame:frmButtons];
    [self setDetailsForMessage:msg inView:viewButtons];
    
    [self addSubview:viewButtons];
}

@end
