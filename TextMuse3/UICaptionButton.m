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

-(void)addViews {
    CGRect frmImg = CGRectMake(0, 0, [self frame].size.width, [self frame].size.height * 0.60);
    CGRect frmText = CGRectMake(0, [self frame].size.height * 0.60,
                                [self frame].size.width, [self frame].size.height*0.40);

    UIImageView* iview = [[UIImageView alloc] initWithImage:_image];
    [iview setFrame:frmImg];
    [iview setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:iview];
    
    UILabel* lview = [[UILabel alloc] initWithFrame:frmText];
    [lview setText:_text];
    [lview setTextAlignment:NSTextAlignmentCenter];
    UIFont* fnt = [UIFont fontWithName:@"Lato-Medium" size:10.0];
    [lview setFont:fnt];
    [self addSubview:lview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
