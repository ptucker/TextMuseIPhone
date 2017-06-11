//
//  ImageUtil.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/7/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageUtil : NSObject

+(UIImage*) scaleImage:(UIImage*)img forFrame:(CGRect)frame;
+(UIImage *)applyAlpha:(CGFloat) alpha toImage:(UIImage *)image;
+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent;
+(CGSize) GetContentSizeForImage:(UIImage*) img inSize:(CGSize)sizeParent forCell:(bool)cell;
+(UIImage *) imageFromColor:(UIColor *)color;
@end
