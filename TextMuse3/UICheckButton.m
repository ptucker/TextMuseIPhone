//
//  UICheckButton.m
//  TextMuse3
//
//  Created by Peter Tucker on 4/25/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "UICheckButton.h"

@implementation UICheckButton

-(id)init {
    self = [super init];
    
    [self setImage:[UIImage imageNamed:@"emptycheck"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"bluecheck"] forState:UIControlStateSelected];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setImage:[UIImage imageNamed:@"emptycheck"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"bluecheck"] forState:UIControlStateSelected];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
