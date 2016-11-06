//
//  MessageView.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "MessageView.h"
#import "ImageUtil.h"
#import "GlobalState.h"
#import "Settings.h"
#import "FLAnimatedImage.h"

@implementation MessageView

UIImage* bubble1 = nil;
UIImage* bubble2 = nil;
UIImage* bubble3 = nil;
UIImage* leftQuote = nil;
UIImage* rightQuote = nil;
UIImage* likeRed = nil;
UIImage* likeGrey = nil;
UIImage* pinRed = nil;
UIImage* pinGrey = nil;
UIImage* openInNew = nil;

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
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect frmLeftQuote = CGRectMake(14, frame.size.height/8, 44, 44);
    CGRect frmRightQuote = CGRectMake(frame.size.width - 58,
                                      frame.size.height/8, 44, 44);
    CGRect frmBubble = CGRectMake(frame.size.width/8, 0,
                                  7*frame.size.width/8, frame.size.height - 80);
    CGRect frmLblContent = CGRectMake(66, frame.size.height/8,
                                      frame.size.width-132, frame.size.height - 80);
    CGFloat fontSize = 24.0;
    CGRect frmPin = CGRectMake(frame.size.width-8-104, frame.size.height-24, 104, 24);
    CGRect frmLike = CGRectMake(12, frame.size.height-24, 96, 24);
    CGRect frmBtnDetails = CGRectMake(frame.size.width/2-48, frame.size.height-24, 96, 24);
    
    if ([msg img] == nil) {
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
    }
    else {
        [self setupImageForMessage:msg inFrame:frame];
        
        CGRect frmImgContent = CGRectMake(14, 14, frame.size.width-28, frame.size.height - 150);
        frmLeftQuote.origin.y = frmImgContent.origin.y+frmImgContent.size.height;
        frmLeftQuote.size.height = frmLeftQuote.size.width = 24;
        frmRightQuote.origin.y = frmLeftQuote.origin.y;
        frmRightQuote.origin.x += 16;
        frmRightQuote.size.height = frmRightQuote.size.width = 24;
        frmLblContent.origin.y = frmLeftQuote.origin.y;
        frmLblContent.size.height = 44;
        
        fontSize = 18;
    }
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
        [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
        [lblContent setTextColor:[UIColor blackColor]];
        [lblContent setNumberOfLines:0];
        [lblContent sizeToFit];

        [self addSubview:imgLeftQuote];
        [self addSubview:imgRightQuote];
        [self addSubview:lblContent];
    }

    UIImage* like = [msg liked] ? likeRed : likeGrey;
    //NSString* likeText = [msg likeCount] > 0 ? [NSString stringWithFormat:@"%d", [msg likeCount]] : @"";
    if (btnLike == nil) {
        btnLike = [[UICaptionButton alloc] initWithFrame:frmLike
                                               withImage:like
                                            andRightText:@"like it"];
        [btnLike setCaptionColor:[UIColor darkGrayColor]];
        [self addSubview:btnLike];
    }
    [btnLike setImage:like];
    [btnLike setFrame:frmLike];
    [btnLike addTarget:self action:@selector(likeMessage:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* pin = [msg pinned] ? pinRed : pinGrey;
    if (btnPin == nil) {
        btnPin = [[UICaptionButton alloc] initWithFrame:frmPin withImage:pin
                                                andRightText:@"save it"];
        [btnPin setCaptionColor:[UIColor darkGrayColor]];
        [self addSubview:btnPin];
    }
    [btnPin setImage:pin];
    [btnPin setFrame:frmPin];
    [btnPin addTarget:self action:@selector(pinMessage:) forControlEvents:UIControlEventTouchUpInside];

    if (btnDetails == nil) {
        btnDetails = [[UICaptionButton alloc] initWithFrame:frmBtnDetails
                                                  withImage:openInNew
                                                    andRightText:@"see it"];
        [btnDetails setCaptionColor:[UIColor darkGrayColor]];
        [self addSubview:btnDetails];
    }
    [btnDetails setImage:openInNew];
    [btnDetails setFrame:frmBtnDetails];
    [btnDetails setHidden:[msg url] == nil];

    [btnDetails addTarget:self action:@selector(messageFollow:)
         forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupImageForMessage:(Message*)msg inFrame:(CGRect)frame {
    CGRect frmImgContent = CGRectMake(14, 14, frame.size.width-28, frame.size.height - 150);
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
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add your message..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add your message...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    else
        [message updateText:textView];
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
                                               replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    else
        [message updateText:textView];

    return YES;
}

-(IBAction)messageFollow:(id)sender{
    [message follow:sender];
}

-(IBAction)pinMessage:(id)sender {
    [message setPinned:![message pinned]];
    [Data setMessagePin:message withValue:[message pinned]];
    
    if ([message pinned])
        [SqlDb pinMessage:message];
    else
        [SqlDb unpinMessage:message];
    
    [btnPin setImage:([message pinned] ? pinRed : pinGrey)];
}

-(IBAction)likeMessage:(id)sender {
    [message setLiked:![message liked]];
    [message setLikeCount:[message likeCount] + ([message liked] ? 1 : -1)];
    
    NSMutableURLRequest* req = [NSMutableURLRequest
                                requestWithURL:[NSURL URLWithString:@"http://www.textmuse.com/admin/notelike.php"]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%ld&app=%@&h=%d",
                       (long)[message msgId], AppID, ([message liked] ? 1 : 0)]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];
    
    [btnLike setSelected:[message liked]];
    [btnLike setImage:([message liked] ? likeRed : likeGrey)];
    //[btnLike setRightCaption:[message likeCount] == 0 ? @"" : [NSString stringWithFormat:@"%d", [message likeCount]]];
}

@end
