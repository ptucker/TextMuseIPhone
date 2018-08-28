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
    return [self initWithStep:step
                     forFrame:frame
                   withParams:nil
            completionHandler:completionHandler];
}

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame withParams:(NSArray *)params {
    return [self initWithStep:step
                     forFrame:frame
                   withParams:params
            completionHandler:nil];
}

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame
             withParams:(NSArray*)params
      completionHandler:(void (^)(void))completionHandler {
    self = [super initWithFrame:frame];
    completion = completionHandler;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    //Calculate the amount of height needed for this tour step
    CGFloat margin = 8;
    CGFloat heightLogo = 32;
    CGFloat heightImage = 120;
    CGFloat totalHeight = heightLogo + margin;
    if ([step image] != nil)
        totalHeight += heightImage + margin;

    CGSize szTitle = CGSizeMake(frame.size.width-20, frame.size.height);
    UIFont* titleFont = [TextUtil GetBoldFontForSize:32.0];
    szTitle = [TextUtil GetContentSizeForText:@"TextMuse Tour" inSize:szTitle forFont:titleFont];
    totalHeight += szTitle.height + margin;

    CGSize szText = CGSizeMake(frame.size.width-20, frame.size.height);
    UIFont* messageFont = [TextUtil GetDefaultFontForSize:18.0];
    NSString* message = [step message];
    if (params != nil)
        message = [self modifyMessage:[step message] withParameters:params];
    szText = [TextUtil GetContentSizeForText:message inSize:szText forFont:messageFont];
    szText.height += 8;
    totalHeight += szText.height;
    
    //Center the tour information vertically (with a minr offset to move it up slightly)
    CGFloat textTop = (frame.size.height*0.40) - (totalHeight/2);
    if (textTop < 70) textTop = 70;
    UIImageView* logo = [[UIImageView alloc] initWithFrame:CGRectMake(5, textTop, heightLogo, heightLogo)];
    [logo setImage:[UIImage imageNamed:@"logo-02-color"]];
    [self addSubview:logo];
    textTop += heightLogo + margin;
    
    if ([step image] != nil) {
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, textTop, frame.size.width-10, heightImage)];
        [img setImage:[step image]];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:img];
        
        textTop += heightImage + margin;
    }
    
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, textTop, frame.size.width-20, szTitle.height)];
    [lblTitle setText:@"TextMuse Tour"];
    [lblTitle setFont:titleFont];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor darkGrayColor]];
    [self addSubview:lblTitle];
    textTop += szTitle.height + margin;
    
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, textTop, frame.size.width-20, szText.height)];
    [lblMessage setFont:messageFont];
    [lblMessage setTextColor:[UIColor darkGrayColor]];
    [lblMessage setText:message];
    [lblMessage setNumberOfLines:0];
    [self addSubview:lblMessage];
    
    CGFloat widthButton = frame.size.width/2 - 40;
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(10, frame.size.height - 95, widthButton, 40)];
    [[btn titleLabel] setFont:[TextUtil GetDefaultFontForSize:18]];
    [btn setTitle:@"Cancel Tour" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2 + 10), frame.size.height - 95, widthButton, 40)];
    [[btn titleLabel] setFont:[TextUtil GetDefaultFontForSize:18]];
    [btn setTitle:@"Continue" forState:UIControlStateNormal];
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

-(NSString*)modifyMessage:(NSString*)msg withParameters:(NSArray*)params {
    NSString* ret = msg;
    
    for (NSString* p in params) {
        NSRange rng = [ret rangeOfString:@"%%"];
        if (rng.location != NSNotFound) {
            ret = [ret stringByReplacingCharactersInRange:rng withString:p];
        }
    }
    
    return ret;
}

@end
