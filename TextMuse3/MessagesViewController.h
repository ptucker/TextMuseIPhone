//
//  MessagesViewController.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController<UIScrollViewDelegate> {
    IBOutlet UIView* header;
    IBOutlet UILabel* headerLabel;
    IBOutlet UIButton* selectButton;
    IBOutlet UIButton* highlightButton;
    
    IBOutlet UIScrollView* scrollview;
    IBOutlet UIPageControl* pages;
    unsigned long pageDivisor;
    CGRect frameStart;
}

-(IBAction)backButton:(id)sender;
-(IBAction)changePage;
-(IBAction)chooseMessage:(id)sender;
-(IBAction)highlightMessage:(id)sender;

@end
