//
//  ImageUtil.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/7/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+(UIImage*) scaleImage:(UIImage*)img forFrame:(CGRect)frame {
    CGSize size = [img size];
    CGFloat origRes = size.width / size.height;
    CGFloat newRes = frame.size.width / frame.size.height;
    CGFloat scale = 1;
    
    if (newRes < origRes)
        scale = size.height / frame.size.height;
    else
        scale = size.width / frame.size.width;
    
    return [UIImage imageWithCGImage:[img CGImage] scale:scale orientation:UIImageOrientationUp];
}

+ (UIImage *)applyAlpha:(CGFloat) alpha toImage:(UIImage *)image
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

+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent {
    return [self GetContentSizeForImage:img inSize:sizeParent forCell:YES];
}

+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent forCell:(bool)cell {
    CGSize sizeView = sizeParent;
    if (cell && sizeView.height > sizeParent.height/2.5)
        sizeView.height = sizeParent.height/2.5;
    CGSize sizeImage = [img size];
    if (sizeImage.width != 0) {
        CGFloat ratioImage = sizeImage.height / sizeImage.width;
        CGFloat ratioView = sizeView.height / sizeView.width;
        if (ratioImage > ratioView) {
            if (sizeImage.height > sizeView.height) {
                sizeView.width = sizeView.height / ratioImage;
            }
        }
        else {
            if (sizeImage.width > sizeView.width) {
                sizeView.height = sizeView.width * ratioImage;
            }
        }
    }
    else {
        //Just guess
        sizeView.height = 133;
        sizeView.width = sizeParent.width;
    }
    
    if (isnan(sizeView.height) || isnan(sizeView.width))
        NSLog(@"this sucks");
    
    return sizeView;
}

+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
