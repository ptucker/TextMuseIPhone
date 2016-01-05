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
    UILabel* _caption;
    UIImage* _image;
    UIImageView* _imgview;
    BOOL right;
}

-(id)initWithImage:(UIImage*)img andText:(NSString*)txt;
-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt;
-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andRightText:(NSString*)txt;
-(void)setCaption:(NSString*)caption;
-(void)setImage:(UIImage*)img;

@end
