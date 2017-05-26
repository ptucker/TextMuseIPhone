//
//  SettingsViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 4/25/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {

    NSMutableDictionary* tmpCategoryList;
    BOOL discardChanges;
    
    IBOutlet UITableView* chosenCategories;
    IBOutlet UISwitch* sortContacts;
    IBOutlet UISwitch* notifications;
    IBOutlet UISwitch* contacts;
    IBOutlet UISlider* contactCount;
    IBOutlet UISwitch* notes;
    IBOutlet UISlider* notesCount;
    IBOutlet UIView* viewBottomContainer;
    IBOutlet UIButton* btnVersions;
    IBOutlet UILabel* lblFacebook;
}

-(IBAction)switchContacts:(id)sender;
-(IBAction)switchNotes:(id)sender;
-(IBAction)registerUser:(id)sender;
-(IBAction)feedback:(id)sender;
-(IBAction)skins:(id)sender;

@end
