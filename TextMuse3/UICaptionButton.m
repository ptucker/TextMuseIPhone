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
    right = NO;
    
    [self addViews];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andText:(NSString*)txt{
    self = [super initWithFrame:frame];
    _text = txt;
    _image = img;
    right = NO;

    [self addViews];

    return self;
}

-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)img andRightText:(NSString*)txt{
    self = [super initWithFrame:frame];
    _text = txt;
    _image = img;
    right = YES;
    
    [self addViews];
    
    return self;
}

-(void)addViews {
    CGRect frmImg = right ? CGRectMake(0, 0, [self frame].size.width * 0.60, [self frame].size.height) :
                            CGRectMake(0, 0, [self frame].size.width, [self frame].size.height * 0.60);
    CGRect frmText = right ?
        CGRectMake([self frame].size.width * 0.60, 0, [self frame].size.width * 0.40, [self frame].size.height) :
        CGRectMake(0, [self frame].size.height * 0.60, [self frame].size.width, [self frame].size.height*0.40);

    _imgview = [[UIImageView alloc] initWithImage:_image];
    [_imgview setFrame:frmImg];
    [_imgview setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_imgview];
    
    _caption = [[UILabel alloc] initWithFrame:frmText];
    [_caption setText:_text];
    [_caption setTextAlignment:(right ? NSTextAlignmentRight : NSTextAlignmentCenter)];
    CGFloat fontsize = (right ? frmText.size.height/2 : frmText.size.height);
    UIFont* fnt = [UIFont fontWithName:@"Lato-Medium" size:fontsize];
    [_caption setFont:fnt];
    [self addSubview:_caption];
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
