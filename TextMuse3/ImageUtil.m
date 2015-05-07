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



@end
