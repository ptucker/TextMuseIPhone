//
//  WalkthroughViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/20/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughViewController : UIViewController<UIScrollViewDelegate, UIPageViewControllerDelegate> {
    IBOutlet UIPageControl* pages;
    IBOutlet UIScrollView* scroller;
}

@end
