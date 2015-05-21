//
//  WalkthroughViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/20/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "WalkthroughViewController.h"

@interface WalkthroughViewController ()

@end

@implementation WalkthroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [scroller setDelegate:self];
    [pages addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated {
    int pagecount = 5;
    [pages setNumberOfPages:pagecount];
    CGRect frmScroll = [scroller frame];
    int x = 0;
    NSString* images[] = {
        @"categories.png", @"message.png", @"contacts.png", @"message_edit.png", @"settings.png"
    };
    NSString* txts[] = {
        @"Choose a category to find a text message you want to send your friends.",
        @"Swipe through and touch the text message you want to send.",
        @"After choosing a text, your contacts will appear. Choose a contact or select a few and touch 'SEND'.",
        @"... and before you send it, you can make edits to give it that personal touch.",
        @"Touch the cog to personalize TextMuse – choose your favorite categories, adjust settings and send us your feedback!"
    };
    CGFloat txtHeight = 120;
    frmScroll.size.height -= frmScroll.origin.y;
    for (int i=0; i<pagecount; i++) {
        CGRect frmText = CGRectMake(x + 10, frmScroll.size.height - txtHeight,
                                    frmScroll.size.width - 20, txtHeight);
        CGRect frmImg = CGRectMake(x, 0, frmScroll.size.width, frmScroll.size.height - txtHeight);
        UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:images[i]]];
        [img setFrame:frmImg];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [scroller addSubview:img];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:frmText];
        [lbl setText:txts[i]];
        [lbl setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
        [lbl setTextColor:[UIColor blackColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setNumberOfLines:0];
        [scroller addSubview:lbl];
        
        x += frmScroll.size.width;
    }
    [scroller setContentSize:CGSizeMake(frmScroll.size.width*pagecount, frmScroll.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = [scroller frame].size.width;
    int page = floor(([scroller contentOffset].x - pageWidth / 2) / pageWidth) + 1;
    
    [pages setCurrentPage: page];
}

- (IBAction)pageTurn:(id)sender {
    long page = [pages currentPage];
    CGRect frm = [scroller frame];
    CGPoint p = [scroller contentOffset];
    [scroller setContentOffset:CGPointMake(page * frm.size.width, p.y)];
}


@end
