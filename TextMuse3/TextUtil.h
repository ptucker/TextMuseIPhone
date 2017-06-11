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

+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent;
+(CGSize) GetContentSizeForText:(NSString*)text inSize:(CGSize)sizeParent forFont:(UIFont*)font;

@end
