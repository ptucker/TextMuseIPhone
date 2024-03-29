//
//  ContactsTableViewController.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/20/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ImageDownloader.h"
#import "SendMessage.h"

@interface ContactsTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSURLConnectionDelegate> {
    ImageDownloader* loader;
    NSMutableData* inetdata;
    SendMessage* sendMessage;
    NSMutableArray* checkedContacts;
    NSArray* groups;
    bool showRecentContacts;
    
    UIFont* fontBold;
    UIFont* fontLight;
    UIBarButtonItem* rightButton;
    IBOutlet UITableView* contacts;
    IBOutlet UISearchBar* searchbar;
    IBOutlet UISearchController* searchcontroller;
    IBOutlet UIButton* btnSend;
}

@property (readwrite) NSString* GroupName;

-(IBAction)backButton:(id)sender;
-(IBAction)check:(id)sender;

@end
