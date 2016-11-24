//
//  ImageUtil.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/7/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
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


@end
