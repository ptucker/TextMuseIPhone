//
//  UICaptionButton.m
//  TextMuse
//
//  Created by Peter Tucker on 1/4/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "UICaptionButton.h"

@implementation UICaptionButton

-(id)initWithImage:(UIImage*)img andText:(NSString*)txt {
    self = [super init];
    _text = txt;
    _image = img;
    
    [self addViews];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt{
    self = [super initWithFrame:frame];
    _text = txt;
    _image = img;

    [self addViews];

    return self;
}

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andRightText:(NSString*)txt{
    self = [super initWithFrame:frame];
    _rtext = txt;
    _image = img;
    
    [self addViews];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt andRightText:(NSString*)txtRight {
    self = [super initWithFrame:frame];
    _text = txt;
    _rtext = txtRight;
    _image = img;
    
    [self addViews];
    
    return self;
}

-(void)addViews {
    BOOL right = [_rtext length] > 0;
    BOOL bottom = [_text length] > 0;
    CGFloat widthImage = right ? [self frame].size.width * 0.60 : [self frame].size.width;
    CGFloat heightImage = bottom ? [self frame].size.height * 0.60 : [self frame].size.height;
    CGRect frmImg = CGRectMake(0, 0, widthImage, heightImage);
    CGRect frmRightText = CGRectMake([self frame].size.width * 0.50, 0, [self frame].size.width * 0.50,
                                     heightImage);
    CGRect frmBottomText =
        CGRectMake(0, [self frame].size.height * 0.60, widthImage, [self frame].size.height*0.40);

    _imgview = [[UIImageView alloc] initWithImage:_image];
    [_imgview setFrame:frmImg];
    [_imgview setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_imgview];
    
    _caption = [[UILabel alloc] initWithFrame:frmBottomText];
    [_caption setText:_text];
    [_caption setTextAlignment:NSTextAlignmentCenter];
    CGFloat fontsize = frmBottomText.size.height;
    UIFont* fnt = [UIFont fontWithName:@"Lato-Medium" size:fontsize];
    [_caption setFont:fnt];
    [self addSubview:_caption];

    _rcaption = [[UILabel alloc] initWithFrame:frmRightText];
    [_rcaption setText:_rtext];
    [_rcaption setTextAlignment:NSTextAlignmentLeft];
    fontsize = 0.75 * frmRightText.size.height;
    fnt = [UIFont fontWithName:@"Lato-Medium" size:fontsize];
    [_rcaption setFont:fnt];
    [self addSubview:_rcaption];
}

-(void)setCaption:(NSString*)caption {
    _text = caption;
    [_caption setText:_text];
}

-(void)setImage:(UIImage*)img {
    [_imgview setImage:img];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
