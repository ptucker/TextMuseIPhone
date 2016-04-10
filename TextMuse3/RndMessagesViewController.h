//
//  RndMessagesViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalState.h"
#import "ImageDownloader.h"

extern NSArray* colors;
extern NSArray* colorsText;
extern NSArray* colorsTitle;

const int maxRecentIDs = 10;

@interface RndMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
DataRefreshDelegate, UINavigationControllerDelegate, UIScrollViewDelegate> {
    IBOutlet UITableView* messages;
    IBOutlet UIButton* btnHome;
    IBOutlet UIButton* btnEvent;
    IBOutlet UIButton* btnGroup;
    UITableView* categoryTable;
    UIRefreshControl *refreshControl;
    UIView* splash;
    UIView* walkthroughView;
    UIPageControl* pages;
    UIScrollView* scroller;
    NSTimer* timerReminder;
    NSArray* allMessages;
    NSArray* pinnedMessages;
    BOOL showPinned;
    BOOL showEvents;
}

-(IBAction)addEvent:(id)sender;
-(IBAction)settings:(id)sender;
-(IBAction)home:(id)sender;
@end
