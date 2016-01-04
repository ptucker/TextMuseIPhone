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

@interface RndMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
DataRefreshDelegate, UINavigationControllerDelegate> {
    IBOutlet UITableView* messages;
    UITableView* categoryTable;
    UIRefreshControl *refreshControl;
    UIView* splash;
    UIView* walkthroughView;
    UIPageControl* pages;
    UIScrollView* scroller;
    NSTimer* timerReminder;
    NSArray* allMessages;
}

-(IBAction)settings:(id)sender;
-(IBAction)home:(id)sender;
@end
