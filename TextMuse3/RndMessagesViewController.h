//
//  RndMessagesViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 12/26/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "GlobalState.h"
#import "ImageDownloader.h"
#import "SendMessage.h"
#import "MessageView.h"

extern NSArray* colors;
extern NSArray* colorsText;
extern NSArray* colorsTitle;

extern const int maxRecentIDs;

@interface RndMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DataRefreshDelegate, CNContactPickerDelegate, UINavigationControllerDelegate> {
    IBOutlet UITableView* messages;
    IBOutlet UIView* bottomMenu;
    IBOutlet UIButton* btnHome;
    IBOutlet UIButton* btnBadges;
    IBOutlet UIButton* btnGroup;
    IBOutlet UIButton* btnCategoryList;
    UITableView* categoryTable;
    UIRefreshControl *refreshControl;
    UIView* splash;
    UIView* walkthroughView;
    UIPageControl* pages;
    UIScrollView* scroller;
    UIScrollView* scrollerCategories;
    NSTimer* timerReminder;
    NSArray* pinnedMessages;
    BOOL showPinned;
    BOOL showEvents;
    NSString* categoryFilter;
    bool segueSettings;
    MessageView* mv;
    SendMessage* sendMessage;
    CNContactStore* contactStore;
}

-(IBAction) showBadges:(id)sender;
-(IBAction)addEvent:(id)sender;
-(IBAction)settings:(id)sender;
-(IBAction)home:(id)sender;
-(IBAction)chooseMessage:(id)sender;
-(void)jumpToMessage;
@end
