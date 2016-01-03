//
//  ImageMessageTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "ImageMessageTableViewCell.h"

@implementation ImageMessageTableViewCell

-(void)showForSize:(CGSize)size
       usingParent:(id)nav
          withColor:(UIColor*)color
          textColor:(UIColor*)colorText
         titleColor:(UIColor*)colorTitle
              title:(NSString*)title
           sponsor:(SponsorInfo *)sponsor
            message:(Message*)msg {
    [super showForSize:size
           usingParent:nav
             withColor:color
             textColor:colorText
            titleColor:colorTitle
                 title:title
               sponsor:sponsor
               message:msg];
    
    CGRect frmContentImage = CGRectMake(0, 0, frmParent.size.width, frmParent.size.height);
    CGRect frmContentLabel = CGRectMake(0, frmParent.size.height - 21, frmParent.size.width, 21);
    if (imgContent == nil) {
        imgContent = [[UIImageView alloc] initWithFrame:frmContentImage];
        [imgContent setContentMode:UIViewContentModeScaleAspectFit];
        [imgContent setClipsToBounds:YES];
        [viewParent addSubview:imgContent];
    }
    if ([[msg text] length] > 0) {
        [lblContent setHidden:NO];
        [lblContent setBackgroundColor:[UIColor darkGrayColor]];
        [lblContent setTextColor:[UIColor whiteColor]];
        [lblContent setAlpha:0.80];
    }
    else {
        [lblContent setHidden:YES];
    }
    
    [imgContent setImage:[UIImage imageWithData:[msg img]]];
    [viewParent bringSubviewToFront:lblContent];
    [lblContent setFrame:frmContentLabel];
    [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
}

@end
