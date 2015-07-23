//
//  CategoriesTableViewCell.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "CategoriesTableViewCell.h"
#import "GlobalState.h"

@implementation CategoriesTableViewCell
@synthesize lblTitle, lblContent, btnSeeAll, lblNew, imgRightQuote, imgLeftQuote, imgContent;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showForWidth:(CGFloat)width
          withColor:(UIColor*)color
          textColor:(UIColor*)colorText
              title:(NSString *)title
           newCount:(int)cnt
            message:(Message*)msg {
    message = msg;
    
    CGRect frmTitle = CGRectMake(8, 12, width - 134, 36);
    CGRect frmLblNew = CGRectMake(width-126, 18, 76, 18);
    CGRect frmSeeMore = CGRectMake(width-22, 18, 14, 18);
    CGRect frmContentView = CGRectMake(8, 60, width-16, 110);
    CGRect frmLeftQuote = CGRectMake(8, 30, 32, 32);
    CGRect frmRightQuote = CGRectMake(frmContentView.size.width-44-8, 30, 32, 32);
    CGFloat bubbleHeight = frmContentView.size.height;
    CGFloat bubbleWidth = 491.0 * (frmContentView.size.height / 326);
    CGRect frmBubble = CGRectMake(frmContentView.size.width-bubbleWidth, 0,
                                  bubbleWidth, bubbleHeight);
    CGRect frmImgContent = CGRectMake(0, 0, frmContentView.size.width, frmContentView.size.height);
    CGRect frmTextContentMiddle = CGRectMake(60, 16, frmContentView.size.width-120,
                                             frmContentView.size.height - 32);
    CGRect frmTextContentBottom = CGRectMake(0, frmContentView.size.height - 21,
                                             frmContentView.size.width, 21);
    
    if ([self lblTitle] == nil) {
        [self setLblTitle:[[UILabel alloc] init]];
        [self addSubview:[self lblTitle]];
    }
    [[self lblTitle] setFrame:frmTitle];
    [[self lblTitle] setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [[self lblTitle] setBackgroundColor:[UIColor whiteColor]];
    [[self lblTitle] setTextColor:color];
    [[self lblTitle] setText:title];
    [[self lblTitle] sizeToFit];
    frmTitle = [[self lblTitle] frame];
    CGFloat fntSize = 20;
    while (frmTitle.size.width > (width-134)) {
        fntSize-=1;
        [[self lblTitle] setFont:[UIFont fontWithName:@"Lato-Regular" size:fntSize]];
        [[self lblTitle] sizeToFit];
        frmTitle = [[self lblTitle] frame];
    }
    
    NSString* newLabel = [NSString stringWithFormat:@"%d NEW", cnt];
    if ([self lblNew] == nil) {
        [self setLblNew:[[UILabel alloc] init]];
        [self addSubview:[self lblNew]];
    }
    [[self lblNew] setFrame:frmLblNew];
    [[self lblNew] setBackgroundColor:color];
    [[self lblNew] setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
    [[self lblNew] setTextColor:[UIColor whiteColor]];
    [[self lblNew] setTextAlignment:NSTextAlignmentCenter];
    [[self lblNew] setHidden:(cnt == 0)];
    //Round the corners
    if ([[self lblNew] respondsToSelector:@selector(layer)]) {
        // Get layer for this view.
        CALayer *layer = [[self lblNew] layer];
        // Set border on layer.
        [layer setCornerRadius: 10];
        [layer setMasksToBounds: YES];
    }
    [[self lblNew] setText:newLabel];

    if ([self btnSeeAll] == nil) {
        [self setBtnSeeAll:[[UIButton alloc] init]];
        [self addSubview:[self btnSeeAll]];
    }
    [[self btnSeeAll] setImage:[UIImage imageNamed:@"rightfacingsmallarrow.png"]
                      forState:UIControlStateNormal];
    [[self btnSeeAll] setFrame:frmSeeMore];
    [[self btnSeeAll] setContentMode:UIViewContentModeScaleAspectFit];

    if ([self viewContent] == nil) {
        [self setViewContent:[[UIView alloc] init]];
        [self addSubview:[self viewContent]];
    }
    [[self viewContent] setFrame:frmContentView];
    [[self viewContent] setBackgroundColor:color];
    if ([self imgContent] == nil) {
        [self setImgContent:[[UIImageView alloc] init]];
        [[self viewContent] addSubview:[self imgContent]];
    }
    [[self imgContent] setFrame:frmImgContent];
    if ([self imgBubble] == nil) {
        [self setImgBubble:[[UIImageView alloc] init]];
        [[self viewContent] addSubview:[self imgBubble]];
    }
    [[self imgBubble] setFrame:frmBubble];
    [[self imgBubble] setImage:[UIImage imageNamed:@"whitecategorybubble"]];
    [[self imgBubble] setContentMode:UIViewContentModeScaleToFill];
    [[self imgBubble] setAlpha:0.60];
    if ([self imgLeftQuote] == nil) {
        [self setImgLeftQuote:[[UIImageView alloc] init]];
        [[self viewContent] addSubview:[self imgLeftQuote]];
    }
    [[self imgLeftQuote] setImage:[UIImage imageNamed:@"whitecategoryleftquote"]];
    [[self imgLeftQuote] setFrame:frmLeftQuote];
    [[self imgLeftQuote] setContentMode:UIViewContentModeScaleToFill];
    if ([self imgRightQuote] == nil) {
        [self setImgRightQuote:[[UIImageView alloc] init]];
        [[self viewContent] addSubview:[self imgRightQuote]];
    }
    [[self imgRightQuote] setFrame:frmRightQuote];
    [[self imgRightQuote] setImage:[UIImage imageNamed:@"whitecategoryrightquote"]];
    [[self imgRightQuote] setContentMode:UIViewContentModeScaleToFill];
    BOOL fImage = (msg != nil && [msg img] != nil);
    if ([self lblContent] == nil) {
        [self setLblContent:[[UILabel alloc] init]];
        [[self viewContent] addSubview:[self lblContent]];
    }
    
    [[self imgContent] setHidden:!fImage];
    [[self imgLeftQuote] setHidden:fImage];
    [[self imgRightQuote] setHidden:fImage];
    [[self imgBubble] setHidden:fImage];
    [[self lblContent] setFrame:(fImage ? frmTextContentBottom : frmTextContentMiddle)];
    [[self lblContent] setBackgroundColor:(fImage ? [UIColor grayColor] : [UIColor clearColor])];
    [[self lblContent] setAlpha:(fImage ? 0.70 : 1.0)];
    [[self lblContent] setNumberOfLines:fImage ? 1 : 0];
    CGFloat fontSize = fImage ? 14 : 16;
    [[self lblContent] setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
    [[self lblContent] setTextColor:colorText];
    [[self lblContent] setTextAlignment:NSTextAlignmentCenter];
    if (msg != nil && [msg text] != nil && [[msg text] length] > 0) {
        [[self lblContent] setHidden:NO];
        [[self lblContent] setText:[msg text]];
    }
    else
        [[self lblContent] setHidden:YES];
    
    if (fImage) {
        [[self imgContent] setImage:[UIImage imageWithData:[msg img] scale:1.0]];
        [[self imgContent] setContentMode:UIViewContentModeScaleAspectFill];
        [[self imgContent] setClipsToBounds:YES];
    }
}

@end
