//
//  ViewController.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalState.h"
#import "UISuggestionButton.h"

//#define HIDE_TEXT 1
#define SHOW_TEXT 0
#define SHOW_TEXT2 1

//Ignore the contacts for this
//#define HIDE_CONTACT 3
#define SHOW_CONTACT 2
#define SHOW_CONTACT2 3
#define BUTTON_STATES 4
#define TIMER_PAUSED -1

#define HIGHLIGHTED_INTERVAL (5.0)

@interface CategoriesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
DataRefreshDelegate, UIScrollViewDelegate, UIPageViewControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UITableView* categories;
    IBOutlet UIScrollView* randomMessages;
    UITableView* categoryTable;
    UIRefreshControl *refreshControl;
    UIView* splash;
    UIView* walkthroughView;
    UIPageControl* pages;
    UIScrollView* scroller;
    
    UserContact* randomContact;
    int reminderButtonState;
    NSTimer* timerReminder;
    NSTimer* timerFade;
}

-(IBAction)sendRandomMessage:(id)sender;
-(IBAction)settings:(id)sender;
-(UISuggestionButton*) addMessageButton:(Message*)msg;

@end

