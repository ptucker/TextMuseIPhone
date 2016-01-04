//
//  UICaptionButton.h
//  TextMuse
//
//  Created by Peter Tucker on 1/4/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICaptionButton : UIButton {
    NSString* _text;
    UIImage* _image;
}

-(id)initWithImage:(UIImage*)img andText:(NSString*)txt;
-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt;

@end
