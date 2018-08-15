//
//  ImageMessageView.m
//  TextMuse
//
//  Created by Peter Tucker on 6/2/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import "ImageMessageView.h"
#import "ImageUtil.h"
#import "TextUtil.h"
#import "GlobalState.h"
#import "Settings.h"
#import "FLAnimatedImage.h"
#import "UICaptionButton.h"

@implementation ImageMessageView

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
    CGFloat fontSize = 18.0;
    if (frame.size.height < 350)
        fontSize -= 6;
    UIFont* fontText = [UIFont fontWithName:@"Lato-Medium" size:fontSize];
    CGSize sizeText = CGSizeMake(frame.size.width-88, frame.size.height - 80);
    sizeText = [TextUtil GetContentSizeForText:[msg text] inSize:sizeText forFont:fontText];
    CGRect frmHeader = CGRectMake(10, 10, frame.size.width-20, 40);
    CGRect frmImage = [self setupImageForMessage:msg inFrame:frame];
    
    CGFloat textTop = frmImage.origin.y + frmImage.size.height + 8;
    CGRect frmLeftQuote = CGRectMake(14, textTop, 24, 24);
    CGRect frmRightQuote = CGRectMake(frame.size.width - 42, textTop, 24, 24);
    CGRect frmLblContent = CGRectMake(44, textTop, sizeText.width, sizeText.height);
    
    if (frame.size.height < 350)
        fontSize -= 4;
    
    NSString* txt = [msg getFullMessage];
    if ([[msg mediaUrl] isEqualToString:@"usertext://"]) {
        imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeftQuote];
        [imgLeftQuote setImage:leftQuote];
        imgRightQuote = [[UIImageView alloc] initWithFrame:frmRightQuote];
        [imgRightQuote setImage:rightQuote];
        
        tvContent = [[UITextView alloc] initWithFrame:frmLblContent];
        //Round the corners
        if ([tvContent respondsToSelector:@selector(layer)]) {
            // Get layer for this view.
            CALayer *layer = [tvContent layer];
            // Set border on layer.
            [layer setCornerRadius: 10];
            [layer setMasksToBounds: YES];
        }
        [tvContent setDelegate:self];
        [tvContent setAlpha:0.60];
        if (txt != nil && [txt length] > 0)
            [tvContent setText:txt];
        else {
            tvContent.text = @"Add your message...";
            tvContent.textColor = [UIColor lightGrayColor]; //optional
        }
        [tvContent setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
        [tvContent setTextColor:[UIColor blackColor]];
        [self addSubview:imgLeftQuote];
        [self addSubview:imgRightQuote];
        [self addSubview:tvContent];
    }
    else if (txt != nil && [txt length] > 0) {
        imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeftQuote];
        [imgLeftQuote setImage:leftQuote];
        imgRightQuote = [[UIImageView alloc] initWithFrame:frmRightQuote];
        [imgRightQuote setImage:rightQuote];
        
        lblContent = [[UILabel alloc] initWithFrame:frmLblContent];
        [lblContent setText:txt];
        [lblContent setFont:fontText];
        [lblContent setTextColor:[UIColor blackColor]];
        [lblContent setNumberOfLines:0];
        [lblContent sizeToFit];
        
        [self addSubview:imgLeftQuote];
        [self addSubview:imgRightQuote];
        [self addSubview:lblContent];
    }
    
    //[self setLikeButtonForMessage:msg inFrame:frmLike];
    //[self setPinButtonForMessage:msg inFrame:frmPin];
    CGFloat buttonsTop = frmLblContent.origin.y + frmLblContent.size.height + 8;
    if (([msg phoneno] != nil && [[msg phoneno] length] > 0) ||
        ([msg textno] != nil && [[msg textno] length] > 0)) {
        CGRect frmButtons = CGRectMake(0, buttonsTop, [self frame].size.width, 40);
        UIView* viewButtons = [[UIView alloc] initWithFrame:frmButtons];
        [self setContactsForMessage:msg inView:viewButtons];
        
        [self addSubview:viewButtons];
        
        buttonsTop += frmButtons.size.height;
    }
    
    UIView* viewHeader = [[UIView alloc] initWithFrame:frmHeader];
    [self setHeaderForMessage:msg inView:viewHeader];
    [self addSubview:viewHeader];

    /*
    CGRect frmButtons = CGRectMake(0, buttonsTop, [self frame].size.width,
                                   [self frame].size.height - buttonsTop);
     */
    CGRect frmButtons = CGRectMake(0, [self frame].size.height - 48,
                                   [self frame].size.width, 40);
    UIView* viewButtons = [[UIView alloc] initWithFrame:frmButtons];
    [self setDetailsForMessage:msg inView:viewButtons];
    
    [self addSubview:viewButtons];
}

-(CGRect)setupImageForMessage:(Message*)msg inFrame:(CGRect)frame {
    CGRect frmImgContent = CGRectMake(14, 84, frame.size.width-28, frame.size.height / 2);
    BOOL gif = [[msg imgType] isEqualToString:@"image/gif"];
    
    CGRect frmImg = CGRectMake(0, 0, frmImgContent.size.width, frmImgContent.size.height);
    UIImageView* iview = [[UIImageView alloc] initWithFrame:frmImg];
    if (!gif) {
        UIImage* img = [UIImage imageWithData:[msg img]];
        [iview setImage:img];
    }
    else {
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        [imageView setFrame:frmImg];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[msg img]];
        [imageView setAnimatedImage: image];
        BOOL running = [imageView isAnimating];
        if (!running) {
            [imageView startAnimating];
        }
        iview = imageView;
    }
    [iview setContentMode:UIViewContentModeScaleAspectFit];
    
    imgContent = [[UIButton alloc] initWithFrame:frmImgContent];
    [imgContent addSubview:iview];
    [imgContent setBackgroundColor:[UIColor clearColor]];
    [self addSubview:imgContent];
    
    [imgContent addTarget:msg action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    
    return frmImgContent;
}

@end
