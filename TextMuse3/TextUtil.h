//
//  TextUtil.h
//  TextMuse
//
//  Created by Peter Tucker on 6/2/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextUtil : NSObject

+(UIFont*) GetDefaultFont;
+(UIFont*) GetDefaultFontForSize:(CGFloat)size;
+(UIFont*) GetLightFontForSize:(CGFloat)size;
+(UIFont*) GetBoldFontForSize:(CGFloat)size;
+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent;
+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent forFont:(UIFont*)font;

@end
