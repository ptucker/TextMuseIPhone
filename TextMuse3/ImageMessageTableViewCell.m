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
    CGRect frmContentLabel = CGRectMake(8, frmParent.size.height - 21, frmParent.size.width-16, 21);
    CGRect frmContentFrame = CGRectMake(0, frmParent.size.height - 21, frmParent.size.width, 21);
    BOOL gif = ([[[msg mediaUrl] pathExtension] isEqualToString:@"gif"]);
    if (imgContent == nil) {
        if (gif) {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[msg img]];
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            [imageView setAnimatedImage: image];
            imgContent = imageView;
        }
        else
            imgContent = [[UIImageView alloc] initWithFrame:frmContentImage];
        [imgContent setContentMode:UIViewContentModeScaleAspectFit];
        [imgContent setClipsToBounds:YES];
        [viewParent addSubview:imgContent];
    }
    if ([[msg text] length] > 0) {
        UIView* vFrame = [[UIView alloc] initWithFrame:frmContentFrame];
        [vFrame setBackgroundColor:[UIColor darkGrayColor]];
        [vFrame setAlpha:0.80];
        [viewParent addSubview:vFrame];
        [viewParent bringSubviewToFront:vFrame];
        
        [lblContent setHidden:NO];
        [lblContent setTextColor:[UIColor whiteColor]];
        [lblContent setTextAlignment:NSTextAlignmentCenter];
        [viewParent bringSubviewToFront:lblContent];
    }
    else {
        [lblContent setHidden:YES];
    }
    
    [imgContent setImage:[UIImage imageWithData:[msg img]]];
    [lblContent setFrame:frmContentLabel];
    [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
}

@end
