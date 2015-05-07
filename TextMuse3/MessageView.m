//
//  MessageView.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "MessageView.h"
#import "ImageUtil.h"

@implementation MessageView

-(void)setupViewForMessage:(Message *)msg inFrame:(CGRect)frame withColor:(UIColor*)color index:(long)i {
    message = msg;
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect frmLeftQuote = CGRectMake(14, frame.size.height/8, 44, 44);
    CGRect frmRightQuote = CGRectMake(frame.size.width - 58,
                                      frame.size.height/8, 44, 44);
    CGRect frmBubble = CGRectMake(frame.size.width/8, 0,
                                  7*frame.size.width/8, frame.size.height - 80);
    CGRect frmImgContent = CGRectMake(14, 14, frame.size.width-28, frame.size.height - 80);
    CGRect frmLblContent = CGRectMake(66, frame.size.height/8,
                                      frame.size.width-132, frame.size.height - 80);
    CGFloat fontSize = 24.0;
    CGRect frmBtnDetails = CGRectMake(frame.size.width-79, frame.size.height-20, 67, 20);
    
    if ([msg img] == nil) {
        imgBubble = [[UIImageView alloc] initWithFrame:frmBubble];
        switch (i) {
            case 0:
                [imgBubble setImage:[UIImage imageNamed:@"largegreenbubble"]];
                break;
            case 1:
                [imgBubble setImage:[UIImage imageNamed:@"largeorangebubble"]];
                break;
            case 2:
                [imgBubble setImage:[UIImage imageNamed:@"largebluebubble"]];
                break;
        }
        [self addSubview:imgBubble];
    }
    else {
        imgContent = [[UIButton alloc] initWithFrame:frmImgContent];
        UIImage* img = [ImageUtil scaleImage:[UIImage imageWithData:[msg img]] forFrame:frmImgContent];
        [imgContent setImage:img forState:UIControlStateNormal];
        [[imgContent imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [imgContent setBackgroundColor:[UIColor clearColor]];
        [self addSubview:imgContent];
        
        [imgContent addTarget:msg action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        frmLeftQuote.origin.y = frmImgContent.origin.y+frmImgContent.size.height;
        frmLeftQuote.size.height = frmLeftQuote.size.width = 24;
        frmRightQuote.origin.y = frmLeftQuote.origin.y;
        frmRightQuote.origin.x += 16;
        frmRightQuote.size.height = frmRightQuote.size.width = 24;
        frmLblContent.origin.y = frmLeftQuote.origin.y;
        frmLblContent.size.height = 44;
        
        fontSize = 18;
    }
    
    if ([[msg mediaUrl] isEqualToString:@"usertext://"]) {
        imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeftQuote];
        [imgLeftQuote setImage:[UIImage imageNamed:@"blackleftquote"]];
        imgRightQuote = [[UIImageView alloc] initWithFrame:frmRightQuote];
        [imgRightQuote setImage:[UIImage imageNamed:@"blackrightquote"]];

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
        if ([msg text] != nil && [[msg text] length] > 0)
            [tvContent setText:[msg text]];
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
    else if ([msg text] != nil && [[msg text] length] > 0) {
        imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeftQuote];
        [imgLeftQuote setImage:[UIImage imageNamed:@"blackleftquote"]];
        imgRightQuote = [[UIImageView alloc] initWithFrame:frmRightQuote];
        [imgRightQuote setImage:[UIImage imageNamed:@"blackrightquote"]];

        lblContent = [[UILabel alloc] initWithFrame:frmLblContent];
        [lblContent setText:[msg text]];
        [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
        [lblContent setTextColor:[UIColor blackColor]];
        [lblContent setNumberOfLines:0];
        [lblContent sizeToFit];

        [self addSubview:imgLeftQuote];
        [self addSubview:imgRightQuote];
        [self addSubview:lblContent];
    }
    
    if (btnDetails == nil) {
        btnDetails = [[UIButton alloc] init];
        [self addSubview:btnDetails];
    }
    [btnDetails setImage:[UIImage imageNamed:@"link.png"] forState:UIControlStateNormal];
    [btnDetails setFrame:frmBtnDetails];
    [btnDetails setHidden:[msg url] == nil];

    [btnDetails addTarget:self action:@selector(messageFollow:)
         forControlEvents:UIControlEventTouchUpInside];
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

@end
