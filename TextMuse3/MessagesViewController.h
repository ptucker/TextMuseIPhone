//
//  MessagesViewController.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/19/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendMessage.h"
#import "MessageView.h"
#import "UICaptionButton.h"

@interface MessagesViewController : UIViewController<NSURLConnectionDelegate, UIScrollViewDelegate> {
    IBOutlet UIView* header;
    IBOutlet UILabel* headerLabel;
    IBOutlet UICaptionButton* selectButton;
    IBOutlet UIButton* highlightButton;
    IBOutlet UIView* lowerView;
    
    IBOutlet UIScrollView* scrollview;
    IBOutlet UIPageControl* pages;
    unsigned long pageDivisor;
    CGRect frameStart;
    
    SendMessage* sendMessage;
    NSMutableData* inetdata;
    
    //MessageView* msgviews[5];
    NSMutableArray* msgviews;
    NSArray* msgs;
    
    UIImage* yellowHighlighter;
    UIImage* greyHighlighter;
    UIImage* flag;
    UIImage* currency;
    UIBarButtonItem* flagButton;
    UIBarButtonItem* currencyButton;
}

-(IBAction)backButton:(id)sender;
-(IBAction)changePage;
-(IBAction)chooseMessage:(id)sender;
-(IBAction)highlightMessage:(id)sender;

@end
