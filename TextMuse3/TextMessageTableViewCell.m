//
//  TextMessageTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "TextMessageTableViewCell.h"

@implementation TextMessageTableViewCell

-(void)showForSize:(CGSize)size
       usingParent:(id)nav
          withColor:(UIColor*)color
          textColor:(UIColor*)colorText
         titleColor:(UIColor*)colorTitle
              title:(NSString*)title
            sponsor:(SponsorInfo*)sponsor
            message:(Message*)msg {
    [super showForSize:size
           usingParent:nav
             withColor:color
             textColor:colorText
            titleColor:colorTitle
                 title:title
               sponsor:sponsor
               message:msg];
    
    long quoteSize = size.width * 44 / 414;
    CGRect frmLeft = CGRectMake(8, 30, quoteSize, quoteSize);
    CGRect frmRight = CGRectMake(frmParent.size.width - quoteSize, 30, quoteSize, quoteSize);
    //491 X 326
    int bubbleWidth = frmParent.size.height * 491 / 326;
    CGRect frmBubble = CGRectMake(frmParent.size.width - bubbleWidth, 0,
                                  bubbleWidth, frmParent.size.height);
    frmContent = CGRectMake(quoteSize + 8, 8,
                            frmParent.size.width-(quoteSize*2)-16, frmParent.size.height-8);

    if (imgBubble == nil) {
        imgBubble = [[UIImageView alloc] initWithFrame:frmBubble];
        [imgBubble setImage:[UIImage imageNamed:@"whitecategorybubble"]];
        [viewParent addSubview:imgBubble];
    }
    if (imgLeftQuote == nil) {
        imgLeftQuote = [[UIImageView alloc] initWithFrame:frmLeft];
        [imgLeftQuote setImage:[UIImage imageNamed:@"whitecategoryleftquote"]];
        [viewParent addSubview:imgLeftQuote];
    }
    if (imgRightQuote == nil) {
        imgRightQuote = [[UIImageView alloc] initWithFrame:frmRight];
        [imgRightQuote setImage:[UIImage imageNamed:@"whitecategoryrightquote"]];
        [viewParent addSubview:imgRightQuote];
    }
    
    [viewParent setBackgroundColor:color];

    [lblContent setTextColor:colorText];
    [lblContent setFrame:frmContent];
    [lblContent setNumberOfLines:0];
    [lblContent setTextAlignment:NSTextAlignmentCenter];
    
    [viewParent bringSubviewToFront:lblContent];
    
    [imgLeftQuote setContentMode:UIViewContentModeScaleAspectFit];
    [imgLeftQuote setTintColor:color];
    [imgRightQuote setContentMode:UIViewContentModeScaleAspectFit];
    [imgRightQuote setTintColor:color];
    [imgBubble setContentMode:UIViewContentModeScaleAspectFit];
    [imgBubble setTintColor:color];
}

@end
