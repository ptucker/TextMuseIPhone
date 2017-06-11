//
//  ImageMessageTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "ImageMessageTableViewCell.h"
#import "ImageUtil.h"
#import "TextUtil.h"

@implementation ImageMessageTableViewCell

UIImage* imgLoading;

-(void)showForSize:(CGSize)size
       usingParent:(id)nav
          withColor:(UIColor*)color
          textColor:(UIColor*)colorText
         titleColor:(UIColor*)colorTitle
              title:(NSString*)title
           sponsor:(SponsorInfo *)sponsor
            message:(Message*)msg {
    UIImage* img = nil;
    bool loading = [msg img] == nil;
    if (!loading)
        img = [UIImage imageWithData:[msg img]];
    else {
        if (imgLoading == nil) {
            imgLoading = [UIImage imageNamed:@"TransparentButterfly"];
            imgLoading = [ImageUtil applyAlpha:0.70 toImage:imgLoading];
        }
        img = imgLoading;
        [[msg loader] addImageView:imgContent];
        [[msg loader] addTableView:_tableView];
    }
    
    [super showForSize:size
           usingParent:nav
             withColor:color
             textColor:colorText
            titleColor:colorTitle
                 title:title
               sponsor:sponsor
               message:msg];
    
    CGSize sizeTemplate = CGSizeMake(size.width-16, size.height);
    CGSize sizeText = [TextUtil GetContentSizeForText:[msg text]
                                               inSize:CGSizeMake(sizeTemplate.width,sizeTemplate.height)];
    CGSize sizeImg = CGSizeMake(sizeTemplate.width, 93);
    if (!loading)
        sizeImg = [ImageUtil GetContentSizeForImage:img inSize:sizeTemplate];
    
    CGRect frmContentImage = CGRectMake((sizeTemplate.width-sizeImg.width)/2, 0, sizeImg.width,
                                        sizeImg.height);
    CGRect frmContentLabel = CGRectMake((sizeTemplate.width - sizeText.width)/2, sizeImg.height+4,
                                        sizeText.width, sizeText.height);
    CGRect frmContentFrame = CGRectMake(0, frmParent.size.height - 21, frmParent.size.width, 21);
    frmLogo = CGRectMake(frmContentFrame.size.width - 41, 13, 21, 21);
    
    [self setMsgImage:msg forFrame:frmContentImage withDefault:img];

    if ([[msg text] length] > 0) {
        UIView* vFrame = [[UIView alloc] initWithFrame:frmContentFrame];
        //[vFrame setBackgroundColor:[UIColor darkGrayColor]];
        //[vFrame setAlpha:0.80];
        [viewParent addSubview:vFrame];
        [viewParent bringSubviewToFront:vFrame];
        
        [lblContent setHidden:NO];
        [lblContent setNumberOfLines:0];
        [lblContent setTextColor:[UIColor blackColor]];
        [lblContent setTextAlignment:NSTextAlignmentCenter];
        [viewParent bringSubviewToFront:lblContent];
    }
    else {
        [lblContent setHidden:YES];
    }
    
    [lblContent setFrame:frmContentLabel];
    [lblContent setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];

    [viewParent bringSubviewToFront:imgLogo];
}

-(void)setMsgImage:(Message*)msg forFrame:(CGRect)frmContentImage withDefault:(UIImage*)img {
    BOOL gif = [[msg imgType] isEqualToString:@"image/gif"];
    if (imgContent == nil) {
        if (gif) {
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            [imageView setFrame:frmContentImage];
            imgContent = imageView;
        }
        else {
            imgContent = [[UIImageView alloc] initWithFrame:frmContentImage];
            [imgContent setContentMode:UIViewContentModeScaleAspectFit];
            [imgContent setClipsToBounds:YES];
        }
        [viewParent addSubview:imgContent];
    }
    
    if (gif) {
        FLAnimatedImageView* imageView = (FLAnimatedImageView*)imgContent;
        if ([imageView animatedImage] == nil) {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[msg img]];
            [imageView setAnimatedImage: image];
            BOOL running = [imageView isAnimating];
            if (!running) {
                [imageView startAnimating];
            }
        }
    }
    else {
        [imgContent setImage:img];
    }
    
}

@end
