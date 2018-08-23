//
//  GuidedTourStepView.m
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import "GuidedTourStepView.h"
#import "TextUtil.h"
#import "GlobalState.h"

@implementation GuidedTourStepView

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame {
    return [self initWithStep:step forFrame:frame completionHandler:nil];
}

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame completionHandler:(void (^)(void))completionHandler {
    self = [super initWithFrame:frame];
    completion = completionHandler;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView* logo = [[UIImageView alloc] initWithFrame:CGRectMake(5, 65, 32, 32)];
    [logo setImage:[UIImage imageNamed:@"logo-02-color"]];
    [self addSubview:logo];
    
    CGFloat textTop = 110;
    if ([step image] != nil) {
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, textTop, frame.size.width-10, 80)];
        [img setImage:[step image]];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:img];
        
        textTop += 100;
    }
    
    CGSize szTitle = CGSizeMake(frame.size.width-20, 40);
    UIFont* titleFont = [TextUtil GetBoldFontForSize:32.0];
    szTitle = [TextUtil GetContentSizeForText:@"TextMuse Tour" inSize:szTitle forFont:titleFont];
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, textTop, frame.size.width-20, szTitle.height)];
    [lblTitle setText:@"TextMuse Tour"];
    [lblTitle setFont:titleFont];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor darkGrayColor]];
    [self addSubview:lblTitle];
    textTop += szTitle.height + 8;
    
    CGSize szText = CGSizeMake(frame.size.width-20, frame.size.height - textTop - 10);
    UIFont* messageFont = [TextUtil GetDefaultFontForSize:18.0];
    szText = [TextUtil GetContentSizeForText:[step message] inSize:szText forFont:messageFont];
    szText.height += 8;
    
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, textTop, frame.size.width-40, szText.height)];
    [lblMessage setFont:messageFont];
    [lblMessage setTextColor:[UIColor darkGrayColor]];
    [lblMessage setText:[step message]];
    [lblMessage setNumberOfLines:0];
    [self addSubview:lblMessage];
    
    CGFloat widthButton = frame.size.width/2 - 40;
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(10, frame.size.height - 95, widthButton, 40)];
    [[btn titleLabel] setFont:[TextUtil GetDefaultFontForSize:18]];
    [btn setTitle:@"Cancel" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2 + 10), frame.size.height - 95, widthButton, 40)];
    [[btn titleLabel] setFont:[TextUtil GetDefaultFontForSize:18]];
    [btn setTitle:@"OK" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return self;
}

-(void)cancel:(id)obj {
    //don't show this anymore.
    Tour = nil;
    [self dismiss:nil];
}

-(void)dismiss:(id)obj {
    [self removeFromSuperview];
    if (completion)
        completion();
}

@end
