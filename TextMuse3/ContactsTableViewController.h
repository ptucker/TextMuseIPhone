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

@interface ContactsTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    MFMessageComposeViewController *msgcontroller;
    ImageDownloader* loader;
    NSMutableData* inetdata;
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

-(IBAction)backButton:(id)sender;
-(IBAction)check:(id)sender;

@end
