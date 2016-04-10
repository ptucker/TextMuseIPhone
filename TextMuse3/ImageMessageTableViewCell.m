//
//  ImageMessageTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "ImageMessageTableViewCell.h"

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
    [super showForSize:size
           usingParent:nav
             withColor:color
             textColor:colorText
            titleColor:colorTitle
                 title:title
               sponsor:sponsor
               message:msg];
    
    UIImage* img = nil;
    if ([msg img] != nil)
        img = [UIImage imageWithData:[msg img]];
    else {
        if (imgLoading == nil) {
            imgLoading = [UIImage imageNamed:@"TransparentButterfly"];
            imgLoading = [self applyAlpha:0.70 toImage:imgLoading];
        }
        img = imgLoading;
    }
    
    CGRect frmContentImage = CGRectMake(0, 0, frmParent.size.width, frmParent.size.height);
    CGRect frmContentLabel = CGRectMake(8, frmParent.size.height - 21, frmParent.size.width-16, 21);
    CGRect frmContentFrame = CGRectMake(0, frmParent.size.height - 21, frmParent.size.width, 21);
    frmLogo = CGRectMake(frmContentFrame.size.width - 41, 13, 21, 21);
    
    [self setMsgImage:msg forFrame:frmContentImage withDefault:img];

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
    
    if ([msg img] == nil) {
        [[msg loader] addImageView:imgContent];
        [[msg loader] addTableView:_tableView];
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
/*
- (UIImage *)applyAlpha:(CGFloat) alpha toImage:(UIImage*)img{
    UIGraphicsBeginImageContextWithOptions([img size], NO, 0.0f);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextRef ctx = CGBitmapContextCreate(nil, [img size].width, [img size].height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    CGRect area = CGRectMake(0, 0, [img size].width, [img size].height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, [img CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
*/

- (UIImage *)applyAlpha:(CGFloat) alpha toImage:(UIImage *)image
{
    // image is an instance of UIImage class that we will convert to grayscale
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    
    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    return grayScaleImage;
}

@end
