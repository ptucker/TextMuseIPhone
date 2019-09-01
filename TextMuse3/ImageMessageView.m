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
    
    CGFloat heightDetails = [self getHeightForMessageDetails:msg inFrame:frame];
    
    //[self setFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    CGFloat fontSize = 18.0;
    if (frame.size.height < 350)
        fontSize -= 6;
    NSString* txt = [msg getFullMessage];
    UIFont* fontText = [TextUtil GetBoldFontForSize:fontSize];
    CGSize sizeText = CGSizeMake(frame.size.width-88, frame.size.height - 80);
    sizeText.height = [TextUtil GetContentSizeForText:txt inSize:sizeText forFont:fontText].height;

    CGFloat textTop = frame.size.height - heightDetails - 24 - sizeText.height;
    
    CGRect frmHeader = CGRectMake(10, 10, frame.size.width-20, 40);
    CGRect frmImg = frame;
    frmImg.origin.y = frmHeader.origin.y + frmHeader.size.height + 12;
    frmImg.size.height -= (frmImg.origin.y + heightDetails + sizeText.height);
    if (frmImg.size.height > frame.size.height * 0.6)
        frmImg.size.height = frame.size.height * 0.6;
    frmImg = [self setupImageForMessage:msg inFrame:frmImg];

    //Now that the image is set, let's move the text to right below the image
    textTop = frmImg.origin.y + frmImg.size.height + 8;
    CGRect frmLeftQuote = CGRectMake(14, textTop, 24, 24);
    CGRect frmRightQuote = CGRectMake(frame.size.width - 42, textTop, 24, 24);
    CGRect frmLblContent = CGRectMake(44, textTop, frmRightQuote.origin.x - 64, sizeText.height);

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
        [tvContent setFont:[TextUtil GetDefaultFontForSize:fontSize]];
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
        [lblContent setTextAlignment:NSTextAlignmentCenter];
        [lblContent setNumberOfLines:0];
        [lblContent sizeToFit];
        
        [self addSubview:imgLeftQuote];
        [self addSubview:imgRightQuote];
        [self addSubview:lblContent];
    }
    
    UIView* viewHeader = [[UIView alloc] initWithFrame:frmHeader];
    [self setHeaderForMessage:msg inView:viewHeader];
    [self addSubview:viewHeader];

    /*
    CGRect frmButtons = CGRectMake(0, buttonsTop, [self frame].size.width,
                                   [self frame].size.height - buttonsTop);
     */
    CGRect frmButtons = CGRectMake(0, [self frame].size.height - heightDetails - 12,
                                   [self frame].size.width, heightDetails);
    UIView* viewButtons = [[UIView alloc] initWithFrame:frmButtons];
    [self setDetailsForMessage:msg inView:viewButtons];
    
    [self addSubview:viewButtons];
}

-(CGRect)setupImageForMessage:(Message*)msg inFrame:(CGRect)frame {
    BOOL gif = [[msg imgType] isEqualToString:@"image/gif"];
    
    CGRect frmImg = CGRectMake(5, 5, frame.size.width-10, frame.size.height-10);
    UIImageView* iview = [[UIImageView alloc] init];
    if (!gif) {
        UIImage* img = [UIImage imageWithData:[msg img]];
        frmImg.size.height = [ImageUtil GetContentSizeForImage:img inSize:frmImg.size forCell:NO].height;
        [iview setFrame:frmImg];
        [iview setImage:img];
    }
    else {
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[msg img]];
        frmImg.size.height = [ImageUtil GetContentSizeForImage:(UIImage*)image inSize:frmImg.size forCell:NO].height;
        [imageView setFrame:frmImg];
        [imageView setAnimatedImage: image];
        BOOL running = [imageView isAnimating];
        if (!running) {
            [imageView startAnimating];
        }
        iview = imageView;
    }
    [iview setContentMode:UIViewContentModeScaleAspectFit];
    
    CGRect frmButton = frmImg;
    frmButton.origin = frame.origin;
    imgContent = [[UIButton alloc] initWithFrame:frmButton];
    [imgContent addSubview:iview];
    [imgContent setBackgroundColor:[UIColor clearColor]];
    [self addSubview:imgContent];
    
    [imgContent addTarget:msg action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    
    return frmButton;
}

@end
