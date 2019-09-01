//
//  UICaptionButton.m
//  TextMuse
//
//  Created by Peter Tucker on 1/4/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "UICaptionButton.h"
#import "ImageUtil.h"
#import "TextUtil.h"

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

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt
      withFontsize:(CGFloat)fontsize{
    self = [super initWithFrame:frame];
    _text = txt;
    _image = img;
    _fontsize = fontsize;
    
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
    if (_image == nil) {
        _image = [UIImage imageNamed:@"TransparentButterfly"];
        _image = [ImageUtil applyAlpha:0.70 toImage:_image];
    }
    _imgview = [[UIImageView alloc] initWithImage:_image];
    [_imgview setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_imgview];
    
    _caption = [[UILabel alloc] init];
    [_caption setText:_text];
    [_caption setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_caption];

    _rcaption = [[UILabel alloc] init];
    [_rcaption setText:_rtext];
    [_rcaption setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_rcaption];
    
    [self setupViews];
}

-(void)setupViews {
    BOOL right = [_rtext length] > 0;
    BOOL bottom = [_text length] > 0;
    CGFloat widthImage = right ? [self frame].size.width * 0.60 : [self frame].size.width;
    CGFloat heightImage = bottom ? [self frame].size.height * 0.60 : [self frame].size.height;
    CGRect frmImg = CGRectMake(0, 0, widthImage, heightImage);
    CGRect frmRightText = CGRectMake([self frame].size.width * 0.50, 0, [self frame].size.width * 0.50,
                                     heightImage);
    CGRect frmBottomText = CGRectMake(0, [self frame].size.height * 0.60, widthImage,
                                      [self frame].size.height*0.40);
    
    [_imgview setFrame:frmImg];
    
    [_caption setText:_text];
    [_caption setFrame:frmBottomText];
    CGFloat fontsize = (_fontsize == 0) ? frmBottomText.size.height : _fontsize;
    UIFont* fnt = [TextUtil GetBoldFontForSize:fontsize];
    [_caption setFont:fnt];
    
    [_rcaption setText:_rtext];
    [_rcaption setFrame:frmRightText];
    fontsize = 0.75 * frmRightText.size.height;
    fnt = [TextUtil GetBoldFontForSize:fontsize];
    [_rcaption setFont:fnt];
}

-(void)setCaption:(NSString*)caption {
    _text = caption;
    [_caption setText:_text];
    
    [self setupViews];
}

-(void)setRightCaption:(NSString*)caption {
    _rtext = caption;
    [_rcaption setText:_rtext];

    [self setupViews];
}

-(void)setCaptionColor:(UIColor*)color {
    [_rcaption setTextColor:color];
    [_caption setTextColor:color];
}

-(void)setCaptionFontSize:(CGFloat)size {
    [_caption setFont:[TextUtil GetBoldFontForSize:size]];
}

-(void)setImage:(UIImage*)img {
    [_imgview setImage:img];
    [_imgview setContentMode:UIViewContentModeScaleAspectFit];

    [self setupViews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
