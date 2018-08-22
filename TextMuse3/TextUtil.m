//
//  TextUtil.m
//  TextMuse
//
//  Created by Peter Tucker on 6/2/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import "TextUtil.h"

@implementation TextUtil

+(UIFont*)GetDefaultFont {
    return [TextUtil GetDefaultFontForSize:18.0];
}

+(UIFont*)GetDefaultFontForSize:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Regular" size:size];
}

+(UIFont*)GetLightFontForSize:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Light" size:size];
}

+(UIFont*)GetBoldFontForSize:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Medium" size:size];
}

+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent forFont:(UIFont *)font {
    CGSize ret = CGSizeMake(sizeParent.width, sizeParent.height);
    
    if ([text length] > 0) {
        CGRect labelRect =
        [text boundingRectWithSize:ret
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : font
                                     }
                           context:nil];
        ret.height = ceil(labelRect.size.height);
        ret.width = ceil(labelRect.size.width);
    }
    
    return ret;
}

+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent {
    return [TextUtil GetContentSizeForText:text
                                    inSize:sizeParent
                                   forFont:[TextUtil GetDefaultFont]];
}



@end
